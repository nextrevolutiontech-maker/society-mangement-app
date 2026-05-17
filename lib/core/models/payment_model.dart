import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String? id;
  final String userId;
  final String userName;
  final String flatNumber;
  final String flatType; // Added
  final String societyId;
  final String month;
  final int year; // Added
  final double amount;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final String? paymentMode; // 'UPI', 'Bank Transfer', 'Cash', 'Other'
  final String? proofUrl;
  final String? adminRemarks;
  final String? residentNote; // Added
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final double? paidAmount;
  final double? dueAmount;
  final DateTime? updatedAt;

  PaymentModel({
    this.id,
    required this.userId,
    required this.userName,
    required this.flatNumber,
    required this.flatType,
    required this.societyId,
    required this.month,
    required this.year,
    required this.amount,
    this.paidAmount,
    this.dueAmount,
    required this.status,
    this.paymentMode,
    this.proofUrl,
    this.adminRemarks,
    this.residentNote,
    required this.createdAt,
    this.updatedAt,
    this.approvedAt,
    this.approvedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'flatNumber': flatNumber,
      'flatType': flatType,
      'societyId': societyId,
      'month': month,
      'year': year,
      'amount': amount,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'status': status,
      'paymentMode': paymentMode,
      'proofUrl': proofUrl,
      'adminRemarks': adminRemarks,
      'residentNote': residentNote,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : Timestamp.fromDate(DateTime.now()),
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
      flatType: map['flatType'] ?? '',
      societyId: map['societyId'] ?? '',
      month: map['month'] ?? '',
      year: map['year'] ?? DateTime.now().year,
      amount: (map['amount'] ?? 0.0).toDouble(),
      paidAmount: map['paidAmount'] != null ? (map['paidAmount'] as num).toDouble() : null,
      dueAmount: map['dueAmount'] != null ? (map['dueAmount'] as num).toDouble() : null,
      status: map['status'] ?? 'Pending',
      paymentMode: map['paymentMode'],
      proofUrl: map['proofUrl'],
      adminRemarks: map['adminRemarks'],
      residentNote: map['residentNote'],
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
      approvedAt: map['approvedAt'] != null ? (map['approvedAt'] as Timestamp).toDate() : null,
      approvedBy: map['approvedBy'],
    );
  }
}
