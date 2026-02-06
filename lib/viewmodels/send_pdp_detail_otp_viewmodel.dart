import 'package:flutter/material.dart';
import 'package:Demo/core/base_viewmodel.dart';
import 'package:Demo/services/wallet_service.dart';
import 'package:Demo/models/requests/verify_pin_request.dart';
import 'package:Demo/models/responses/verify_pin_response.dart';

class SendPdpDetailOtpViewModel extends BaseViewModel {
  final WalletService _walletService = WalletService();

  VerifyPinResponse? _verifyResponse;
  VerifyPinResponse? get verifyResponse => _verifyResponse;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> verifyPin(String pin, int idUser) async {
    setBusy(true);
    _errorMessage = null;
    try {
      final request = VerifyPinRequest(pin: pin);
      _verifyResponse = await _walletService.verifyPin(request, idUser);
      notifyListeners();

      if (_verifyResponse!.data.verified) {
        return true;
      } else {
        _errorMessage = _verifyResponse!.data.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      setBusy(false);
    }
  }
}
