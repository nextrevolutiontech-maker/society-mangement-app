import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String? id;
  final String userId;
  final String userName;
  final String flatNumber;
  final String societyId;
  final String month;
  final double amount;
  final String status; // 'Pending', 'Approved'
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  PaymentModel({
    this.id,
    required this.userId,
    required this.userName,
    required this.flatNumber,
    required this.societyId,
    required this.month,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'flatNumber': flatNumber,
      'societyId': societyId,
      'month': month,
      'amount': amount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'approvedBy': approvedBy,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map, String docId) {
    return PaymentModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown',
      flatNumber: map['flatNumber'] ?? '',
      societyId: map['societyId'] ?? '',
      month: map['month'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      approvedAt: map['approvedAt'] != null ? (map['approvedAt'] as Timestamp).toDate() : null,
      approvedBy: map['approvedBy'],
    );
  }
}
