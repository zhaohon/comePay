import 'package:flutter/material.dart';
import 'package:Demo/core/base_viewmodel.dart';
import 'package:Demo/models/wallet_model.dart';
import 'package:Demo/services/wallet_service.dart';
import 'package:Demo/services/hive_storage_service.dart';

class SendScreenViewModel extends BaseViewModel {
  final WalletService _walletService = WalletService();

  List<Map<String, dynamic>> _tokens = [];
  List<Map<String, dynamic>> get tokens => _tokens;

  WalletResponse? _walletResponse;

  // Maps for icons and colors based on symbol
  final Map<String, IconData> _icons = {
    'BTC': Icons.currency_bitcoin,
    'ETH': Icons.token,
    'USDT': Icons.attach_money,
    'USDC': Icons.account_balance_wallet,
    'BNB': Icons.circle,
    'MATIC': Icons.account_balance,
    'BASE': Icons.foundation,
    'TRX': Icons.flash_on,
    'SOL': Icons.wb_sunny,
  };

  final Map<String, Color> _colors = {
    'BTC': Colors.orange,
    'ETH': Colors.blue,
    'USDT': Colors.green,
    'USDC': Colors.teal,
    'BNB': Colors.yellow,
    'MATIC': Colors.purple,
    'BASE': Colors.grey,
    'TRX': Colors.red,
    'SOL': Colors.amber,
  };

  Future<void> fetchTokens() async {
    setBusy(true);
    try {
      final user = HiveStorageService.getUser();
      if (user == null) {
        throw Exception('User not found');
      }

      _walletResponse = await _walletService.getWalletById(user.id);
      _buildTokensFromWallets();
      notifyListeners();
    } catch (e) {
      // Handle error, perhaps set an error message
      print('Error fetching tokens: $e');
    } finally {
      setBusy(false);
    }
  }

  void _buildTokensFromWallets() {
    _tokens.clear();
    if (_walletResponse == null) return;

    final balances = _walletResponse!.wallet.balances;

    for (var balance in balances) {
      _tokens.add({
        'name': _getNameForCurrency(balance.currency),
        'symbol': balance.currency,
        'chain': balance.currency,
        'icon': _icons[balance.currency] ?? Icons.attach_money,
        'color': _colors[balance.currency] ?? Colors.green,
        'networks': [balance.currency],
        'balance': balance.balance.toString(),
        'usdBalance': '****', // Placeholder, as no USD conversion
      });
    }
  }

  String _getNameForCurrency(String currency) {
    switch (currency) {
      case 'BTC':
        return 'Bitcoin';
      case 'ETH':
        return 'Ethereum';
      case 'BNB':
        return 'Binance Coin';
      case 'MATIC':
        return 'Polygon';
      case 'BASE':
        return 'Base';
      case 'TRX':
        return 'Tron';
      case 'SOL':
        return 'Solana';
      case 'USD':
        return 'US Dollar';
      case 'USDT':
        return 'Tether';
      case 'USDC':
        return 'USD Coin';
      default:
        return currency;
    }
  }
}
