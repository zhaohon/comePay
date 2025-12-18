import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/responses/card_response_model.dart' as card_response;
import 'package:comecomepay/models/responses/transaction_response_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';

class CardViewModel extends BaseViewModel {
  final GlobalService _globalService = GlobalService();

  card_response.CardResponseModel? _cardResponse;
  card_response.CardResponseModel? get cardResponse => _cardResponse;

  List<String> _availableCurrencies = [];
  List<String> get availableCurrencies => _availableCurrencies;

  String _selectedCurrency = "USD";
  String get selectedCurrency => _selectedCurrency;

  double _currentBalance = 0.0;
  double get currentBalance => _currentBalance;

  TransactionResponse? _transactionResponse;
  TransactionResponse? get transactionResponse => _transactionResponse;

  Future<void> fetchCardData() async {
    setBusy(true);
    try {
      final user = HiveStorageService.getUser();
      if (user == null) {
        throw Exception('User not found');
      }

      _cardResponse = await _globalService.getCardData(user.id.toString());
      _populateCurrencies();
      _updateBalance();
      notifyListeners();
      setBusy(false);
    } catch (e) {
      setBusy(false);
      throw e;
    }
  }

  void _populateCurrencies() {
    if (_cardResponse?.data.isNotEmpty ?? false) {
      final currencies = <String>{};
      for (final card in _cardResponse!.data) {
        currencies.add(card.currencyCode);
        currencies.add(card.convertedCurrencyCode);
      }
      _availableCurrencies = currencies.toList();
      if (!_availableCurrencies.contains(_selectedCurrency)) {
        _selectedCurrency = _availableCurrencies.first;
      }
    }
  }

  void _updateBalance() {
    if (_cardResponse?.data.isNotEmpty ?? false) {
      double totalBalance = 0.0;
      for (final card in _cardResponse!.data) {
        if (_selectedCurrency == card.currencyCode) {
          totalBalance += card.balance;
        } else if (_selectedCurrency == card.convertedCurrencyCode) {
          totalBalance += card.convertedBalance;
        }
      }
      _currentBalance = totalBalance;
    }
  }

  void selectCurrency(String currency) {
    _selectedCurrency = currency;
    _updateBalance();
    notifyListeners();
  }

  String getFormattedBalance() {
    if (busy || _cardResponse == null) return "****";
    return _currentBalance.toStringAsFixed(2);
  }

  Future<void> fetchTransactionData() async {
    setBusy(true);
    try {
      final user = HiveStorageService.getUser();
      if (user == null) {
        throw Exception('User not found');
      }

      _transactionResponse = await _globalService.getTransactionData(user.id.toString());
      setBusy(false);
    } catch (e) {
      setBusy(false);
      throw e;
    }
  }
}
