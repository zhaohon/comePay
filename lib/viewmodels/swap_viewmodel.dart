import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/services/swap_service.dart';
import 'dart:async';

class SwapViewModel extends BaseViewModel {
  final SwapService _swapService = SwapService();

  // 汇率
  double _exchangeRate = 0.0;
  double get exchangeRate => _exchangeRate;

  bool _isLoadingRate = false;
  bool get isLoadingRate => _isLoadingRate;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 报价数据
  String? _quoteId;
  String? get quoteId => _quoteId;

  double _fromAmount = 0.0;
  double get fromAmount => _fromAmount;

  double _toAmount = 0.0;
  double get toAmount => _toAmount;

  double _fee = 0.0;
  double get fee => _fee;

  double _netAmount = 0.0;
  double get netAmount => _netAmount;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _expiresAt;

  bool _isCreatingPreview = false;
  bool get isCreatingPreview => _isCreatingPreview;

  bool _isExecutingSwap = false;
  bool get isExecutingSwap => _isExecutingSwap;

  /// 获取汇率
  Future<void> fetchExchangeRate(String fromCurrency, String toCurrency) async {
    _isLoadingRate = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _swapService.getExchangeRate(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );

      // 根据API文档，响应格式为：
      // { "status": "success", "data": { "rate": 7.80, ... } }
      if (response['data'] != null) {
        final data = response['data'];
        _exchangeRate = (data['rate'] ?? 0.0).toDouble();
      } else {
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

  /// 创建兑换预览/报价
  Future<bool> createPreview({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    if (amount <= 0) {
      _errorMessage = '金额必须大于0';
      notifyListeners();
      return false;
    }

    _isCreatingPreview = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _swapService.createPreview(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        amount: amount,
      );

      // 根据API文档，响应格式为：
      // {
      //   "status": "success",
      //   "data": {
      //     "quote_id": "quote_xxx",
      //     "from_amount": 100,
      //     "to_amount": 780,
      //     "exchange_rate": 7.80,
      //     "fee": 0,
      //     "net_amount": 780,
      //     "expires_at": "2025-12-21T00:05:00Z"
      //   }
      // }
      if (response['data'] != null) {
        final data = response['data'];
        _quoteId = data['quote_id'];
        _fromAmount = (data['from_amount'] ?? 0.0).toDouble();
        _toAmount = (data['to_amount'] ?? 0.0).toDouble();
        _exchangeRate = (data['exchange_rate'] ?? 0.0).toDouble();
        _fee = (data['fee'] ?? 0.0).toDouble();
        _netAmount = (data['net_amount'] ?? 0.0).toDouble();

        // 解析过期时间
        if (data['expires_at'] != null) {
          _expiresAt = DateTime.parse(data['expires_at']);
        }

        _isCreatingPreview = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = '创建报价失败：数据格式错误';
        _isCreatingPreview = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isCreatingPreview = false;
      notifyListeners();
      return false;
    }
  }

  /// 执行兑换
  Future<Map<String, dynamic>?> executeSwap({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    if (amount <= 0) {
      _errorMessage = '金额必须大于0';
      notifyListeners();
      return null;
    }

    _isExecutingSwap = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _swapService.executeSwap(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        amount: amount,
        quoteId: _quoteId,
      );

      _isExecutingSwap = false;
      notifyListeners();

      // 返回完整的响应数据供UI使用
      return response['data'];
    } catch (e) {
      _errorMessage = e.toString();
      _isExecutingSwap = false;
      notifyListeners();
      return null;
    }
  }

  /// 清除报价数据
  void clearQuote() {
    _quoteId = null;
    _fromAmount = 0.0;
    _toAmount = 0.0;
    _fee = 0.0;
    _netAmount = 0.0;
    _expiresAt = null;
    notifyListeners();
  }

  /// 检查报价是否过期
  bool isQuoteExpired() {
    if (_expiresAt == null) return true;
    return DateTime.now().isAfter(_expiresAt!);
  }
}
