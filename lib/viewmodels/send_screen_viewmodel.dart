import 'package:flutter/material.dart';
import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/wallet_model.dart';
import 'package:comecomepay/services/wallet_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';

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

    final wallets = _walletResponse!.data.wallets;
    final availableCurrencies = _walletResponse!.data.availableCurrencies;

    for (var wallet in wallets) {
      // Add native token for the chain
      final nativeBalance =
          _getNativeBalance(wallet.chain, availableCurrencies);
      _tokens.add({
        'name': _getNameForChain(wallet.chain),
        'symbol': wallet.chain,
        'chain': '',
        'icon': _icons[wallet.chain] ?? Icons.help,
        'color': _colors[wallet.chain] ?? Colors.black,
        'networks': [wallet.chain],
        'balance': nativeBalance,
        'usdBalance': '****', // Placeholder, as no USD conversion
      });

      // Add tokens for each non-null token_address
      wallet.tokenAddresses.forEach((symbol, address) {
        if (address != null) {
          final tokenBalance =
              _getTokenBalance(wallet.chain, symbol, availableCurrencies);
          _tokens.add({
            'name': symbol,
            'symbol': symbol,
            'chain': wallet.chain,
            'icon': _icons[symbol] ?? Icons.attach_money,
            'color': _colors[symbol] ?? Colors.green,
            'networks': ['${wallet.chain} ${symbol}'], // e.g., "ETH USDT"
            'balance': tokenBalance,
            'usdBalance': '****',
          });
        }
      });
    }
  }

  String _getNameForChain(String chain) {
    switch (chain) {
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
      default:
        return chain;
    }
  }

  String _getNativeBalance(
      String chain, List<AvailableCurrency> availableCurrencies) {
    final currency = availableCurrencies.firstWhere(
      (c) => c.chain == chain,
      orElse: () => AvailableCurrency(
        id: 0,
        chain: '',
        address: '',
        native: '0',
        token: {},
        tenantId: '',
        createdAt: '',
        updatedAt: '',
      ),
    );
    return currency.native;
  }

  String _getTokenBalance(String chain, String symbol,
      List<AvailableCurrency> availableCurrencies) {
    final currency = availableCurrencies.firstWhere(
      (c) => c.chain == chain,
      orElse: () => AvailableCurrency(
        id: 0,
        chain: '',
        address: '',
        native: '0',
        token: {},
        tenantId: '',
        createdAt: '',
        updatedAt: '',
      ),
    );
    return (currency.token[symbol] ?? '0').toString();
  }
}
