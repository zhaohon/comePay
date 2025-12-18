class ClaimCouponRequestModel {
  final String couponCode;

  ClaimCouponRequestModel({
    required this.couponCode,
  });

  factory ClaimCouponRequestModel.fromJson(Map<String, dynamic> json) {
    return ClaimCouponRequestModel(
      couponCode: json['coupon_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coupon_code': couponCode,
    };
  }
}
