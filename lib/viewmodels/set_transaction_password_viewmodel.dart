import 'package:flutter/material.dart';
import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/requests/transaction_password_request_model.dart';
import 'package:comecomepay/models/responses/transaction_password_response_model.dart';
import 'package:comecomepay/models/responses/transaction_password_error_model.dart';
import 'package:comecomepay/models/requests/complete_transaction_password_request_model.dart';
import 'package:comecomepay/models/responses/complete_transaction_password_response_model.dart';
import 'package:comecomepay/models/responses/complete_transaction_password_error_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/utils/service_locator.dart';

// Response types for transaction password
class TransactionPasswordResult {
  final bool success;
  final String? message;
  final TransactionPasswordResponseType responseType;

  TransactionPasswordResult({
    required this.success,
    this.message,
    required this.responseType,
  });
}

enum TransactionPasswordResponseType {
  success,
  error,
}

// Response types for complete transaction password
class CompleteTransactionPasswordResult {
  final bool success;
  final String? message;
  final CompleteTransactionPasswordResponseType responseType;

  CompleteTransactionPasswordResult({
    required this.success,
    this.message,
    required this.responseType,
  });
}

enum CompleteTransactionPasswordResponseType {
  success,
  error,
}

class SetTransactionPasswordViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  // State variables
  String? _errorMessage;
  String? _tempHash;
  bool _isOtpRequested = false;

  // Getters
  bool get isLoading => busy;
  String? get errorMessage => _errorMessage;
  String? get tempHash => _tempHash;
  bool get isOtpRequested => _isOtpRequested;

  // Setters
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Business logic methods
  Future<TransactionPasswordResult> requestTransactionPassword({
    required String password,
    required String confirmPassword,
  }) async {
    // Validasi input
    if (password.isEmpty || confirmPassword.isEmpty) {
      _errorMessage = 'Password fields cannot be empty';
      notifyListeners();
      return TransactionPasswordResult(
        success: false,
        message: _errorMessage,
        responseType: TransactionPasswordResponseType.error,
      );
    }

    if (password != confirmPassword) {
      _errorMessage = 'Passwords do not match';
      notifyListeners();
      return TransactionPasswordResult(
        success: false,
        message: _errorMessage,
        responseType: TransactionPasswordResponseType.error,
      );
    }

    // if (password.length != 6) {
    //   _errorMessage = 'Transaction password must be 6 digits';
    //   notifyListeners();
    //   return TransactionPasswordResult(
    //     success: false,
    //     message: _errorMessage,
    //     responseType: TransactionPasswordResponseType.error,
    //   );
    // }

    // if (!RegExp(r'^\d{6}$').hasMatch(password)) {
    //   _errorMessage = 'Transaction password must be numeric';
    //   notifyListeners();
    //   return TransactionPasswordResult(
    //     success: false,
    //     message: _errorMessage,
    //     responseType: TransactionPasswordResponseType.error,
    //   );
    // }

    // No loading state
    _errorMessage = null;

    try {
      // Create request model
      final request = TransactionPasswordRequestModel(
        transactionPassword: password,
        confirmTransactionPassword: confirmPassword,
      );

      // Call service
      final response = await _globalService.requestTransactionPassword(request);

      // Handle different response types
      if (response is TransactionPasswordResponseModel) {
        // Request berhasil
        _tempHash = response.tempHash;
        await HiveStorageService.saveTempHash(response.tempHash);
        _errorMessage = null;
        _isOtpRequested = true;
        notifyListeners();
        return TransactionPasswordResult(
          success: true,
          message: response.message,
          responseType: TransactionPasswordResponseType.success,
        );
      } else if (response is TransactionPasswordErrorModel) {
        // Request error
        _errorMessage = response.error;
        _tempHash = null;
        _isOtpRequested = false;
        notifyListeners();
        return TransactionPasswordResult(
          success: false,
          message: _errorMessage,
          responseType: TransactionPasswordResponseType.error,
        );
      } else {
        // Unexpected response
        _errorMessage = 'An unexpected error occurred';
        _tempHash = null;
        _isOtpRequested = false;
        notifyListeners();
        return TransactionPasswordResult(
          success: false,
          message: _errorMessage,
          responseType: TransactionPasswordResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      _tempHash = null;
      _isOtpRequested = false;
      notifyListeners();
      return TransactionPasswordResult(
        success: false,
        message: _errorMessage,
        responseType: TransactionPasswordResponseType.error,
      );
    }
  }

  // Business logic methods for complete transaction password
  Future<CompleteTransactionPasswordResult> completeTransactionPassword({
    required String otpCode,
  }) async {
    // Validasi input
    if (otpCode.isEmpty) {
      _errorMessage = 'OTP code cannot be empty';
      notifyListeners();
      return CompleteTransactionPasswordResult(
        success: false,
        message: _errorMessage,
        responseType: CompleteTransactionPasswordResponseType.error,
      );
    }

    if (_tempHash == null) {
      _errorMessage = 'No temp hash available. Please request OTP first.';
      notifyListeners();
      return CompleteTransactionPasswordResult(
        success: false,
        message: _errorMessage,
        responseType: CompleteTransactionPasswordResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Create request model
      final request = CompleteTransactionPasswordRequestModel(
        otpCode: otpCode,
        tempHash: _tempHash!,
      );

      // Call service
      final response =
          await _globalService.completeTransactionPassword(request);

      // Handle different response types
      if (response is CompleteTransactionPasswordResponseModel) {
        // Completion berhasil
        _errorMessage = null;
        // Clear temp hash after success
        _tempHash = null;
        await HiveStorageService.clearTempHash();

        setBusy(false);
        return CompleteTransactionPasswordResult(
          success: true,
          message: response.message,
          responseType: CompleteTransactionPasswordResponseType.success,
        );
      } else if (response is CompleteTransactionPasswordErrorModel) {
        // Completion error
        _errorMessage = response.error;
        setBusy(false);
        return CompleteTransactionPasswordResult(
          success: false,
          message: _errorMessage,
          responseType: CompleteTransactionPasswordResponseType.error,
        );
      } else {
        // Unexpected response
        _errorMessage = 'An unexpected error occurred';
        setBusy(false);
        return CompleteTransactionPasswordResult(
          success: false,
          message: _errorMessage,
          responseType: CompleteTransactionPasswordResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      setBusy(false);
      return CompleteTransactionPasswordResult(
        success: false,
        message: _errorMessage,
        responseType: CompleteTransactionPasswordResponseType.error,
      );
    }
  }
}
