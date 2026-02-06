import 'package:Demo/core/base_service.dart';
import 'package:Demo/models/wallet_model.dart';
import 'package:Demo/models/requests/verify_pin_request.dart';
import 'package:Demo/models/responses/verify_pin_response.dart';
import 'package:dio/dio.dart';

class WalletService extends BaseService {
  Future<WalletResponse> getWalletById(int idUser) async {
    try {
      final response = await dio.get(
        'http://149.88.65.193:8010/api/v1/wallet/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'id_user': idUser.toString(),
          },
        ),
      );

      final data = handleResponse(response);
      return WalletResponse.fromJson(data);
    } catch (e) {
      throw e;
    }
  }

  Future<VerifyPinResponse> verifyPin(
      VerifyPinRequest request, int idUser) async {
    try {
      final response = await dio.post(
        'http://149.88.65.193:8010/api/wallet/verify-pin',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'id_user': idUser.toString(),
          },
        ),
      );

      final data = handleResponse(response);
      return VerifyPinResponse.fromJson(data);
    } catch (e) {
      throw e;
    }
  }
}
