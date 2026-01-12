import 'package:flutter/material.dart';
import '../services/referral_service.dart';
// Pagination & Filters (Simulated)
// int _currentPage = 1;
// int _totalPages = 1;

import '../utils/logger.dart';

class MyInvitationViewModel extends ChangeNotifier {
  final ReferralService _referralService = ReferralService();

  // Overview Stats
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> get stats => _stats;

  // Referrals List
  List<dynamic> _referrals = [];
  List<dynamic> get referrals => _referrals;

  // Commissions List
  List<dynamic> _commissions = [];
  List<dynamic> get commissions => _commissions;

  // Loading States
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isListLoading = false;
  bool get isListLoading => _isListLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Pagination & Filters
  int _currentPage = 1;
  // int _totalPages = 1;

  // Stats
  Future<void> loadStats() async {
    _setLoading(true);
    try {
      _stats = await _referralService.getReferralStats();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
      // Use mock data if API fails or is unimplemented (for UI demo)
      _stats = {
        'total_referrals': 3,
        'level1_referrals': 1,
        'level2_referrals': 2,
        'total_card_rebate': 1.1,
        'level1_card_rebate': 1,
        'level2_card_rebate': 0.1,
        'total_spending_rebate': 1.28,
        'level1_spending_rebate': 1.28,
        'level2_spending_rebate': 0,
      };
    } finally {
      _setLoading(false);
    }
  }

  // Load Referrals List
  Future<void> loadReferrals(
      {int level = 0, int page = 1, bool refresh = false}) async {
    if (loadingMore(refresh, page)) return;

    try {
      if (refresh) {
        _referrals = [];
        _currentPage = 1;
      }

      _setListLoading(true);

      final result =
          await _referralService.getReferrals(level: level, page: page);
      final List newItems = result['referrals'] ?? [];

      // Mock data if empty for demo
      if (newItems.isEmpty && page == 1) {
        if (level == 1 || level == 0) {
          _referrals.add({
            'email': '184***8064@qq.com',
            'is_card_activated': true,
            'has_physical_card': false,
            'created_at': '2025-05-08 10:22:30'
          });
        }
        if (level == 2 || level == 0) {
          _referrals.add({
            'email': 'test***user@qq.com',
            'is_card_activated': false,
            'has_physical_card': false,
            'created_at': '2025-06-01 12:00:00'
          });
          _referrals.add({
            'email': 'demo***002@qq.com',
            'is_card_activated': true,
            'has_physical_card': true,
            'created_at': '2025-06-02 14:00:00'
          });
        }
      } else {
        _referrals.addAll(newItems);
      }

      _currentPage = page;
      // Handle pagination properties if backend returns total pages...

      _errorMessage = '';
    } catch (e) {
      Logger.error('loadReferrals', '', e, StackTrace.current);
      _errorMessage = e.toString();
    } finally {
      _setListLoading(false);
    }
  }

  // Load Commissions
  // Type: 'card' or 'transaction' (spending)
  Future<void> loadCommissions(
      {String? type, int? level, int page = 1, bool refresh = false}) async {
    if (loadingMore(refresh, page)) return;

    try {
      if (refresh) {
        _commissions = [];
        _currentPage = 1;
      }
      _setListLoading(true);

      final result = await _referralService.getCommissions(
          type: type, level: level, page: page);
      final List newItems = result['commissions'] ?? [];

      // Mock Data
      if (newItems.isEmpty && page == 1) {
        // Mock data based on provided screenshots
        if (type == 'card') {
          _commissions.add({
            'source_user_email': '184***8064@qq.com',
            'type': 'card_opening',
            'amount': 5.0, // Fee
            'commission_amount': 1.0,
            'currency': 'USD',
            'created_at': '2025-05-08 13:18:54',
            'status': 'success' // '開卡'
          });
        } else if (type == 'transaction') {
          // Spending
          _commissions.add({
            'source_user_email': '184***8064@qq.com',
            'type': 'transaction',
            'amount': 218.4,
            'commission_amount': 0.11,
            'currency': 'HKD',
            'created_at': '2025-10-23 22:29:00',
            'status': 'success'
          });
          _commissions.add({
            'source_user_email': '184***8064@qq.com', // repeated for demo
            'type': 'transaction',
            'amount': 450.01,
            'commission_amount': 0.23,
            'currency': 'HKD',
            'created_at': '2025-09-28 21:21:50',
            'status': 'success'
          });
        }
      } else {
        _commissions.addAll(newItems);
      }

      _currentPage = page;
    } catch (e) {
      Logger.error('loadCommissions', '', e, StackTrace.current);
      _errorMessage = e.toString();
    } finally {
      _setListLoading(false);
    }
  }

  bool loadingMore(bool refresh, int page) {
    if (refresh) return false;
    if (_isListLoading) return true;
    // Simple check to prevent infinite load if empty
    // Real implementation needs total_pages from API
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setListLoading(bool value) {
    _isListLoading = value;
    notifyListeners();
  }
}
