import 'package:flutter/material.dart';
import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/responses/coupon_model.dart';
import 'package:comecomepay/models/responses/new_coupon_model.dart';
import 'package:comecomepay/models/responses/pagination_model.dart';
import 'package:comecomepay/models/responses/claim_coupon_response_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/utils/service_locator.dart';

class CouponViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  // State variables
  List<CouponModel> _coupons = [];
  PaginationModel? _pagination;
  String? _errorMessage;
  bool _isLoadingMore = false;
  bool _hasMorePages = true;

  // Getters
  List<CouponModel> get coupons => _coupons;
  PaginationModel? get pagination => _pagination;
  String? get errorMessage => _errorMessage;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMorePages => _hasMorePages;
  bool get isLoading => busy;

  // Setters
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Business logic methods
  Future<void> getCoupons(String status, {bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (_isLoadingMore || !_hasMorePages) return;
      _isLoadingMore = true;
    } else {
      setBusy(true);
      _coupons.clear();
      _pagination = null;
      _hasMorePages = true;
    }

    _errorMessage = null;
    notifyListeners();

    try {
      final currentPage = isLoadMore ? (_pagination?.page ?? 1) + 1 : 1;
      final response =
          await _globalService.getMyCoupons(status, currentPage, 10);

      if (isLoadMore) {
        _coupons.addAll(response.coupons);
      } else {
        _coupons = response.coupons;
      }

      _pagination = response.pagination;

      // Check if there are more pages
      _hasMorePages = (_pagination?.page ?? 1) * (_pagination?.limit ?? 10) <
          (_pagination?.total ?? 0);

      if (isLoadMore) {
        _isLoadingMore = false;
      } else {
        setBusy(false);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      if (isLoadMore) {
        _isLoadingMore = false;
      } else {
        setBusy(false);
      }
      notifyListeners();
    }
  }

  // Method to refresh coupons
  Future<void> refreshCoupons(String status) async {
    await getCoupons(status, isLoadMore: false);
  }

  // Method to load more coupons
  Future<void> loadMoreCoupons(String status) async {
    await getCoupons(status, isLoadMore: true);
  }

  // Method to clear data
  void clearData() {
    _coupons.clear();
    _pagination = null;
    _errorMessage = null;
    _isLoadingMore = false;
    _hasMorePages = true;
    notifyListeners();
  }

  // Claim coupon states
  String? _claimError;
  bool _isClaiming = false;
  ClaimCouponResponseModel? _claimedCoupon;

  // Getters for claim states
  String? get claimError => _claimError;
  bool get isClaiming => _isClaiming;
  ClaimCouponResponseModel? get claimedCoupon => _claimedCoupon;

  // Clear claim error
  void clearClaimError() {
    _claimError = null;
    notifyListeners();
  }

  // Business logic for claiming coupon
  Future<void> claimCoupon(String couponCode) async {
    setBusy(true);
    _isClaiming = true;
    _claimError = null;
    _claimedCoupon = null;
    notifyListeners();

    try {
      final response = await _globalService.claimCoupon(couponCode);
      _claimedCoupon = response;
      _claimError = null;
      // Optionally refresh coupons after successful claim
      // await refreshCoupons('available');
    } catch (e) {
      _claimError = e.toString();
      _claimedCoupon = null;
    } finally {
      setBusy(false);
      _isClaiming = false;
      notifyListeners();
    }
  }

  // ========== 新的优惠券加载逻辑（使用 /coupons API） ==========
  List<NewCouponModel> _newCoupons = [];
  List<NewCouponModel> get newCoupons => _newCoupons;

  // 获取优惠券列表（新API）
  Future<void> loadNewCoupons({bool onlyValid = true}) async {
    setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _globalService.getCoupons(onlyValid: onlyValid);
      _newCoupons = response.coupons;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _newCoupons = [];
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // 按状态过滤优惠券
  List<NewCouponModel> getCouponsByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'unused':
        return _newCoupons.where((c) => c.isAvailable).toList();
      case 'used':
        return _newCoupons.where((c) => c.isUsed).toList();
      case 'expired':
        return _newCoupons.where((c) => c.isExpired).toList();
      default:
        return _newCoupons;
    }
  }

  // 刷新优惠券
  Future<void> refreshNewCoupons() async {
    await loadNewCoupons(onlyValid: false); // 加载所有优惠券以支持三个标签
  }
}
