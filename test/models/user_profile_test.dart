import 'package:flutter_test/flutter_test.dart';
import 'package:divelogtest/models/user_profile.dart';

void main() {
  group('UserProfile serialization', () {
    final base = UserProfile(
      id: 'user-123',
      name: 'Test Diver',
      email: 'test@example.com',
      certificationLevel: 'Advanced',
      certificationNumber: 'CERT-001',
      certificationDate: DateTime.parse('2023-01-01T12:00:00Z'),
      totalDives: 15,
      totalBottomTime: 500.5,
      deepestDive: 30.0,
      createdAt: DateTime.parse('2023-01-01T10:00:00Z'),
      updatedAt: DateTime.parse('2023-02-01T10:00:00Z'),
    );

    test('toJson -> fromJson round-trip preserves all fields', () {
      final map = base.toJson();
      final decoded = UserProfile.fromJson(map);

      expect(decoded.id, base.id);
      expect(decoded.name, base.name);
      expect(decoded.email, base.email);
      expect(decoded.certificationLevel, base.certificationLevel);
      expect(decoded.certificationNumber, base.certificationNumber);
      expect(decoded.totalDives, base.totalDives);
      expect(decoded.totalBottomTime, base.totalBottomTime);
      expect(decoded.deepestDive, base.deepestDive);
      
      // Dates
      expect(decoded.certificationDate?.toIso8601String(), base.certificationDate?.toIso8601String());
      expect(decoded.createdAt.toIso8601String(), base.createdAt.toIso8601String());
      expect(decoded.updatedAt.toIso8601String(), base.updatedAt.toIso8601String());
    });

    test('fromJson handles null optional fields', () {
      final map = base.toJson();
      map['certificationLevel'] = null;
      map['certificationNumber'] = null;
      map['certificationDate'] = null;

      final decoded = UserProfile.fromJson(map);
      expect(decoded.certificationLevel, isNull);
      expect(decoded.certificationNumber, isNull);
      expect(decoded.certificationDate, isNull);
    });

    test('fromJson handles numeric type conversions (int to double)', () {
      final map = base.toJson();
      // Force int where double is expected
      map['totalBottomTime'] = 500; 
      map['deepestDive'] = 30;

      final decoded = UserProfile.fromJson(map);
      expect(decoded.totalBottomTime, 500.0);
      expect(decoded.deepestDive, 30.0);
    });
  });
}
