import 'package:Demo/core/base_viewmodel.dart';
import 'package:Demo/models/transaction_record_model.dart';
import 'package:Demo/services/transaction_record_service.dart';

class TransactionHistoryViewModel extends BaseViewModel {
  final TransactionRecordService _transactionRecordService =
      TransactionRecordService();

  List<TransactionRecord> _transactions = [];
  List<TransactionRecord> get transactions => _transactions;

  int _currentPage = 1;
  int _limit = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> fetchTransactionHistory({bool loadMore = false}) async {
    if (loadMore && !_hasMore) return;

    if (loadMore) {
      _isLoadingMore = true;
    } else {
      setBusy(true);
      _transactions.clear();
      _currentPage = 1;
      _hasMore = true;
    }

    notifyListeners();

    try {
      final response = await _transactionRecordService.fetchTransactionRecords(
        page: loadMore ? _currentPage : 1,
        limit: _limit,
      );

      if (loadMore) {
        _transactions.addAll(response.data);
      } else {
        _transactions = response.data;
      }

      if (response.data.length < _limit) {
        _hasMore = false;
      } else {
        _currentPage++;
      }

      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error fetching transaction records: $e');
      _hasMore = false;
      notifyListeners();
    } finally {
      if (loadMore) {
        _isLoadingMore = false;
      } else {
        setBusy(false);
      }
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get transactionDisplayData {
    return _transactions.map((record) {
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
        'isSent': !isPositive, // For backward compatibility with UI
      };
    }).toList();
  }
}
