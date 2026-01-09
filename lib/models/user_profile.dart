import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? certificationLevel;
  final String? certificationNumber;
  final DateTime? certificationDate;
  final int totalDives;
  final double totalBottomTime;
  final double deepestDive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.certificationLevel,
    this.certificationNumber,
    this.certificationDate,
    this.totalDives = 0,
    this.totalBottomTime = 0.0,
    this.deepestDive = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'certificationLevel': certificationLevel,
    'certificationNumber': certificationNumber,
    'certificationDate': certificationDate?.toIso8601String(),
    'totalDives': totalDives,
    'totalBottomTime': totalBottomTime,
    'deepestDive': deepestDive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'name': name,
    'email': email,
    'certificationLevel': certificationLevel,
    'certificationNumber': certificationNumber,
    'certificationDate': certificationDate != null ? Timestamp.fromDate(certificationDate!) : null,
    'totalDives': totalDives,
    'totalBottomTime': totalBottomTime,
    'deepestDive': deepestDive,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    certificationLevel: json['certificationLevel'] as String?,
    certificationNumber: json['certificationNumber'] as String?,
    certificationDate: json['certificationDate'] != null 
      ? DateTime.parse(json['certificationDate'] as String) 
      : null,
    totalDives: json['totalDives'] as int? ?? 0,
    totalBottomTime: (json['totalBottomTime'] as num?)?.toDouble() ?? 0.0,
    deepestDive: (json['deepestDive'] as num?)?.toDouble() ?? 0.0,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  factory UserProfile.fromFirestore(Map<String, dynamic> data) => UserProfile(
    id: data['id'] as String,
    name: data['name'] as String,
    email: data['email'] as String,
    certificationLevel: data['certificationLevel'] as String?,
    certificationNumber: data['certificationNumber'] as String?,
    certificationDate: data['certificationDate'] != null 
      ? (data['certificationDate'] as Timestamp).toDate()
      : null,
    totalDives: data['totalDives'] as int? ?? 0,
    totalBottomTime: (data['totalBottomTime'] as num?)?.toDouble() ?? 0.0,
    deepestDive: (data['deepestDive'] as num?)?.toDouble() ?? 0.0,
    createdAt: (data['createdAt'] as Timestamp).toDate(),
    updatedAt: (data['updatedAt'] as Timestamp).toDate(),
  );

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? certificationLevel,
    String? certificationNumber,
    DateTime? certificationDate,
    int? totalDives,
    double? totalBottomTime,
    double? deepestDive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    certificationLevel: certificationLevel ?? this.certificationLevel,
    certificationNumber: certificationNumber ?? this.certificationNumber,
    certificationDate: certificationDate ?? this.certificationDate,
    totalDives: totalDives ?? this.totalDives,
    totalBottomTime: totalBottomTime ?? this.totalBottomTime,
    deepestDive: deepestDive ?? this.deepestDive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
