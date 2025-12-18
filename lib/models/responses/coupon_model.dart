import 'user_model.dart';
import 'coupon_detail_model.dart';

class CouponModel {
  final int id;
  final int userId;
  final int couponId;
  final String status;
  final bool isUsed;
  final DateTime? usedAt;
  final DateTime assignedAt;
  final bool notificationSent;
  final String source;
  final int usageCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel user;
  final CouponDetailModel coupon;

  CouponModel({
    required this.id,
    required this.userId,
    required this.couponId,
    required this.status,
    required this.isUsed,
    this.usedAt,
    required this.assignedAt,
    required this.notificationSent,
    required this.source,
    required this.usageCount,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.coupon,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      couponId: json['coupon_id'] ?? 0,
      status: json['status'] ?? '',
      isUsed: json['is_used'] ?? false,
      usedAt:
          json['used_at'] != null ? DateTime.tryParse(json['used_at']) : null,
      assignedAt: DateTime.tryParse(json['assigned_at'] ?? '') ?? DateTime(1),
      notificationSent: json['notification_sent'] ?? false,
      source: json['source'] ?? '',
      usageCount: json['usage_count'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime(1),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime(1),
      user: UserModel.fromJson(json['user'] ?? {}),
      coupon: CouponDetailModel.fromJson(json['coupon'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'coupon_id': couponId,
      'status': status,
      'is_used': isUsed,
      'used_at': usedAt?.toIso8601String(),
      'assigned_at': assignedAt.toIso8601String(),
      'notification_sent': notificationSent,
      'source': source,
      'usage_count': usageCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user.toJson(),
      'coupon': coupon.toJson(),
    };
  }
}
