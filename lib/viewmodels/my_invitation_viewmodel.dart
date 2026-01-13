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
      _stats = {};
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

      _referrals.addAll(newItems);

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

      String? apiType;
      if (type == 'card') {
        apiType = 'card_opening';
      } else if (type == 'transaction') {
        apiType = 'transaction';
      }

      final result = await _referralService.getCommissions(
          type: apiType, level: level, page: page);
      final List newItems = result['commissions'] ?? [];

      _commissions.addAll(newItems);

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
