class UserCouponModel {
  final int id;
  final String status;
  final DateTime assignedAt;

  UserCouponModel({
    required this.id,
    required this.status,
    required this.assignedAt,
  });

  factory UserCouponModel.fromJson(Map<String, dynamic> json) {
    return UserCouponModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      assignedAt: DateTime.tryParse(json['assigned_at'] ?? '') ?? DateTime(1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'assigned_at': assignedAt.toIso8601String(),
    };
  }
}
