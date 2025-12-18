import 'coupon_detail_model.dart';
import 'user_coupon_model.dart';

class ClaimCouponResponseModel {
  final String status;
  final String message;
  final CouponDetailModel coupon;
  final UserCouponModel userCoupon;

  ClaimCouponResponseModel({
    required this.status,
    required this.message,
    required this.coupon,
    required this.userCoupon,
  });

  factory ClaimCouponResponseModel.fromJson(Map<String, dynamic> json) {
    return ClaimCouponResponseModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      coupon: CouponDetailModel.fromJson(json['coupon'] ?? {}),
      userCoupon: UserCouponModel.fromJson(json['user_coupon'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'coupon': coupon.toJson(),
      'user_coupon': userCoupon.toJson(),
    };
  }
}
