import 'package:Demo/core/base_viewmodel.dart';
import 'package:dio/dio.dart';

class SendPdpViewModel extends BaseViewModel {
  final Dio _dio = Dio();

  List<Map<String, dynamic>> _networks = [];
  List<Map<String, dynamic>> get networks => _networks;

  Map<String, dynamic>? _selectedNetwork;
  Map<String, dynamic>? get selectedNetwork => _selectedNetwork;

  bool _loading = false;
  bool get loading => _loading;

  bool _withdrawing = false;
  bool get withdrawing => _withdrawing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _withdrawResponse;
  Map<String, dynamic>? get withdrawResponse => _withdrawResponse;

  Future<void> fetchNetworks(String symbol) async {
    if (symbol.isEmpty) return;
    setBusy(true);
    _loading = true;
    notifyListeners();
    try {
      final resp = await _dio.get(
        'http://149.88.65.193:8010/api/networks',
        queryParameters: {'coin': symbol},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final data = resp.data;
      if (data != null && data['data'] is List) {
        final list = List.from(data['data']);
        _networks = list.map((e) {
          if (e is Map<String, dynamic>) return e;
          return Map<String, dynamic>.from(e);
        }).toList();
        if (_networks.isNotEmpty) {
          _selectedNetwork ??= _networks.first;
        }
      }
    } catch (e) {
      // Optionally log or set an error message
    } finally {
      _loading = false;
      setBusy(false);
      notifyListeners();
    }
  }

  void selectNetwork(Map<String, dynamic>? network) {
    _selectedNetwork = network;
    notifyListeners();
  }

  /// Calls the withdraw API with the provided parameters.
  /// Returns true on success, false on failure.
  Future<bool> withdrawRequest({
    required int coinId,
    required int networkId,
    required String toAddress,
    required double amount,
    required int userId,
  }) async {
    _withdrawing = true;
    _errorMessage = null;
    _withdrawResponse = null;
    setBusy(true);
    notifyListeners();

    try {
      final resp = await _dio.post(
        'http://149.88.65.193:8010/api/withdraw',
        data: {
          'coin_id': coinId,
          'network_id': networkId,
          'to_address': toAddress,
          'amount': amount,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'id_user': userId.toString(),
          },
        ),
      );

      final data = resp.data;
      if (data != null && data['code'] == 200) {
        _withdrawResponse = data['data'];
        return true;
      } else {
        _errorMessage = data?['message'] ?? 'Unknown error';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _withdrawing = false;
      setBusy(false);
      notifyListeners();
    }
  }
}
