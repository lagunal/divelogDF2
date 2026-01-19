import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divelogtest/models/user_profile.dart';
import 'package:divelogtest/services/firestore_dive_service.dart';
import 'package:logging/logging.dart';

class FirestoreUserService {
  static final Logger _log = Logger('FirestoreUserService');
  static final FirestoreUserService _instance =
      FirestoreUserService._internal();
  factory FirestoreUserService() => _instance;
  FirestoreUserService._internal();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final FirestoreDiveService _diveService = FirestoreDiveService();

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<UserProfile> createOrUpdateUserProfile({
    required String userId,
    required String name,
    required String email,
    String? certificationLevel,
    String? certificationNumber,
    DateTime? certificationDate,
  }) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      final profile = doc.exists
          ? _updateExistingProfile(doc, name, email, certificationLevel,
              certificationNumber, certificationDate)
          : _createNewProfile(userId, name, email, certificationLevel,
              certificationNumber, certificationDate);

      await _usersCollection.doc(userId).set(profile.toFirestore());
      _log.info('User profile saved to Firestore: $userId');
      return profile;
    } catch (e) {
      _log.severe('Error saving user profile to Firestore', e);
      rethrow;
    }
  }

  UserProfile _updateExistingProfile(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String name,
    String email,
    String? certLevel,
    String? certNum,
    DateTime? certDate,
  ) {
    final existing = UserProfile.fromFirestore(doc.data()!);
    return existing.copyWith(
      name: name,
      email: email,
      certificationLevel: certLevel ?? existing.certificationLevel,
      certificationNumber: certNum ?? existing.certificationNumber,
      certificationDate: certDate ?? existing.certificationDate,
      updatedAt: DateTime.now(),
    );
  }

  UserProfile _createNewProfile(
    String userId,
    String name,
    String email,
    String? certLevel,
    String? certNum,
    DateTime? certDate,
  ) {
    final now = DateTime.now();
    return UserProfile(
      id: userId,
      name: name,
      email: email,
      certificationLevel: certLevel,
      certificationNumber: certNum,
      certificationDate: certDate,
      totalDives: 0,
      totalBottomTime: 0.0,
      deepestDive: 0.0,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) {
        _log.info('User profile not found in Firestore: $userId');
        return null;
      }
      return UserProfile.fromFirestore(doc.data()!);
    } catch (e) {
      _log.severe('Error fetching user profile from Firestore', e);
      return null;
    }
  }

  Stream<UserProfile?> watchUserProfile(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc.data()!);
    });
  }

  Future<UserProfile> updateUserStatistics(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      if (profile == null) {
        throw Exception('User profile not found');
      }

      final stats = await _diveService.getStatistics(userId);

      final updatedProfile = profile.copyWith(
        totalDives: stats['totalDives'] as int,
        totalBottomTime: stats['totalBottomTime'] as double,
        deepestDive: stats['deepestDive'] as double,
        updatedAt: DateTime.now(),
      );

      await _usersCollection.doc(userId).update(updatedProfile.toFirestore());
      _log.info('User statistics updated in Firestore: $userId');
      return updatedProfile;
    } catch (e) {
      _log.severe('Error updating user statistics in Firestore', e);
      rethrow;
    }
  }

  Future<void> deleteUserProfile(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
      _log.info('User profile deleted from Firestore: $userId');
    } catch (e) {
      _log.severe('Error deleting user profile from Firestore', e);
      rethrow;
    }
  }
}
