import 'package:Demo/core/base_viewmodel.dart';
import 'package:Demo/models/transaction_record_model.dart';
import 'package:Demo/services/transaction_record_service.dart';
import 'package:flutter/material.dart';
import 'package:Demo/main.dart';

/// ViewModel responsible for managing transaction record state and business logic.
/// Follows MVVM pattern and clean code principles with single responsibility.
class TransactionRecordViewModel extends BaseViewModel {
  final TransactionRecordService _transactionRecordService =
      TransactionRecordService();

  List<TransactionRecord> _transactionRecords = [];
  String? _errorMessage;

  /// Gets the list of transaction records
  List<TransactionRecord> get transactionRecords => _transactionRecords;

  /// Gets the current error message, if any
  String? get errorMessage => _errorMessage;

  /// Indicates if there's an error state
  bool get hasError => _errorMessage != null;

  /// Fetches transaction records from the service
  /// [page] - Page number for pagination (default: 1)
  /// [limit] - Number of records per page (default: 10)
  Future<void> fetchTransactionRecords({int page = 1, int limit = 10}) async {
    setBusy(true);
    _errorMessage = null; // Clear previous errors

    try {
      final response = await _transactionRecordService.fetchTransactionRecords(
        page: page,
        limit: limit,
      );
      _transactionRecords = response.data;
      notifyListeners();
    } catch (e) {
      // ⚠️ DO NOT manually handle 401 errors!
      // Let the BaseService interceptor handle token refresh automatically
      _errorMessage = 'Failed to load transaction records: ${e.toString()}';
      print('Error fetching transaction records: $e');
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  /// Clears the current error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Gets formatted transaction data for UI display
  /// Returns a list of maps containing display-friendly transaction information
  List<Map<String, dynamic>> get transactionDisplayData {
    return _transactionRecords.map((record) {
      final date = DateTime.parse(record.tradeTime);
      final formattedDate = '${date.day}/${date.month}/${date.year}';

      final isPositive = record.tradeTotal >= 0;
      final amount =
          '${record.currencyCode} ${record.tradeTotal.abs().toStringAsFixed(2)}';
      final description = record.merchantName;
      final type = isPositive ? 'Credit' : 'Debit';

      return {
        'amount': amount,
        'description': description,
        'date': formattedDate,
        'type': type,
        'isPositive': isPositive,
      };
    }).toList();
  }
}
