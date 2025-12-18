import 'package:flutter/material.dart';
import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/viewmodels/crypto_viewmodel.dart';
import 'package:comecomepay/models/responses/crypto_response_model.dart';

class TokenReceiveViewModel extends BaseViewModel {
  final CryptoViewModel _cryptoViewModel = CryptoViewModel();

  List<CryptoResponse> _cryptoData = [];
  List<CryptoResponse> get cryptoData => _cryptoData;

  List<Map<String, dynamic>> _tokens = [];
  List<Map<String, dynamic>> get tokens => _tokens;

  List<Map<String, dynamic>> _filteredTokens = [];
  List<Map<String, dynamic>> get filteredTokens => _filteredTokens;

  double _totalAssets = 0.0;
  double get totalAssets => _totalAssets;

  Future<void> fetchCryptoData() async {
    setBusy(true);
    try {
      await _cryptoViewModel.fetchCryptoData();
      _cryptoData = _cryptoViewModel.cryptoData;
      _processTokensFromCrypto();
      _filteredTokens = _tokens;
      notifyListeners();
      setBusy(false);
    } catch (e) {
      setBusy(false);
      rethrow;
    }
  }

  void _processTokensFromCrypto() {
    // 根据接口返回的币种，手动组织接收页需要展示的“网络列表”
    final Map<String, CryptoResponse> bySymbol = {
      for (final c in _cryptoData) c.symbol.toLowerCase(): c,
    };

    CryptoResponse? _get(String symbol) {
      return bySymbol[symbol.toLowerCase()];
    }

    _tokens = [];

    void addToken({
      required CryptoResponse? crypto,
      required String displaySymbol,
      required String walletChain, // 用于匹配后端钱包的 chain 字段 (BTC/ETH/BNB/MATIC/BASE/TRX/SOL)
      required String networkLabel, // 用于界面显示 (ERC20/TRC20...)
      required String iconPath,
      String? tokenAddressKey, // 用于在 tokenAddresses 里取地址 (USDT/USDC)
    }) {
      if (crypto == null) return;

      final Color color = _getCryptoColor(walletChain.toLowerCase());
      _tokens.add({
        "name": crypto.name,
        "symbol": displaySymbol,
        "chain": walletChain, // 给详情页去匹配 Wallet.chain
        "iconPath": iconPath,
        "image": crypto.image,
        "color": color,
        "networks": [networkLabel],
        // balance / usdBalance 只是展示用途，用 currentPrice 和 totalAssets 做一个占位计算
        "balance": (totalAssets * crypto.currentPrice).toStringAsFixed(4),
        "usdBalance": "\$${crypto.currentPrice.toStringAsFixed(4)}",
        "usdBalanceFormatted":
            "\$${(totalAssets * crypto.currentPrice).toStringAsFixed(4)}",
        "crypto": crypto,
        "tokenAddressKey": tokenAddressKey,
      });
    }

    // 1. BTC (Bitcoin 链)
    addToken(
      crypto: _get('btc'),
      displaySymbol: 'BTC',
      walletChain: 'BTC',
      networkLabel: 'Bitcoin',
      iconPath: 'assets/token_networks/btc.png',
    );

    // 2. ETH (以太坊主网 / ERC20)
    addToken(
      crypto: _get('eth'),
      displaySymbol: 'ETH',
      walletChain: 'ETH',
      networkLabel: 'ERC20',
      iconPath: 'assets/token_networks/eth.png',
    );

    // 3-5. USDC 各网络
    final usdc = _get('usdc');
    addToken(
      crypto: usdc,
      displaySymbol: 'USDC',
      walletChain: 'ETH',
      networkLabel: 'ERC20',
      iconPath: 'assets/token_networks/usdc-eth.png',
      tokenAddressKey: 'USDC',
    );
    addToken(
      crypto: usdc,
      displaySymbol: 'USDC',
      walletChain: 'MATIC',
      networkLabel: 'Polygon',
      iconPath: 'assets/token_networks/usdc-polygon.png',
      tokenAddressKey: 'USDC',
    );
    addToken(
      crypto: usdc,
      displaySymbol: 'USDC',
      walletChain: 'BNB',
      networkLabel: 'BEP20',
      iconPath: 'assets/token_networks/usdc-bnb.png',
      tokenAddressKey: 'USDC',
    );

    // 6-9. USDT 各网络
    final usdt = _get('usdt');
    addToken(
      crypto: usdt,
      displaySymbol: 'USDT',
      walletChain: 'ETH',
      networkLabel: 'ERC20',
      iconPath: 'assets/token_networks/usdt-eth.png',
      tokenAddressKey: 'USDT',
    );
    addToken(
      crypto: usdt,
      displaySymbol: 'USDT',
      walletChain: 'TRX',
      networkLabel: 'TRC20',
      iconPath: 'assets/token_networks/usdt-tron.png',
      tokenAddressKey: 'USDT',
    );
    addToken(
      crypto: usdt,
      displaySymbol: 'USDT',
      walletChain: 'BNB',
      networkLabel: 'BEP20',
      iconPath: 'assets/token_networks/usdt-bnb.png',
      tokenAddressKey: 'USDT',
    );
    addToken(
      crypto: usdt,
      displaySymbol: 'USDT',
      walletChain: 'MATIC',
      networkLabel: 'Polygon',
      iconPath: 'assets/token_networks/usdt-polygon.png',
      tokenAddressKey: 'USDT',
    );

    // 10. HKD 法币
    final hkd = _get('hkd');
    if (hkd != null) {
      _tokens.add({
        "name": hkd.name,
        "symbol": 'HKD',
        "chain": 'ETH', // 先复用 ETH 地址，如需单独 HKD 链可再调整
        "iconPath": 'assets/hkd.png',
        "image": hkd.image,
        "color": Colors.green,
        "networks": ['HKD'],
        "balance": (totalAssets * hkd.currentPrice).toStringAsFixed(4),
        "usdBalance": "\$${hkd.currentPrice.toStringAsFixed(4)}",
        "usdBalanceFormatted":
            "\$${(totalAssets * hkd.currentPrice).toStringAsFixed(4)}",
        "crypto": hkd,
      });
    }
  }

  Color _getCryptoColor(String id) {
    switch (id) {
      case 'bitcoin':
        return Colors.orange;
      case 'ethereum':
        return Colors.blue;
      case 'binancecoin':
        return Colors.yellow.shade700;
      case 'matic-network':
        return Colors.purple;
      case 'base':
        return Colors.blue.shade300;
      case 'tron':
        return Colors.red;
      case 'solana':
        return Colors.purple.shade300;
      default:
        return Colors.grey;
    }
  }

  String _getCryptoIcon(String id) {
    switch (id) {
      case 'bitcoin':
        return 'assets/btc.png';
      case 'ethereum':
        return 'assets/eth.png';
      case 'tether':
        return 'assets/usdt.png';
      case 'usd-coin':
        return 'assets/usdc.png';
      default:
        return 'assets/hkd.png'; // Default icon
    }
  }

  void setTotalAssets(double value) {
    _totalAssets = value;
    notifyListeners();
  }

  void filterTokens(String query) {
    if (query.isEmpty) {
      _filteredTokens = _tokens;
    } else {
      _filteredTokens = _tokens.where((token) {
        return token["name"].toLowerCase().contains(query.toLowerCase()) ||
            token["symbol"].toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}
