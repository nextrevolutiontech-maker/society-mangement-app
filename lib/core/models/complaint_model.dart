class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final String residentName;
  final String flatNumber;
  final String residentId;
  final String societyId;
  final String status; // Open | In Progress | Resolved
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? inProgressAt;
  final DateTime? resolvedAt;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.residentName,
    required this.flatNumber,
    required this.residentId,
    required this.societyId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.inProgressAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'residentName': residentName,
      'flatNumber': flatNumber,
      'residentId': residentId,
      'societyId': societyId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'inProgressAt': inProgressAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> map, String docId) {
    return ComplaintModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      residentName: map['residentName'] ?? '',
      flatNumber: map['flatNumber'] ?? '',
      residentId: map['residentId'] ?? '',
      societyId: map['societyId'] ?? '',
      status: map['status'] ?? 'Open',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
      inProgressAt: map['inProgressAt'] != null ? DateTime.tryParse(map['inProgressAt']) : null,
      resolvedAt: map['resolvedAt'] != null ? DateTime.tryParse(map['resolvedAt']) : null,
    );
  }
}
