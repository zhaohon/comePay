import 'coupon_model.dart';
import 'pagination_model.dart';

class CouponResponseModel {
  final List<CouponModel> coupons;
  final PaginationModel pagination;

  CouponResponseModel({
    required this.coupons,
    required this.pagination,
  });

  factory CouponResponseModel.fromJson(Map<String, dynamic> json) {
    return CouponResponseModel(
      coupons: (json['coupons'] as List<dynamic>?)
              ?.map((e) => CouponModel.fromJson(e))
              .toList() ??
          [],
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coupons': coupons.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
