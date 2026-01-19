import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

/// Web-only storage service using SharedPreferences for persistence
class WebStorageService {
  static final Logger _log = Logger('WebStorageService');
  static final WebStorageService _instance = WebStorageService._internal();
  static const String _divesKey = 'dive_sessions';
  static const String _userProfileKeyPrefix = 'user_profile_';
  static const String _currentUserIdKey = 'current_user_id';

  factory WebStorageService() {
    return _instance;
  }

  WebStorageService._internal();

  Future<void> saveDiveSessions(List<Map<String, dynamic>> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(sessions);
      await prefs.setString(_divesKey, jsonString);
      _log.info('${sessions.length} dive sessions saved to SharedPreferences');
    } catch (e) {
      _log.severe('Error saving dive sessions', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> loadDiveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_divesKey);

      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> decoded = jsonDecode(jsonString);
      return List<Map<String, dynamic>>.from(
        decoded.map((item) => item as Map<String, dynamic>),
      );
    } catch (e) {
      _log.severe('Error loading dive sessions', e);
      return [];
    }
  }

  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = profile['id'] as String?;

      if (userId == null) {
        _log.warning('Cannot save user profile without userId');
        return;
      }

      final userKey = '$_userProfileKeyPrefix$userId';
      final jsonString = jsonEncode(profile);
      await prefs.setString(userKey, jsonString);
      await prefs.setString(_currentUserIdKey, userId);
      _log.info('User profile saved to SharedPreferences: $userKey');
    } catch (e) {
      _log.severe('Error saving user profile', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loadUserProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = '$_userProfileKeyPrefix$userId';
      final jsonString = prefs.getString(userKey);

      if (jsonString == null || jsonString.isEmpty) {
        _log.info('No profile found for userId: $userId');
        return null;
      }

      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        _log.info('Loaded profile for userId: $userId');
        return decoded;
      }

      return null;
    } catch (e) {
      _log.severe('Error loading user profile', e);
      return null;
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _log.info('All SharedPreferences cleared');
    } catch (e) {
      _log.severe('Error clearing storage', e);
      rethrow;
    }
  }
}
