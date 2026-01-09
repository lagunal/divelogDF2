import 'dart:async';

// Stub implementation for Web to avoid importing sqflite
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<int> insertDiveSession(Map<String, dynamic> session) async {
    throw UnimplementedError('Not supported on Web');
  }

  Future<List<Map<String, dynamic>>> getAllDiveSessions() async {
    throw UnimplementedError('Not supported on Web');
  }

  Future<Map<String, dynamic>?> getDiveSessionById(String id) async {
    throw UnimplementedError('Not supported on Web');
  }

  Future<int> updateDiveSession(Map<String, dynamic> session) async {
    throw UnimplementedError('Not supported on Web');
  }

  Future<int> deleteDiveSession(String id) async {
    throw UnimplementedError('Not supported on Web');
  }

  Future<int> saveUserProfile(Map<String, dynamic> profile) async {
    throw UnimplementedError('Not supported on Web');
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    throw UnimplementedError('Not supported on Web');
  }

  Future<void> clearAll() async {
    throw UnimplementedError('Not supported on Web');
  }
}
