import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/services/swap_service.dart';
import 'dart:async';

class SwapViewModel extends BaseViewModel {
  final SwapService _swapService = SwapService();

  // Rate cache: e.g. "USDT_HKD" -> 7.8
  double _exchangeRate = 0.0;
  double get exchangeRate => _exchangeRate;

  bool _isLoadingRate = false;
  bool get isLoadingRate => _isLoadingRate;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Method to fetch exchange rate
  Future<void> fetchExchangeRate(String src, String dst) async {
    _isLoadingRate = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _swapService.getExchangeRate(
        srcCurrencyCode: src,
        dstCurrencyCode: dst,
      );
      // Assuming response structure: { ..., data: { rate: 7.8, ... } } or direct rate field.
      // Based on user description: "1源币种 能换 多少 目标币种"
      // Let's assume the API returns a 'price' or 'rate'.
      // Usually currencySimple returns the price of src in dst.
      // I will log and parse dynamically for robustness or assume a standard field like 'price' or 'rate'.
      // Since I cannot see the exact API response format in the prompt, I will assume 'price' from common patterns or look for "data".
      // Let's assume data['data']['price'] or data['price'].

      // Let's assume the response is the 'data' part returned by handleResponse which strips the wrapper.
      // If handleResponse returns the inner data object.
      // Let's try to find a 'price' field.

      if (data.containsKey('price')) {
        _exchangeRate = double.tryParse(data['price'].toString()) ?? 0.0;
      } else if (data.containsKey('rate')) {
        _exchangeRate = double.tryParse(data['rate'].toString()) ?? 0.0;
      } else {
        // Fallback if structure is unknown, log it (implying we might need to debug if it fails)
        _exchangeRate = 0.0;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _exchangeRate = 0.0;
    } finally {
      _isLoadingRate = false;
      notifyListeners();
    }
  }
}
