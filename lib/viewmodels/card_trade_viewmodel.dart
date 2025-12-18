import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/card_trade_model.dart';
import 'package:comecomepay/services/card_trade_service.dart';

class CardTradeViewModel extends BaseViewModel {
  final CardTradeService _cardTradeService = CardTradeService();

  List<CardTrade> _cardTrades = [];
  String? _errorMessage;
  int _currentPage = 1;
  int _totalTrades = 0;
  bool _hasMoreData = true;

  List<CardTrade> get cardTrades => _cardTrades;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasMoreData => _hasMoreData;
  int get totalTrades => _totalTrades;

  Future<void> fetchCardTrades({
    required String publicToken,
    bool isLoadMore = false,
    int limit = 10,
  }) async {
    if (isLoadMore && !_hasMoreData) return;

    setBusy(true);
    _errorMessage = null;

    try {
      final response = await _cardTradeService.fetchCardTrades(
        publicToken: publicToken,
        page: isLoadMore ? _currentPage + 1 : 1,
        limit: limit,
      );

      if (isLoadMore) {
        _cardTrades.addAll(response.data.trades);
        _currentPage++;
      } else {
        _cardTrades = response.data.trades;
        _currentPage = 1;
      }

      _totalTrades = response.data.total;
      _hasMoreData = _cardTrades.length < _totalTrades;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load card trades: ${e.toString()}';
      print('Error fetching card trades: $e');
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetData() {
    _cardTrades.clear();
    _currentPage = 1;
    _totalTrades = 0;
    _hasMoreData = true;
    _errorMessage = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> get tradeDisplayData {
    return _cardTrades.map((trade) {
      final date = DateTime.parse(trade.tradeTime);
      final formattedDate = '${date.day}/${date.month}/${date.year}';

      final isPositive = trade.tradeTotal >= 0;
      final amount = '${trade.currencyCode} ${trade.tradeTotal.abs().toStringAsFixed(2)}';
      final description = trade.merchantName;
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
