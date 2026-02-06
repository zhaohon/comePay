import 'package:Demo/core/base_viewmodel.dart';
import 'package:Demo/models/unified_transaction_model.dart';
import 'package:Demo/services/unified_transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:Demo/main.dart';

/// ViewModel responsible for managing unified transaction record state and business logic.
/// Follows MVVM pattern and clean code principles with single responsibility.
class UnifiedTransactionViewModel extends BaseViewModel {
  final UnifiedTransactionService _service = UnifiedTransactionService();

  List<UnifiedTransaction> _transactions = [];
  List<UnifiedTransaction> _latestTransactions = [];
  String? _errorMessage;

  // 分页相关
  int _currentPage = 1;
  int _pageSize = 20;
  int _totalPages = 0;
  int _total = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  /// Gets the list of all transactions
  List<UnifiedTransaction> get transactions => _transactions;

  /// Gets the latest transactions (for home screen)
  List<UnifiedTransaction> get latestTransactions => _latestTransactions;

  /// Gets the current error message, if any
  String? get errorMessage => _errorMessage;

  /// Indicates if there's an error state
  bool get hasError => _errorMessage != null;

  /// Gets current page number
  int get currentPage => _currentPage;

  /// Gets total number of pages
  int get totalPages => _totalPages;

  /// Gets total number of records
  int get total => _total;

  /// Indicates if there are more pages to load
  bool get hasMore => _hasMore;

  /// Indicates if currently loading more data
  bool get isLoadingMore => _isLoadingMore;

  /// Indicates if currently loading (for UI state)
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  /// Fetches the latest transactions (用于首页显示)
  /// [limit] - Number of latest records to fetch (default: 10)
  Future<void> fetchLatestTransactions({int limit = 10}) async {
    setBusy(true);
    _errorMessage = null;

    try {
      _latestTransactions =
          await _service.fetchLatestTransactions(limit: limit);
      notifyListeners();
    } catch (e) {
      _handleError(e);
    } finally {
      setBusy(false);
    }
  }

  /// Fetches unified transaction records from the service
  /// [page] - Page number for pagination (default: 1)
  /// [pageSize] - Number of records per page (default: 20)
  /// [type] - Filter by transaction type (optional)
  /// [status] - Filter by transaction status (optional)
  /// [refresh] - If true, clears existing data before loading (用于下拉刷新)
  Future<void> fetchTransactions({
    int? page,
    int? pageSize,
    String? type,
    String? status,
    bool refresh = false,
  }) async {
    // 如果是刷新操作，重置所有分页状态
    if (refresh) {
      _currentPage = 1;
      _transactions.clear();
      setBusy(true);
    }

    _errorMessage = null;
    final targetPage = page ?? _currentPage;
    final targetPageSize = pageSize ?? _pageSize;

    try {
      final response = await _service.fetchUnifiedTransactions(
        page: targetPage,
        pageSize: targetPageSize,
        type: type,
        status: status,
      );

      if (refresh) {
        // 刷新操作：替换所有数据
        _transactions = response.data.items;
      } else {
        // 加载更多：追加数据
        _transactions.addAll(response.data.items);
      }

      // 更新分页信息
      _currentPage = response.data.page;
      _pageSize = response.data.pageSize;
      _totalPages = response.data.totalPages;
      _total = response.data.total;
      _hasMore = response.data.hasMore;

      notifyListeners();
    } catch (e) {
      _handleError(e);
    } finally {
      if (refresh) {
        setBusy(false);
      }
    }
  }

  /// Loads more transactions (用于上拉加载更多)
  Future<void> loadMore({String? type, String? status}) async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _service.fetchUnifiedTransactions(
        page: nextPage,
        pageSize: _pageSize,
        type: type,
        status: status,
      );

      _transactions.addAll(response.data.items);
      _currentPage = response.data.page;
      _totalPages = response.data.totalPages;
      _total = response.data.total;
      _hasMore = response.data.hasMore;

      notifyListeners();
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Refreshes the transaction list (用于下拉刷新)
  Future<void> refresh({String? type, String? status}) async {
    await fetchTransactions(
      page: 1,
      type: type,
      status: status,
      refresh: true,
    );
  }

  /// Handles errors from API calls
  void _handleError(dynamic e) {
    // ⚠️ DO NOT manually handle 401/Unauthorized errors here!
    // The BaseService interceptor will automatically handle token refresh
    // Only handle other types of errors
    _errorMessage = 'Failed to load transactions: ${e.toString()}';
    print('Error fetching transactions: $e');
    notifyListeners();
  }

  /// Clears the current error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Resets all state (用于退出登录等场景)
  void reset() {
    _transactions.clear();
    _latestTransactions.clear();
    _errorMessage = null;
    _currentPage = 1;
    _totalPages = 0;
    _total = 0;
    _hasMore = true;
    _isLoadingMore = false;
    notifyListeners();
  }
}
