import 'package:cloud_firestore/cloud_firestore.dart';

class SocietyModel {
  final String? id;
  final String name;
  final String address;
  final String? totalFlats;
  final String status; // 'active', 'inactive', 'pending'
  final DateTime? createdAt;

  SocietyModel({
    this.id,
    required this.name,
    required this.address,
    this.totalFlats,
    this.status = 'active',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'total_flats': totalFlats,
      'status': status,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory SocietyModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SocietyModel(
      id: documentId,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      totalFlats: map['total_flats'],
      status: map['status'] ?? 'active',
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
    );
  }
}
