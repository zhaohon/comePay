// 新的优惠券模型，对应 /coupons API
class NewCouponModel {
  final int id;
  final String code;
  final String name;
  final String type; // "fixed" 或其他类型
  final double value; // 优惠券值
  final double minFee; // 最小消费
  final double maxDiscount; // 最大折扣
  final String status; // "unused", "used", "expired"
  final DateTime validFrom;
  final DateTime validUntil;
  final DateTime assignedAt;
  final DateTime? usedAt;

  NewCouponModel({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.value,
    required this.minFee,
    required this.maxDiscount,
    required this.status,
    required this.validFrom,
    required this.validUntil,
    required this.assignedAt,
    this.usedAt,
  });

  factory NewCouponModel.fromJson(Map<String, dynamic> json) {
    return NewCouponModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'fixed',
      value: (json['value'] ?? 0).toDouble(),
      minFee: (json['min_fee'] ?? 0).toDouble(),
      maxDiscount: (json['max_discount'] ?? 0).toDouble(),
      status: json['status'] ?? 'unused',
      validFrom: DateTime.tryParse(json['valid_from'] ?? '') ?? DateTime.now(),
      validUntil:
          DateTime.tryParse(json['valid_until'] ?? '') ?? DateTime.now(),
      assignedAt:
          DateTime.tryParse(json['assigned_at'] ?? '') ?? DateTime.now(),
      usedAt:
          json['used_at'] != null ? DateTime.tryParse(json['used_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'type': type,
      'value': value,
      'min_fee': minFee,
      'max_discount': maxDiscount,
      'status': status,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'assigned_at': assignedAt.toIso8601String(),
      'used_at': usedAt?.toIso8601String(),
    };
  }

  // 判断是否已过期
  bool get isExpired {
    return status == 'expired' || DateTime.now().isAfter(validUntil);
  }

  // 判断是否已使用
  bool get isUsed {
    return status == 'used';
  }

  // 判断是否可用
  bool get isAvailable {
    return status == 'unused' &&
        DateTime.now().isAfter(validFrom) &&
        DateTime.now().isBefore(validUntil);
  }
}

// 优惠券列表响应模型
class NewCouponResponseModel {
  final String status;
  final int count;
  final List<NewCouponModel> coupons;

  NewCouponResponseModel({
    required this.status,
    required this.count,
    required this.coupons,
  });

  factory NewCouponResponseModel.fromJson(Map<String, dynamic> json) {
    final couponsData = json['coupons'] as List? ?? [];

    return NewCouponResponseModel(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
      coupons: couponsData
          .map((item) => NewCouponModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'count': count,
      'coupons': coupons.map((c) => c.toJson()).toList(),
    };
  }
}
