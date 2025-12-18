class CouponDetailModel {
  final int id;
  final String code;
  final String name;
  final String description;
  final String valueType;
  final double value;
  final double minTransactionAmount;
  final double maxDiscount;
  final int usageLimit;
  final int usageLimitPerUser;
  final int usedCount;
  final String status;
  final DateTime expiresAt;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  CouponDetailModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.valueType,
    required this.value,
    required this.minTransactionAmount,
    required this.maxDiscount,
    required this.usageLimit,
    required this.usageLimitPerUser,
    required this.usedCount,
    required this.status,
    required this.expiresAt,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CouponDetailModel.fromJson(Map<String, dynamic> json) {
    return CouponDetailModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      valueType: json['value_type'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      minTransactionAmount: (json['min_transaction_amount'] ?? 0).toDouble(),
      maxDiscount: (json['max_discount'] ?? 0).toDouble(),
      usageLimit: json['usage_limit'] ?? 0,
      usageLimitPerUser: json['usage_limit_per_user'] ?? 0,
      usedCount: json['used_count'] ?? 0,
      status: json['status'] ?? '',
      expiresAt: DateTime.tryParse(json['expires_at'] ?? '') ?? DateTime(1),
      createdBy: json['created_by'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime(1),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime(1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'value_type': valueType,
      'value': value,
      'min_transaction_amount': minTransactionAmount,
      'max_discount': maxDiscount,
      'usage_limit': usageLimit,
      'usage_limit_per_user': usageLimitPerUser,
      'used_count': usedCount,
      'status': status,
      'expires_at': expiresAt.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
