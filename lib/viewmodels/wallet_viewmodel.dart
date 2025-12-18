import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/wallet_model.dart';
import 'package:comecomepay/services/wallet_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';

class WalletViewModel extends BaseViewModel {
  final WalletService _walletService = WalletService();

  WalletResponse? _walletResponse;
  WalletResponse? get walletResponse => _walletResponse;

  String _selectedCurrency = 'USD';
  String get selectedCurrency => _selectedCurrency;

  Map<String, dynamic> _listAssets = {};
  Map<String, dynamic> get listAssets => _listAssets;

  double _totalAssets = 0.0;
  double get totalAssets => _totalAssets;

  double _displayValue = 0.0;
  double get displayValue => _displayValue;

  List<AvailableCurrency> get availableCurrenciesList =>
      _walletResponse?.data.availableCurrencies ?? [];

  Future<void> fetchWalletData() async {
    setBusy(true);
    try {
      final user = HiveStorageService.getUser();
      if (user == null) {
        throw Exception('User not found');
      }

      _walletResponse = await _walletService.getWalletById(user.id);
      _listAssets = _walletResponse!.data.listAssets;
      _totalAssets = _walletResponse!.data.totalAssets;
      _selectedCurrency = _walletResponse!.data.defaultCurrency;
      _displayValue = _totalAssets; // Initially show total_assets

      notifyListeners();
      setBusy(false);
    } catch (e) {
      setBusy(false);
      throw e;
    }
  }

  void selectCurrency(String currency) {
    _selectedCurrency = currency;
    // Update display value to the selected currency's value from list_assets
    final value = _listAssets[currency];
    if (value is num) {
      _displayValue = value.toDouble();
    } else if (value is String) {
      _displayValue = double.tryParse(value) ?? 0.0;
    } else {
      _displayValue = 0.0;
    }
    notifyListeners();
  }

  String getFormattedBalance() {
    if (busy || _walletResponse == null) return "****";
    return _displayValue.toStringAsFixed(2);
  }
}
