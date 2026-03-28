import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/wallet_model.dart';
import 'package:comecomepay/models/requests/verify_pin_request.dart';
import 'package:comecomepay/models/responses/verify_pin_response.dart';
import 'package:dio/dio.dart';

class WalletService extends BaseService {
  Future<WalletResponse> getWalletById(int idUser) async {
    final response = await get(
      'http://149.88.65.193:8010/api/v1/wallet/',
      options: Options(
        headers: {
          'id_user': idUser.toString(),
        },
      ),
    );

    return WalletResponse.fromJson(response);
  }

  Future<VerifyPinResponse> verifyPin(
      VerifyPinRequest request, int idUser) async {
    final response = await post(
      'http://149.88.65.193:8010/api/wallet/verify-pin',
      data: request.toJson(),
      options: Options(
        headers: {
          'id_user': idUser.toString(),
        },
      ),
    );

    return VerifyPinResponse.fromJson(response);
  }
}
