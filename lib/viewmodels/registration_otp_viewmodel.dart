import 'package:flutter/material.dart';
import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/requests/registration_otp_verification_request_model.dart';
import 'package:comecomepay/models/responses/registration_otp_verification_response_model.dart';
import 'package:comecomepay/models/responses/registration_otp_verification_error_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/utils/service_locator.dart';

// Response types for different scenarios
class RegistrationOtpResult {
  final bool success;
  final String? message;
  final RegistrationOtpResponseType responseType;

  RegistrationOtpResult({
    required this.success,
    this.message,
    required this.responseType,
  });
}

enum RegistrationOtpResponseType {
  success,
  error,
}

class RegistrationOtpViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  // State variables
  String? _errorMessage;
  RegistrationOtpVerificationResponseModel? _otpResponse;

  // Getters
  bool get isLoading => busy;
  String? get errorMessage => _errorMessage;
  RegistrationOtpVerificationResponseModel? get otpResponse => _otpResponse;

  // Setters
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<RegistrationOtpResult> resendOtp(String email) async {
    // Validasi input
    if (email.isEmpty) {
      _errorMessage = 'Email tidak boleh kosong';
      notifyListeners();
      return RegistrationOtpResult(
        success: false,
        message: _errorMessage,
        responseType: RegistrationOtpResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Call service
      final response = await _globalService.resendOtp(email);

      // Handle different response types
      if (response is Map<String, dynamic> && response['status'] == 'success') {
        // Resend OTP berhasil
        _errorMessage = null;
        setBusy(false);
        return RegistrationOtpResult(
          success: true,
          message: response['message'] ?? 'New OTP sent to your email',
          responseType: RegistrationOtpResponseType.success,
        );
      } else if (response is Map<String, dynamic> &&
          response['error'] != null) {
        // Resend OTP gagal
        _errorMessage = response['error'];
        setBusy(false);
        return RegistrationOtpResult(
          success: false,
          message: _errorMessage,
          responseType: RegistrationOtpResponseType.error,
        );
      } else {
        // Unexpected response
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        setBusy(false);
        return RegistrationOtpResult(
          success: false,
          message: _errorMessage,
          responseType: RegistrationOtpResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      setBusy(false);
      return RegistrationOtpResult(
        success: false,
        message: _errorMessage,
        responseType: RegistrationOtpResponseType.error,
      );
    }
  }

  // Business logic methods
  Future<RegistrationOtpResult> verifyRegistrationOtp({
    required String email,
    required String otpCode,
  }) async {
    // Validasi input
    if (email.isEmpty) {
      _errorMessage = 'Email tidak boleh kosong';
      notifyListeners();
      return RegistrationOtpResult(
        success: false,
        message: _errorMessage,
        responseType: RegistrationOtpResponseType.error,
      );
    }

    if (otpCode.isEmpty || otpCode.length != 5) {
      _errorMessage = 'OTP harus diisi dengan 5 digit';
      notifyListeners();
      return RegistrationOtpResult(
        success: false,
        message: _errorMessage,
        responseType: RegistrationOtpResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Buat request model
      final request = RegistrationOtpVerificationRequestModel(
        email: email,
        otpCode: otpCode,
      );

      // Call service
      final response = await _globalService.verifyRegistrationOtp(request);

      // Handle different response types
      if (response is RegistrationOtpVerificationResponseModel) {
        // OTP verification berhasil
        _otpResponse = response;
        _errorMessage = null;

        setBusy(false);
        return RegistrationOtpResult(
          success: true,
          message: response.message,
          responseType: RegistrationOtpResponseType.success,
        );
      } else if (response is RegistrationOtpVerificationErrorModel) {
        // OTP verification error
        _errorMessage = response.error;
        _otpResponse = null;
        setBusy(false);
        return RegistrationOtpResult(
          success: false,
          message: _errorMessage,
          responseType: RegistrationOtpResponseType.error,
        );
      } else {
        // Unexpected response
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        _otpResponse = null;
        setBusy(false);
        return RegistrationOtpResult(
          success: false,
          message: _errorMessage,
          responseType: RegistrationOtpResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _otpResponse = null;
      setBusy(false);
      return RegistrationOtpResult(
        success: false,
        message: _errorMessage,
        responseType: RegistrationOtpResponseType.error,
      );
    }
  }
}
