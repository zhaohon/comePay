import 'package:flutter/material.dart';
import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/requests/change_email_request_model.dart';
import 'package:comecomepay/models/responses/change_email_response_model.dart';
import 'package:comecomepay/models/responses/change_email_error_model.dart';
import 'package:comecomepay/models/requests/verify_new_email_request_model.dart';
import 'package:comecomepay/models/responses/verify_new_email_response_model.dart';
import 'package:comecomepay/models/requests/complete_change_email_request_model.dart';
import 'package:comecomepay/models/responses/complete_change_email_response_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/utils/service_locator.dart';

// Result types for change email scenarios
class ChangeEmailResult {
  final bool success;
  final String? message;
  final ChangeEmailResponseType responseType;
  final String? newEmail;
  final String? otp;
  final String? nextStep;

  ChangeEmailResult({
    required this.success,
    this.message,
    required this.responseType,
    this.newEmail,
    this.otp,
    this.nextStep,
  });
}

enum ChangeEmailResponseType {
  success,
  otpSent,
  error,
}

class VerifyNewEmailResult {
  final bool success;
  final String? message;
  final VerifyNewEmailResponseType responseType;
  final String? currentEmail;
  final String? otp;
  final String? nextStep;

  VerifyNewEmailResult({
    required this.success,
    this.message,
    required this.responseType,
    this.currentEmail,
    this.otp,
    this.nextStep,
  });
}

enum VerifyNewEmailResponseType {
  success,
  otpSentToCurrent,
  error,
}

class CompleteChangeEmailResult {
  final bool success;
  final String? message;
  final CompleteChangeEmailResponseType responseType;
  final String? newEmail;

  CompleteChangeEmailResult({
    required this.success,
    this.message,
    required this.responseType,
    this.newEmail,
  });
}

enum CompleteChangeEmailResponseType {
  success,
  error,
}

class ModifyEmailViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  // State variables
  String? _errorMessage;
  ChangeEmailResponseModel? _changeEmailResponse;
  bool _isEmailValid = false;

  // Getters
  bool get isLoading => busy;
  String? get errorMessage => _errorMessage;
  ChangeEmailResponseModel? get changeEmailResponse => _changeEmailResponse;
  bool get isEmailValid => _isEmailValid;

  // Setters
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Business logic methods
  Future<ChangeEmailResult> requestChangeEmail(String newEmail) async {
    // Validasi input
    if (newEmail.isEmpty) {
      _errorMessage = 'Email baru tidak boleh kosong';
      notifyListeners();
      return ChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: ChangeEmailResponseType.error,
      );
    }

    if (!isValidEmail(newEmail)) {
      _errorMessage = 'Format email tidak valid';
      notifyListeners();
      return ChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: ChangeEmailResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;
    _isEmailValid = true;

    try {
      // Buat request model
      final request = ChangeEmailRequestModel(newEmail: newEmail);

      // Call service
      final response = await _globalService.changeEmail(request);

      // Handle different response types
      if (response is ChangeEmailResponseModel) {
        // Change email request berhasil
        _changeEmailResponse = response;
        _errorMessage = null;

        setBusy(false);
        return ChangeEmailResult(
          success: true,
          message: response.message,
          responseType: ChangeEmailResponseType.otpSent,
          newEmail: response.newEmail,
          otp: response.otp,
          nextStep: response.nextStep,
        );
      } else if (response is ChangeEmailErrorModel) {
        // Change email error
        _errorMessage = response.error;
        _changeEmailResponse = null;
        setBusy(false);
        return ChangeEmailResult(
          success: false,
          message: response.error,
          responseType: ChangeEmailResponseType.error,
        );
      } else if (response is Map<String, dynamic>) {
        // Handle raw response if needed
        if (response['status'] == 'success') {
          _changeEmailResponse = ChangeEmailResponseModel.fromJson(response);
          _errorMessage = null;
          setBusy(false);
          return ChangeEmailResult(
            success: true,
            message: response['message'],
            responseType: ChangeEmailResponseType.otpSent,
            newEmail: response['new_email'],
            otp: response['otp'],
            nextStep: response['next_step'],
          );
        } else {
          _errorMessage = response['error'] ?? 'Change email failed';
          _changeEmailResponse = null;
          setBusy(false);
          return ChangeEmailResult(
            success: false,
            message: _errorMessage,
            responseType: ChangeEmailResponseType.error,
          );
        }
      } else {
        // Unexpected response
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        _changeEmailResponse = null;
        setBusy(false);
        return ChangeEmailResult(
          success: false,
          message: _errorMessage,
          responseType: ChangeEmailResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _changeEmailResponse = null;
      setBusy(false);
      return ChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: ChangeEmailResponseType.error,
      );
    }
  }

  // Helper method untuk validasi email
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Method untuk validate email on change
  void validateEmail(String email) {
    _isEmailValid = isValidEmail(email) && email.isNotEmpty;
    notifyListeners();
  }

  // Method untuk reset state
  void reset() {
    _errorMessage = null;
    _changeEmailResponse = null;
    _isEmailValid = false;
    notifyListeners();
  }

  // Business logic methods for verify new email OTP
  Future<VerifyNewEmailResult> verifyNewEmailOtp(
      String newEmail, String otpCode) async {
    // Validasi input
    if (newEmail.isEmpty) {
      _errorMessage = 'Email baru tidak boleh kosong';
      notifyListeners();
      return VerifyNewEmailResult(
        success: false,
        message: _errorMessage,
        responseType: VerifyNewEmailResponseType.error,
      );
    }

    if (!isValidEmail(newEmail)) {
      _errorMessage = 'Format email tidak valid';
      notifyListeners();
      return VerifyNewEmailResult(
        success: false,
        message: _errorMessage,
        responseType: VerifyNewEmailResponseType.error,
      );
    }

    if (otpCode.isEmpty) {
      _errorMessage = 'Kode OTP tidak boleh kosong';
      notifyListeners();
      return VerifyNewEmailResult(
        success: false,
        message: _errorMessage,
        responseType: VerifyNewEmailResponseType.error,
      );
    }

    if (otpCode.length != 5) {
      _errorMessage = 'Kode OTP harus 5 digit';
      notifyListeners();
      return VerifyNewEmailResult(
        success: false,
        message: _errorMessage,
        responseType: VerifyNewEmailResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Buat request model
      final request = VerifyNewEmailRequestModel(
        newEmail: newEmail,
        otpCode: otpCode,
      );

      // Call service
      final response = await _globalService.verifyNewEmail(request);

      // Handle different response types
      if (response is VerifyNewEmailResponseModel) {
        // Verify new email berhasil
        _errorMessage = null;

        setBusy(false);
        return VerifyNewEmailResult(
          success: true,
          message: response.message,
          responseType: VerifyNewEmailResponseType.otpSentToCurrent,
          currentEmail: response.currentEmail,
          otp: response.otp,
          nextStep: response.nextStep,
        );
      } else if (response is ChangeEmailErrorModel) {
        // Verify new email error
        _errorMessage = response.error;
        setBusy(false);
        return VerifyNewEmailResult(
          success: false,
          message: response.error,
          responseType: VerifyNewEmailResponseType.error,
        );
      } else if (response is Map<String, dynamic>) {
        // Handle raw response if needed
        if (response['status'] == 'success') {
          _errorMessage = null;
          setBusy(false);
          return VerifyNewEmailResult(
            success: true,
            message: response['message'],
            responseType: VerifyNewEmailResponseType.otpSentToCurrent,
            currentEmail: response['current_email'],
            otp: response['otp'],
            nextStep: response['next_step'],
          );
        } else {
          _errorMessage = response['error'] ?? 'Verify new email failed';
          setBusy(false);
          return VerifyNewEmailResult(
            success: false,
            message: _errorMessage,
            responseType: VerifyNewEmailResponseType.error,
          );
        }
      } else {
        // Unexpected response
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        setBusy(false);
        return VerifyNewEmailResult(
          success: false,
          message: _errorMessage,
          responseType: VerifyNewEmailResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      setBusy(false);
      return VerifyNewEmailResult(
        success: false,
        message: _errorMessage,
        responseType: VerifyNewEmailResponseType.error,
      );
    }
  }

  // Business logic methods for complete change email
  Future<CompleteChangeEmailResult> completeChangeEmail(
      String newEmail, String oldEmailOtp) async {
    // Validasi input
    if (newEmail.isEmpty) {
      _errorMessage = 'Email baru tidak boleh kosong';
      notifyListeners();
      return CompleteChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: CompleteChangeEmailResponseType.error,
      );
    }

    if (!isValidEmail(newEmail)) {
      _errorMessage = 'Format email tidak valid';
      notifyListeners();
      return CompleteChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: CompleteChangeEmailResponseType.error,
      );
    }

    if (oldEmailOtp.isEmpty) {
      _errorMessage = 'Kode OTP email lama tidak boleh kosong';
      notifyListeners();
      return CompleteChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: CompleteChangeEmailResponseType.error,
      );
    }

    if (oldEmailOtp.length != 5) {
      _errorMessage = 'Kode OTP harus 5 digit';
      notifyListeners();
      return CompleteChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: CompleteChangeEmailResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Buat request model
      final request = CompleteChangeEmailRequestModel(
        newEmail: newEmail,
        oldEmailOtp: oldEmailOtp,
      );

      // Call service
      final response = await _globalService.completeChangeEmail(request);

      // Handle different response types
      if (response is CompleteChangeEmailResponseModel) {
        // Complete change email berhasil
        _errorMessage = null;

        setBusy(false);
        return CompleteChangeEmailResult(
          success: true,
          message: response.message,
          responseType: CompleteChangeEmailResponseType.success,
          newEmail: response.newEmail,
        );
      } else if (response is ChangeEmailErrorModel) {
        // Complete change email error
        _errorMessage = response.error;
        setBusy(false);
        return CompleteChangeEmailResult(
          success: false,
          message: response.error,
          responseType: CompleteChangeEmailResponseType.error,
        );
      } else if (response is Map<String, dynamic>) {
        // Handle raw response if needed
        if (response['status'] == 'success') {
          _errorMessage = null;
          setBusy(false);
          return CompleteChangeEmailResult(
            success: true,
            message: response['message'],
            responseType: CompleteChangeEmailResponseType.success,
            newEmail: response['new_email'],
          );
        } else {
          _errorMessage = response['error'] ?? 'Complete change email failed';
          setBusy(false);
          return CompleteChangeEmailResult(
            success: false,
            message: _errorMessage,
            responseType: CompleteChangeEmailResponseType.error,
          );
        }
      } else {
        // Unexpected response
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        setBusy(false);
        return CompleteChangeEmailResult(
          success: false,
          message: _errorMessage,
          responseType: CompleteChangeEmailResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      setBusy(false);
      return CompleteChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: CompleteChangeEmailResponseType.error,
      );
    }
  }
}
