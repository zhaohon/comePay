class CouponErrorModel {
  final String error;

  CouponErrorModel({
    required this.error,
  });

  factory CouponErrorModel.fromJson(Map<String, dynamic> json) {
    return CouponErrorModel(
      error: json['error'] ?? 'Unknown error',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
    };
  }
}
