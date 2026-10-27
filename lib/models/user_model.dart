import 'dart:convert';
import 'package:crypto/crypto.dart';

enum UserRole { admin, faculty, cr }

class User {
  final String userId;
  final String registrationNumber;
  final String name;
  final String passwordHash;
  final UserRole role;
  final String? academicYear;
  final String? branch;
  final String? section;
  final bool active;

  User({
    required this.userId,
    required this.registrationNumber,
    required this.name,
    required this.passwordHash,
    required this.role,
    this.academicYear,
    this.branch,
    this.section,
    this.active = true,
  });

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Mandatory restriction: The CRs are strictly I1 (24B01A12I1) and F7 (24B01A12F7) only.
  static bool isAuthorizedCR(String regNo) {
    final clean = regNo.trim().toUpperCase();
    return clean == '24B01A12I1' || clean == '24B01A12F7';
  }

  User copyWith({
    String? passwordHash,
    bool? active,
  }) {
    return User(
      userId: userId,
      registrationNumber: registrationNumber,
      name: name,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role,
      academicYear: academicYear,
      branch: branch,
      section: section,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'registrationNumber': registrationNumber,
      'name': name,
      'passwordHash': passwordHash,
      'role': role.name,
      'academicYear': academicYear,
      'branch': branch,
      'section': section,
      'active': active,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'] ?? '',
      registrationNumber: map['registrationNumber'] ?? '',
      name: map['name'] ?? '',
      passwordHash: map['passwordHash'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.faculty,
      ),
      academicYear: map['academicYear'],
      branch: map['branch'],
      section: map['section'],
      active: map['active'] ?? true,
    );
  }
}
