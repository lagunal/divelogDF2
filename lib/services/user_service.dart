import 'package:divelogtest/models/user_profile.dart';
import 'package:divelogtest/services/storage_service.dart';
import 'package:divelogtest/services/dive_service.dart';
import 'package:divelogtest/services/firestore_user_service.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

class UserService {
  static final Logger _log = Logger('UserService');
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final _uuid = const Uuid();
  final _storageService = StorageService();
  final _firestoreUserService = FirestoreUserService();
  UserProfile? _currentUser;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadFromStorage();
    _isInitialized = true;
  }

  /// Initialize with Firebase user (called when user signs in)
  Future<void> initializeWithFirebaseUser(User firebaseUser) async {
    try {
      _log.info('Initializing with Firebase user: ${firebaseUser.uid}');

      final localProfile =
          await _storageService.loadUserProfile(firebaseUser.uid);
      if (localProfile != null && localProfile.isNotEmpty) {
        _currentUser = UserProfile.fromJson(localProfile);
        _log.info('Loaded local profile for user: ${_currentUser!.name}');
      } else {
        await _fetchOrCreatedProfileFromCloud(firebaseUser);
      }
      _isInitialized = true;
    } catch (e) {
      _log.severe('Error initializing with Firebase user', e);
      await createDefaultUserIfNeeded();
      _isInitialized = true;
    }
  }

  Future<void> _fetchOrCreatedProfileFromCloud(User firebaseUser) async {
    final firestoreProfile =
        await _firestoreUserService.getUserProfile(firebaseUser.uid);

    if (firestoreProfile != null) {
      _currentUser = firestoreProfile;
      await _saveToStorage();
      _log.info('Fetched profile from Firestore: ${_currentUser!.name}');
    } else {
      _currentUser = await _createFirebaseUserProfile(firebaseUser);
      _log.info('Created new profile for Firebase user: ${_currentUser!.name}');
    }
  }

  /// Create user profile from Firebase user
  Future<UserProfile> _createFirebaseUserProfile(User firebaseUser) async {
    final now = DateTime.now();
    _currentUser = UserProfile(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ??
          firebaseUser.email?.split('@').first ??
          'Usuario',
      email: firebaseUser.email ?? '',
      certificationLevel: null,
      certificationNumber: null,
      certificationDate: null,
      totalDives: 0,
      totalBottomTime: 0.0,
      deepestDive: 0.0,
      createdAt: now,
      updatedAt: now,
    );

    // Save to local storage
    await _saveToStorage();

    // Try to save to Firestore (but don't fail if offline)
    try {
      await _firestoreUserService.createOrUpdateUserProfile(
        userId: firebaseUser.uid,
        name: _currentUser!.name,
        email: _currentUser!.email,
      );
    } catch (e) {
      _log.warning('Could not save to Firestore (offline?)', e);
    }

    return _currentUser!;
  }

  Future<void> _loadFromStorage() async {
    try {
      final storedProfile =
          await _storageService.loadUserProfile('default-user');
      if (storedProfile != null && storedProfile.isNotEmpty) {
        _currentUser = UserProfile.fromJson(storedProfile);
        _log.info('User profile loaded from storage: ${_currentUser!.name}');
      } else {
        _log.info('No user profile found in storage');
        _currentUser = null;
      }
    } catch (e) {
      _log.severe('Error loading user profile from storage', e);
      _currentUser = null;
    }
  }

  Future<void> _saveToStorage() async {
    if (_currentUser == null) return;
    try {
      await _storageService.saveUserProfile(_currentUser!.toJson());
      _log.info('User profile saved to storage');
    } catch (e) {
      _log.severe('Error saving user profile to storage', e);
      rethrow;
    }
  }

  Future<UserProfile> createUserProfile({
    required String name,
    required String email,
    String? certificationLevel,
    String? certificationNumber,
    DateTime? certificationDate,
  }) async {
    await initialize();

    final now = DateTime.now();
    _currentUser = UserProfile(
      id: _uuid.v4(),
      name: name,
      email: email,
      certificationLevel: certificationLevel,
      certificationNumber: certificationNumber,
      certificationDate: certificationDate,
      totalDives: 0,
      totalBottomTime: 0.0,
      deepestDive: 0.0,
      createdAt: now,
      updatedAt: now,
    );

    await _saveToStorage();
    return _currentUser!;
  }

  Future<UserProfile?> getUserProfile() async {
    await initialize();
    if (_currentUser == null) {
      _log.info('No user found, creating default user');
      await createDefaultUserIfNeeded();
    }
    return _currentUser;
  }

  Future<UserProfile> updateUserProfile({
    String? name,
    String? email,
    String? certificationLevel,
    String? certificationNumber,
    DateTime? certificationDate,
  }) async {
    await initialize();

    if (_currentUser == null) {
      throw Exception('No user profile found. Create a profile first.');
    }

    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
      certificationLevel: certificationLevel,
      certificationNumber: certificationNumber,
      certificationDate: certificationDate,
      updatedAt: DateTime.now(),
    );

    await _saveToStorage();
    return _currentUser!;
  }

  Future<UserProfile> updateUserStatistics() async {
    await initialize();

    if (_currentUser == null) {
      throw Exception('No user profile found. Create a profile first.');
    }

    final diveService = DiveService();
    final stats = await diveService.getStatistics(_currentUser!.id);

    _currentUser = _currentUser!.copyWith(
      totalDives: stats['totalDives'] as int,
      totalBottomTime: stats['totalBottomTime'] as double,
      deepestDive: stats['deepestDive'] as double,
      updatedAt: DateTime.now(),
    );

    await _saveToStorage();
    return _currentUser!;
  }

  Future<void> createDefaultUserIfNeeded() async {
    // Don't call initialize() here to avoid recursion
    if (_currentUser == null) {
      final now = DateTime.now();
      _currentUser = UserProfile(
        id: 'default-user', // Fixed ID for offline-first single user
        name: 'Usuario Demo',
        email: 'demo@divelogapp.com',
        certificationLevel: 'Open Water Diver',
        totalDives: 0,
        totalBottomTime: 0.0,
        deepestDive: 0.0,
        createdAt: now,
        updatedAt: now,
      );
      await _saveToStorage();
      _log.info('Default user profile created: ${_currentUser!.name}');
    }
  }

  Future<void> deleteUserProfile() async {
    await initialize();
    _currentUser = null;
    await _storageService.saveUserProfile({});
  }

  String? getCurrentUserId() => _currentUser?.id;

  bool get hasUserProfile => _currentUser != null;
}
