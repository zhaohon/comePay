import 'package:flutter/material.dart';
import 'package:Demo/models/three_ds_record_model.dart';
import 'package:Demo/services/three_ds_service.dart';

class CardAuthorizationViewModel extends ChangeNotifier {
  final ThreeDSService _service = ThreeDSService();

  List<ThreeDSRecordModel> _records = [];
  List<ThreeDSRecordModel> get records => _records;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  int _currentPage = 1;
  int _totalPages = 1;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get hasMore => _currentPage < _totalPages;

  // Initial load or refresh
  Future<void> loadRecords({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _records.clear();
      _errorMessage = null; // Clear error on refresh
    } else {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await _service.getMyRecords(page: _currentPage);

      _records = response.records;
      _totalPages = response.totalPages;
      _currentPage = response.page;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error loading 3DS records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load next page
  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _service.getMyRecords(page: nextPage);

      _records.addAll(response.records);
      _currentPage = response.page;
      _totalPages = response.totalPages;
    } catch (e) {
      print('Error loading more 3DS records: $e');
      // Optionally set an error message specifically for load more,
      // or just show a snackbar in the UI
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
