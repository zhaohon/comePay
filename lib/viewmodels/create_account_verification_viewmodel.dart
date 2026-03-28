import 'dart:math';
import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/requests/create_wallet_request_model.dart';
import 'package:comecomepay/models/responses/create_wallet_response_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/utils/service_locator.dart';

import 'package:comecomepay/l10n/app_localizations.dart';

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
  Future<CreateWalletResult> createWallet(AppLocalizations l10n) async {
    // Get user data from Hive
    final user = HiveStorageService.getUser();
    if (user == null) {
      _errorMessage = l10n.userDataNotFound;
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

      // Success (BaseService handles failure by throwing)
      _createWalletResponse = response as CreateWalletResponseModel;
      _errorMessage = null;

      setBusy(false);
      return CreateWalletResult(
        success: true,
        message: response.message,
        responseType: CreateWalletResponseType.success,
      );
    } catch (e) {
      _errorMessage = e.toString();
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
