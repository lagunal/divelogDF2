import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:divelogtest/models/dive_session.dart';
import 'package:divelogtest/services/storage_service.dart';
import 'package:divelogtest/services/firestore_dive_service.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

class DiveService {
  static final Logger _log = Logger('DiveService');
  static final DiveService _instance = DiveService._internal();
  factory DiveService() => _instance;
  DiveService._internal();

  final _uuid = const Uuid();
  final _storageService = StorageService();
  final _firestoreService = FirestoreDiveService();
  final _connectivity = Connectivity();

  List<DiveSession> _sessions = [];
  bool _isInitialized = false;
  bool _isOnline = false;
  bool _isSyncing = false;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Sync status stream
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  int get pendingSyncCount => _sessions.where((s) => !s.isSynced).length;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadFromStorage();
    _isInitialized = true;

    _initConnectivityListener();

    // Check initial connectivity status
    await _updateConnectivityStatus();

    // Attempt to sync on startup if online
    if (_isOnline) {
      syncPendingDives();
    }
  }

  void _initConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final wasOffline = !_isOnline;
        await _updateConnectivityStatus();

        // If we just came online, trigger sync
        if (wasOffline && _isOnline) {
          _log.info('Connection restored. Starting automatic sync...');
          _syncStatusController.add(SyncStatus.reconnected);
          syncPendingDives();
        } else if (!_isOnline) {
          _log.info('Connection lost. Working in offline mode.');
          _syncStatusController.add(SyncStatus.offline);
        }
      },
    );
  }

  Future<void> _updateConnectivityStatus() async {
    _isOnline = await _isOnlineCheck();
    _log.info('Connectivity status: ${_isOnline ? "Online" : "Offline"}');
  }

  Future<void> _loadFromStorage() async {
    try {
      final data = await _storageService.loadDiveSessions();
      _sessions = data.map((json) => DiveSession.fromJson(json)).toList();
      _sessions.sort((a, b) => b.horaEntrada.compareTo(a.horaEntrada));
    } catch (e) {
      _log.severe('Error loading dive sessions from storage', e);
      _sessions = [];
    }
  }

  // Helper to update session in memory list and storage
  Future<void> _updateLocalSession(DiveSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
    } else {
      _sessions.insert(0, session);
    }
    _sessions.sort((a, b) => b.horaEntrada.compareTo(a.horaEntrada));
    await _storageService.saveDiveSession(session.toJson());
    // Note: storageService calls databaseHelper, which now logs the DB write.
    // We add a high-level log here for flow tracking.
    _log.info(
        'Local session updated in memory and storage request sent: ${session.id}');
  }

  Future<bool> _isOnlineCheck() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet) ||
          result.contains(ConnectivityResult.vpn);
    } catch (e) {
      _log.severe('Error checking connectivity', e);
      return false;
    }
  }

  Future<DiveSession> createDiveSession(DiveSession session) async {
    await initialize();

    // 1. Create locally first (Offline First)
    var newSession = session.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await _updateLocalSession(newSession);

    // 2. Try to sync to Firestore if online
    if (_isOnline) {
      try {
        await _firestoreService.createDiveSession(
            newSession, newSession.userId);

        // Mark as synced
        newSession = newSession.copyWith(
          isSynced: true,
          lastSyncedAt: DateTime.now(),
        );
        await _updateLocalSession(newSession);
        _log.info('Dive session created and synced: ${newSession.id}');
      } catch (e) {
        _log.warning('Error syncing dive to Firestore (will retry)', e);
      }
    }

    return newSession;
  }

  Future<DiveSession> updateDiveSession(DiveSession session) async {
    await initialize();

    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index == -1) {
      throw Exception('Dive session not found');
    }

    // 1. Update locally first
    var updatedSession = session.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false, // Mark as dirty until synced
    );

    await _updateLocalSession(updatedSession);

    // 2. Try to sync to Firestore
    if (_isOnline) {
      try {
        // Use createDiveSession (upsert) to be safe in case it doesn't exist on server
        await _firestoreService.createDiveSession(
            updatedSession, updatedSession.userId);

        updatedSession = updatedSession.copyWith(
          isSynced: true,
          lastSyncedAt: DateTime.now(),
        );
        await _updateLocalSession(updatedSession);
        _log.info('Dive session updated and synced: ${updatedSession.id}');
      } catch (e) {
        _log.warning('Error syncing updated dive to Firestore', e);
      }
    }

    return updatedSession;
  }

  Future<void> deleteDiveSession(String id, String userId) async {
    await initialize();

    final index = _sessions.indexWhere((session) => session.id == id);
    if (index == -1) {
      throw Exception('Dive session not found');
    }

    // For deletion, it's tricky in offline-first without soft deletes.
    // Ideally we should mark as "deleted" (isDeleted=true) and sync that.
    // For now, we will delete locally and try to delete remotely.
    // If offline, the remote delete will fail and we might have a zombie record on server.
    // TODO: Implement soft delete for robust offline deletion sync.

    // Remove locally
    _sessions.removeAt(index);
    // We need to delete from SQLite too.
    // StorageService doesn't expose delete single? It does in database_helper.
    // But StorageService only has clearAll. We need to add delete to StorageService or access DB helper.
    // Wait, DatabaseHelper has deleteDiveSession. StorageService doesn't expose it.
    // I should have added delete to StorageService.
    // For now, I'll access DatabaseHelper via StorageService if I can, or update StorageService.

    // Assuming StorageService needs an update for delete.
    // I will skip StorageService update here and address it in next step if needed.
    // But wait, the previous implementation used _saveToStorage() which saved the whole list.
    // So removing from list and saving list WORKS for deletion locally.
    await _saveToStorage();

    // Try remote delete
    if (_isOnline) {
      try {
        await _firestoreService.deleteDiveSession(id, userId);
        _log.info('Dive session deleted from Firestore: $id');
      } catch (e) {
        _log.warning('Error deleting from Firestore (zombie record risk)', e);
      }
    }
  }

  // This helper is needed because we switched to single item update,
  // but for delete we fall back to full list save unless we add delete to StorageService.
  Future<void> _saveToStorage() async {
    try {
      final data = _sessions.map((session) => session.toJson()).toList();
      await _storageService.saveDiveSessions(data);
    } catch (e) {
      _log.severe('Error saving dive sessions to storage', e);
      rethrow;
    }
  }

  Future<void> syncPendingDives() async {
    await initialize();

    if (!_isOnline || _isSyncing) return;

    final pendingSessions = _sessions.where((s) => !s.isSynced).toList();
    if (pendingSessions.isEmpty) {
      _syncStatusController.add(SyncStatus.completed);
      return;
    }

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);
    _log.info('Found ${pendingSessions.length} pending dives to sync...');

    int successCount = 0;
    int failCount = 0;

    for (var session in pendingSessions) {
      try {
        await _firestoreService.createDiveSession(session, session.userId);

        // Update local status
        final syncedSession = session.copyWith(
          isSynced: true,
          lastSyncedAt: DateTime.now(),
        );
        await _updateLocalSession(syncedSession);
        successCount++;
        _log.info('Synced pending dive: ${session.id}');
      } catch (e) {
        failCount++;
        _log.warning('Failed to sync dive ${session.id}', e);
      }
    }

    _isSyncing = false;

    if (failCount == 0) {
      _syncStatusController.add(SyncStatus.completed);
      _log.info('✅ All $successCount dives synced successfully');
    } else {
      _syncStatusController.add(SyncStatus.error);
      _log.warning(
          '⚠️ Sync completed with errors: $successCount S, $failCount F');
    }
  }

  // Read methods (Local Cache)

  Future<void> syncFromFirestore(String userId) async {
    await initialize();
    if (!_isOnline) return;

    try {
      _log.info('Syncing from Firestore for user: $userId...');
      final cloudSessions = await _firestoreService.getAllDiveSessions(userId);
      if (cloudSessions.isEmpty) {
        _log.info('No sessions found in Firestore.');
        return;
      }
      await _processCloudSessions(cloudSessions);
    } catch (e) {
      _log.severe('Error syncing from Firestore', e);
      rethrow;
    }
  }

  Future<void> _processCloudSessions(List<DiveSession> cloudSessions) async {
    int addedCount = 0;
    for (var cloudSession in cloudSessions) {
      final exists = _sessions.any((s) => s.id == cloudSession.id);
      if (!exists) {
        _sessions.add(cloudSession.copyWith(isSynced: true));
        addedCount++;
      }
    }

    if (addedCount > 0) {
      _sessions.sort((a, b) => b.horaEntrada.compareTo(a.horaEntrada));
      await _saveToStorage();
      _log.info('Sync complete: Added $addedCount new sessions.');
    } else {
      _log.info('Sync complete: No new sessions to add.');
    }
  }

  Future<List<DiveSession>> getAllDiveSessions() async {
    await initialize();
    return List.unmodifiable(_sessions);
  }

  Future<DiveSession?> getDiveSessionById(String id) async {
    await initialize();
    try {
      return _sessions.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<DiveSession>> getDiveSessionsByDateRange(
      DateTime start, DateTime end) async {
    await initialize();
    return _sessions
        .where((session) =>
            session.horaEntrada
                .isAfter(start.subtract(const Duration(days: 1))) &&
            session.horaEntrada.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  Future<List<DiveSession>> getDiveSessionsByLocation(String location) async {
    await initialize();
    return _sessions
        .where((session) =>
            session.lugarBuceo.toLowerCase().contains(location.toLowerCase()))
        .toList();
  }

  Future<List<DiveSession>> getDiveSessionsByOperator(String operator) async {
    await initialize();
    return _sessions
        .where((session) => session.operadoraBuceo
            .toLowerCase()
            .contains(operator.toLowerCase()))
        .toList();
  }

  Future<List<DiveSession>> getDiveSessionsByUserId(String userId) async {
    await initialize();
    return _sessions.where((session) => session.userId == userId).toList();
  }

  Future<Map<String, dynamic>> getStatistics(String userId) async {
    await initialize();
    final userSessions =
        _sessions.where((session) => session.userId == userId).toList();
    return calculateStatistics(userSessions);
  }

  static Map<String, dynamic> calculateStatistics(
      List<DiveSession> userSessions) {
    if (userSessions.isEmpty) {
      return {
        'totalDives': 0,
        'totalBottomTime': 0.0,
        'deepestDive': 0.0,
        'averageDepth': 0.0,
        'totalDiveTime': 0.0,
      };
    }

    final totalDives = userSessions.length;
    final totalBottomTime = userSessions.fold<double>(
        0.0, (sum, session) => sum + session.tiempoFondo);
    final deepestDive = userSessions.fold<double>(
        0.0,
        (max, session) =>
            session.maximaProfundidad > max ? session.maximaProfundidad : max);
    final averageDepth = userSessions.fold<double>(
            0.0, (sum, session) => sum + session.maximaProfundidad) /
        totalDives;
    final totalDiveTime = userSessions.fold<double>(
        0.0, (sum, session) => sum + session.tiempoTotalInmersion);

    return {
      'totalDives': totalDives,
      'totalBottomTime': totalBottomTime,
      'deepestDive': deepestDive,
      'averageDepth': averageDepth,
      'totalDiveTime': totalDiveTime,
    };
  }

  Future<List<String>> getUniqueLocations(String userId) async {
    await initialize();
    // Filter by userId locally as well? Yes.
    final locations = _sessions
        .where((s) => s.userId == userId)
        .map((s) => s.lugarBuceo)
        .toSet()
        .toList();
    locations.sort();
    return locations;
  }

  Future<List<String>> getUniqueOperators(String userId) async {
    await initialize();
    final operators = _sessions
        .where((s) => s.userId == userId)
        .map((s) => s.operadoraBuceo)
        .toSet()
        .toList();
    operators.sort();
    return operators;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
  }
}

enum SyncStatus {
  syncing,
  completed,
  error,
  offline,
  reconnected,
}
