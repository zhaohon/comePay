import 'dart:math';
import 'package:flutter/material.dart';
import 'package:Demo/core/base_viewmodel.dart';
import 'package:Demo/models/requests/create_wallet_request_model.dart';
import 'package:Demo/models/responses/create_wallet_response_model.dart';
import 'package:Demo/models/responses/create_wallet_error_model.dart';
import 'package:Demo/services/global_service.dart';
import 'package:Demo/services/hive_storage_service.dart';
import 'package:Demo/utils/service_locator.dart';

// Response types for different scenarios
class CreateWalletResult {
  final bool success;
  final String? message;
  final CreateWalletResponseType responseType;

  CreateWalletResult({
    required this.success,
    this.message,
    required this.responseType,
  });
}

enum CreateWalletResponseType {
  success,
  error,
}

class CreateAccountVerificationViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  // State variables
  String? _errorMessage;
  CreateWalletResponseModel? _createWalletResponse;

  // Getters
  bool get isLoading => busy;
  String? get errorMessage => _errorMessage;
  CreateWalletResponseModel? get createWalletResponse => _createWalletResponse;

  // Setters
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Business logic methods
  Future<CreateWalletResult> createWallet() async {
    // Get user data from Hive
    final user = HiveStorageService.getUser();
    if (user == null) {
      _errorMessage = 'User data not found';
      notifyListeners();
      return CreateWalletResult(
        success: false,
        message: _errorMessage,
        responseType: CreateWalletResponseType.error,
      );
    }

    // Generate tenant_external_id
    final random = Random();
    final generatedNumber = 10000 + random.nextInt(90000); // 10000-99999
    final name = '${user.firstName}${user.lastName}';
    final tenantExternalId = 'app_user_${generatedNumber}_${name}_${user.id}';

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Buat request model
      final request = CreateWalletRequestModel(
        tenantName: user.email,
        tenantExternalId: tenantExternalId,
        chain: 'ALL',
        label: 'User Wallet',
        custody: 'custodial',
      );

      // Call service
      final response =
          await _globalService.createWallet(request, user.id.toString());

      // Handle different response types
      if (response is CreateWalletResponseModel) {
        // Create wallet berhasil
        _createWalletResponse = response;
        _errorMessage = null;

        setBusy(false);
        return CreateWalletResult(
          success: true,
          message: response.message,
          responseType: CreateWalletResponseType.success,
        );
      } else if (response is CreateWalletErrorModel) {
        // Create wallet error
        _errorMessage = response.error;
        _createWalletResponse = null;
        setBusy(false);
        return CreateWalletResult(
          success: false,
          message: _errorMessage,
          responseType: CreateWalletResponseType.error,
        );
      } else {
        // Unexpected response
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        _createWalletResponse = null;
        setBusy(false);
        return CreateWalletResult(
          success: false,
          message: _errorMessage,
          responseType: CreateWalletResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _createWalletResponse = null;
      setBusy(false);
      return CreateWalletResult(
        success: false,
        message: _errorMessage,
        responseType: CreateWalletResponseType.error,
      );
    }
  }
}
