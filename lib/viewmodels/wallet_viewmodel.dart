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

  Map<String, double> _balancesByCurrency = {};
  Map<String, double> get balancesByCurrency => _balancesByCurrency;

  // 保持兼容性
  Map<String, dynamic> get listAssets {
    return _balancesByCurrency.map((key, value) => MapEntry(key, value));
  }

  double _totalAssets = 0.0;
  double get totalAssets => _totalAssets;

  double _displayValue = 0.0;
  double get displayValue => _displayValue;

  // 返回空列表以保持兼容性
  List<AvailableCurrency> get availableCurrenciesList => [];

  List<WalletBalance> get balances => _walletResponse?.wallet.balances ?? [];

  // 获取 HKD 和 USDT 总资产
  double get totalAssetHkd => _walletResponse?.wallet.totalAssetHkd ?? 0.0;
  double get totalAssetUsdt => _walletResponse?.wallet.totalAssetUsdt ?? 0.0;

  Future<void> fetchWalletData() async {
    setBusy(true);
    try {
      final user = HiveStorageService.getUser();
      if (user == null) {
        print('❌ WalletViewModel: User not found');
        throw Exception('User not found');
      }

      print('🔄 WalletViewModel: Fetching wallet data for user ${user.id}');
      _walletResponse = await _walletService.getWalletById(user.id);

      print('✅ WalletViewModel: Received wallet response');
      print('   Balances count: ${_walletResponse!.wallet.balances.length}');

      // 将balances数组转换为Map
      _balancesByCurrency = {};
      for (var balance in _walletResponse!.wallet.balances) {
        _balancesByCurrency[balance.currency] = balance.balance;
        print('   ${balance.currency}: ${balance.balance}');
      }

      // 计算总资产
      _totalAssets =
          _balancesByCurrency.values.fold(0.0, (sum, value) => sum + value);
      print('   Total assets: $_totalAssets');

      // 默认选择第一个货币
      if (_walletResponse!.wallet.balances.isNotEmpty) {
        _selectedCurrency = _walletResponse!.wallet.balances[0].currency;
        _displayValue = _walletResponse!.wallet.balances[0].balance;
        print('   Selected currency: $_selectedCurrency = $_displayValue');
      } else {
        _selectedCurrency = 'USD';
        _displayValue = 0.0;
        print('   No balances found, using defaults');
      }

      setBusy(false);
      notifyListeners();
    } catch (e, stackTrace) {
      setBusy(false);
      notifyListeners();
      // 不重新抛出异常，让UI继续显示
    }
  }

  void selectCurrency(String currency) {
    _selectedCurrency = currency;
    _displayValue = _balancesByCurrency[currency] ?? 0.0;
    notifyListeners();
  }

  String getFormattedBalance() {
    if (busy || _walletResponse == null) return "****";
    return _displayValue.toStringAsFixed(2);
  }
}
