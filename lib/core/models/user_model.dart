import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String name;
  final String email;
  final String mobile;
  final String role;
  final String societyId;
  final String? flatNo;
  final String? flatType;
  final String? block;
  final bool isActive;
  final String? createdBy; // mobile/email of the admin/super_admin who created this user
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.name,
    required String email,
    required this.mobile,
    required this.role,
    required this.societyId,
    this.flatNo,
    this.flatType,
    this.block,
    this.isActive = true,
    this.createdBy,
    this.createdAt,
  }) : email = email.toLowerCase();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'role': role,
      'society_id': societyId,
      'flat_no': flatNo,
      'flat_type': flatType,
      'block': block,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: (map['email'] ?? '').toString().toLowerCase(),
      mobile: map['mobile'] ?? '',
      role: map['role'] ?? '',
      societyId: map['society_id'] ?? '',
      flatNo: map['flat_no'],
      flatType: map['flat_type'],
      block: map['block'],
      isActive: map['is_active'] ?? true,
      createdBy: map['created_by'],
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    String? role,
    String? societyId,
    String? flatNo,
    String? flatType,
    String? block,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      role: role ?? this.role,
      societyId: societyId ?? this.societyId,
      flatNo: flatNo ?? this.flatNo,
      flatType: flatType ?? this.flatType,
      block: block ?? this.block,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
