import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:divelogtest/models/dive_session.dart';
import 'package:divelogtest/services/dive_service.dart';
import 'package:logging/logging.dart';

class DiveProvider extends ChangeNotifier {
  static final Logger _log = Logger('DiveProvider');
  final DiveService _diveService = DiveService();
  StreamSubscription<SyncStatus>? _syncStatusSubscription;

  List<DiveSession> _allDives = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  SyncStatus _syncStatus = SyncStatus.completed;

  List<DiveSession> get allDives => List.unmodifiable(_allDives);
  List<DiveSession> get recentDives => _allDives.take(3).toList();
  Map<String, dynamic> get statistics => Map.unmodifiable(_statistics);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  bool get isOnline => _diveService.isOnline;
  bool get isSyncing => _diveService.isSyncing;
  int get pendingSyncCount => _diveService.pendingSyncCount;
  SyncStatus get syncStatus => _syncStatus;

  Future<void> initialize(String userId) async {
    if (_isInitialized) {
      _log.info('DiveProvider already initialized for user: $userId');
      return;
    }

    _log.info('Initializing DiveProvider for user: $userId');
    _setLoading(true);

    try {
      await _diveService.syncFromFirestore(userId);
      await _loadAllData(userId);
      _isInitialized = true;
      _setupSyncListener();
      _log.info('DiveProvider initialized. Total dives: ${_allDives.length}');
      // Background sync
      _diveService.syncPendingDives();
    } catch (e) {
      _error = 'Error al inicializar: $e';
      _log.severe('Error initializing DiveProvider', e);
    } finally {
      _setLoading(false);
    }
  }

  void _setupSyncListener() {
    _syncStatusSubscription?.cancel();
    _syncStatusSubscription = _diveService.syncStatusStream.listen((status) {
      _syncStatus = status;
      _log.info('Sync status changed: $status');
      notifyListeners();

      if (status == SyncStatus.completed) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) refreshData(userId);
      }
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (!value) _error = null;
    notifyListeners();
  }

  Future<void> _loadAllData(String userId) async {
    try {
      _allDives = await _diveService.getDiveSessionsByUserId(userId);
      _statistics = await _diveService.getStatistics(userId);
    } catch (e) {
      _log.severe('Error loading dive data', e);
      rethrow;
    }
  }

  Future<void> refreshData(String userId) async {
    _setLoading(true);
    try {
      await _loadAllData(userId);
    } catch (e) {
      _error = 'Error al actualizar datos: $e';
      _log.severe('Error refreshing data', e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createDive(DiveSession session) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create locally (and sync if online)
      final newSession = await _diveService.createDiveSession(session);
      _allDives.insert(0, newSession);
      await _updateStatistics(userId);
    } catch (e) {
      _error = 'Error al crear inmersión: $e';
      _log.severe('Error creating dive', e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateDive(DiveSession session) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update locally (and sync if online)
      final updatedSession = await _diveService.updateDiveSession(session);
      final index = _allDives.indexWhere((d) => d.id == session.id);
      if (index != -1) {
        _allDives[index] = updatedSession;
        _allDives.sort((a, b) => b.horaEntrada.compareTo(a.horaEntrada));
      }
      await _updateStatistics(userId);
    } catch (e) {
      _error = 'Error al actualizar inmersión: $e';
      _log.severe('Error updating dive', e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteDive(String id, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _diveService.deleteDiveSession(id, userId);
      _allDives.removeWhere((d) => d.id == id);
      await _updateStatistics(userId);
    } catch (e) {
      _error = 'Error al eliminar inmersión: $e';
      _log.severe('Error deleting dive', e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _updateStatistics(String userId) async {
    try {
      _statistics = await _diveService.getStatistics(userId);
    } catch (e) {
      _log.warning('Error updating statistics', e);
    }
  }

  Future<List<String>> getUniqueLocations() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];
    return await _diveService.getUniqueLocations(userId);
  }

  Future<List<String>> getUniqueOperators() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];
    return await _diveService.getUniqueOperators(userId);
  }

  DiveSession? getDiveById(String id) {
    try {
      return _allDives.firstWhere((dive) => dive.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> manualSync() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await _diveService.syncPendingDives();
    } catch (e) {
      _log.severe('Error during manual sync', e);
    }
  }

  @override
  void dispose() {
    _syncStatusSubscription?.cancel();
    super.dispose();
  }
}
