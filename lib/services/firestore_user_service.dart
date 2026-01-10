import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divelogtest/models/user_profile.dart';
import 'package:divelogtest/services/firestore_dive_service.dart';
import 'package:flutter/foundation.dart';

class FirestoreUserService {
  static final FirestoreUserService _instance = FirestoreUserService._internal();
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
      final now = DateTime.now();
      final doc = await _usersCollection.doc(userId).get();

      UserProfile profile;
      if (doc.exists) {
        // Update existing profile
        final existing = UserProfile.fromFirestore(doc.data()!);
        profile = existing.copyWith(
          name: name,
          email: email,
          certificationLevel: certificationLevel ?? existing.certificationLevel,
          certificationNumber: certificationNumber ?? existing.certificationNumber,
          certificationDate: certificationDate ?? existing.certificationDate,
          updatedAt: now,
        );
      } else {
        // Create new profile
        profile = UserProfile(
          id: userId,
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
      }

      await _usersCollection.doc(userId).set(profile.toFirestore());
      debugPrint('User profile saved to Firestore: $userId');
      return profile;
    } catch (e) {
      debugPrint('Error saving user profile to Firestore: $e');
      rethrow;
    }
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) {
        debugPrint('User profile not found in Firestore: $userId');
        return null;
      }
      return UserProfile.fromFirestore(doc.data()!);
    } catch (e) {
      debugPrint('Error fetching user profile from Firestore: $e');
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
      debugPrint('User statistics updated in Firestore: $userId');
      return updatedProfile;
    } catch (e) {
      debugPrint('Error updating user statistics in Firestore: $e');
      rethrow;
    }
  }

  Future<void> deleteUserProfile(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
      debugPrint('User profile deleted from Firestore: $userId');
    } catch (e) {
      debugPrint('Error deleting user profile from Firestore: $e');
      rethrow;
    }
  }
}
