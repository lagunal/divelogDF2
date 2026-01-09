import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divelogtest/models/dive_session.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class FirestoreDiveService {
  static final FirestoreDiveService _instance = FirestoreDiveService._internal();
  factory FirestoreDiveService() => _instance;
  FirestoreDiveService._internal();

  final _uuid = const Uuid();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _divesCollection =>
      _firestore.collection('dive_sessions');

  Future<DiveSession> createDiveSession(DiveSession session, String userId) async {
    try {
      final newSession = session.copyWith(
        userId: userId,
        // Preserve original timestamps if syncing, otherwise update
        createdAt: session.createdAt, 
        updatedAt: DateTime.now(),
      );

      await _divesCollection.doc(newSession.id).set(newSession.toFirestore());
      debugPrint('Dive session created in Firestore: ${newSession.id}');
      return newSession;
    } catch (e) {
      debugPrint('Error creating dive session in Firestore: $e');
      rethrow;
    }
  }

  Future<List<DiveSession>> getAllDiveSessions(String userId) async {
    try {
      final snapshot = await _divesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('horaEntrada', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => DiveSession.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching dive sessions from Firestore: $e');
      return [];
    }
  }

  Stream<List<DiveSession>> watchAllDiveSessions(String userId) {
    return _divesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('horaEntrada', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DiveSession.fromFirestore(doc.data()))
            .toList());
  }

  Future<DiveSession?> getDiveSessionById(String id, String userId) async {
    try {
      final doc = await _divesCollection.doc(id).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      if (data['userId'] != userId) {
        debugPrint('User does not have access to this dive session');
        return null;
      }

      return DiveSession.fromFirestore(data);
    } catch (e) {
      debugPrint('Error fetching dive session from Firestore: $e');
      return null;
    }
  }

  Future<List<DiveSession>> getDiveSessionsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snapshot = await _divesCollection
          .where('userId', isEqualTo: userId)
          .where('horaEntrada', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('horaEntrada', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('horaEntrada', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => DiveSession.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching dive sessions by date range from Firestore: $e');
      return [];
    }
  }

  Future<List<DiveSession>> getDiveSessionsByLocation(
    String userId,
    String location,
  ) async {
    try {
      final snapshot = await _divesCollection
          .where('userId', isEqualTo: userId)
          .where('lugarBuceo', isEqualTo: location)
          .orderBy('horaEntrada', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => DiveSession.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching dive sessions by location from Firestore: $e');
      return [];
    }
  }

  Future<List<DiveSession>> getDiveSessionsByOperator(
    String userId,
    String operator,
  ) async {
    try {
      final snapshot = await _divesCollection
          .where('userId', isEqualTo: userId)
          .where('operadoraBuceo', isEqualTo: operator)
          .orderBy('horaEntrada', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => DiveSession.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching dive sessions by operator from Firestore: $e');
      return [];
    }
  }

  Future<DiveSession> updateDiveSession(DiveSession session, String userId) async {
    try {
      if (session.userId != userId) {
        throw Exception('User does not have permission to update this dive session');
      }

      final updatedSession = session.copyWith(updatedAt: DateTime.now());
      await _divesCollection.doc(session.id).update(updatedSession.toFirestore());
      debugPrint('Dive session updated in Firestore: ${session.id}');
      return updatedSession;
    } catch (e) {
      debugPrint('Error updating dive session in Firestore: $e');
      rethrow;
    }
  }

  Future<void> deleteDiveSession(String id, String userId) async {
    try {
      final doc = await _divesCollection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Dive session not found');
      }

      final data = doc.data()!;
      if (data['userId'] != userId) {
        throw Exception('User does not have permission to delete this dive session');
      }

      await _divesCollection.doc(id).delete();
      debugPrint('Dive session deleted from Firestore: $id');
    } catch (e) {
      debugPrint('Error deleting dive session from Firestore: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStatistics(String userId) async {
    try {
      final sessions = await getAllDiveSessions(userId);

      if (sessions.isEmpty) {
        return {
          'totalDives': 0,
          'totalBottomTime': 0.0,
          'deepestDive': 0.0,
          'averageDepth': 0.0,
          'totalDiveTime': 0.0,
        };
      }

      final totalDives = sessions.length;
      final totalBottomTime = sessions.fold<double>(
        0.0,
        (sum, session) => sum + session.tiempoFondo,
      );
      final deepestDive = sessions.fold<double>(
        0.0,
        (max, session) => session.maximaProfundidad > max ? session.maximaProfundidad : max,
      );
      final averageDepth = sessions.fold<double>(
        0.0,
        (sum, session) => sum + session.maximaProfundidad,
      ) / totalDives;
      final totalDiveTime = sessions.fold<double>(
        0.0,
        (sum, session) => sum + session.tiempoTotalInmersion,
      );

      return {
        'totalDives': totalDives,
        'totalBottomTime': totalBottomTime,
        'deepestDive': deepestDive,
        'averageDepth': averageDepth,
        'totalDiveTime': totalDiveTime,
      };
    } catch (e) {
      debugPrint('Error calculating statistics from Firestore: $e');
      return {
        'totalDives': 0,
        'totalBottomTime': 0.0,
        'deepestDive': 0.0,
        'averageDepth': 0.0,
        'totalDiveTime': 0.0,
      };
    }
  }

  Future<List<String>> getUniqueLocations(String userId) async {
    try {
      final sessions = await getAllDiveSessions(userId);
      final locations = sessions.map((s) => s.lugarBuceo).toSet().toList();
      locations.sort();
      return locations;
    } catch (e) {
      debugPrint('Error fetching unique locations from Firestore: $e');
      return [];
    }
  }

  Future<List<String>> getUniqueOperators(String userId) async {
    try {
      final sessions = await getAllDiveSessions(userId);
      final operators = sessions.map((s) => s.operadoraBuceo).toSet().toList();
      operators.sort();
      return operators;
    } catch (e) {
      debugPrint('Error fetching unique operators from Firestore: $e');
      return [];
    }
  }
}
