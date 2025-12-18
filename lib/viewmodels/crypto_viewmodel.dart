import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/responses/crypto_response_model.dart';
import 'package:comecomepay/services/crypto_service.dart';

class CryptoViewModel extends BaseViewModel {
  final CryptoService _cryptoService = CryptoService();

  List<CryptoResponse> _cryptoData = [];
  List<CryptoResponse> get cryptoData => _cryptoData;

  Future<void> fetchCryptoData() async {
    setBusy(true);
    try {
      _cryptoData = await _cryptoService.fetchCryptoData();
    } catch (e) {
      _cryptoData = [];
    }

    // Hardcoded fallback list dengan sparklineIn7d
    final List<CryptoResponse> fallbackData = [
      CryptoResponse(
        id: 'bitcoin',
        symbol: 'btc',
        name: 'Bitcoin',
        image: 'https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png',
        currentPrice: 91168,
        priceChange24h: 4233.69,
        priceChangePercentage24h: 4.86998,
        sparklineIn7d: [91408, 91801, 92482], // contoh data sparkline
      ),
      CryptoResponse(
        id: 'ethereum',
        symbol: 'eth',
        name: 'Ethereum',
        image: 'https://coin-images.coingecko.com/coins/images/279/large/ethereum.png',
        currentPrice: 3041.3,
        priceChange24h: 118.26,
        priceChangePercentage24h: 4.04584,
        sparklineIn7d: [3020, 3038, 3042],
      ),
      CryptoResponse(
        id: 'tether',
        symbol: 'usdt',
        name: 'Tether',
        image: 'https://coin-images.coingecko.com/coins/images/325/large/Tether.png',
        currentPrice: 0.999918,
        priceChange24h: 0.0001727,
        priceChangePercentage24h: 0.01727,
        sparklineIn7d: [0.9991, 0.9992, 0.9993],
      ),
      CryptoResponse(
        id: 'usd-coin',
        symbol: 'usdc',
        name: 'USDC',
        image: 'https://coin-images.coingecko.com/coins/images/6319/large/usdc.png',
        currentPrice: 0.999844,
        priceChange24h: 0.00014137,
        priceChangePercentage24h: 0.01414,
        sparklineIn7d: [0.9997, 0.9996, 0.9998],
      ),
      CryptoResponse(
        id: 'hong-kong-dollar',
        symbol: 'hkd',
        name: 'HKD',
        image: 'https://cdn-icons-png.flaticon.com/512/3033/3033722.png',
        currentPrice: 7.8,
        priceChange24h: 0.0,
        priceChangePercentage24h: 0.0,
        sparklineIn7d: [7.8, 7.81, 7.79],
      ),
      CryptoResponse(
        id: 'usd',
        symbol: 'usd',
        name: 'USD',
        image: 'https://cdn-icons-png.freepik.com/512/6557/6557111.png',
        currentPrice: 1.0,
        priceChange24h: 0.0,
        priceChangePercentage24h: 0.0,
        sparklineIn7d: [7.8, 7.81, 7.79],
      ),
    ];

    // Tambahkan fallback data jika simbol belum ada
    for (var fallback in fallbackData) {
      if (!_cryptoData.any((c) => c.symbol == fallback.symbol)) {
        _cryptoData.add(fallback);
      }
    }

    notifyListeners();
    setBusy(false);
  }

}
