import 'package:flutter/material.dart';
import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/services/transaction_service.dart';
import 'package:comecomepay/models/requests/transaction_preview_request_model.dart';
import 'package:comecomepay/models/responses/transaction_preview_response_model.dart';

class SendPdpDetailViewModel extends BaseViewModel {
  final TransactionService _transactionService = TransactionService();

  TransactionPreviewResponse? _previewResponse;
  TransactionPreviewResponse? get previewResponse => _previewResponse;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> previewTransaction({
    required String toAddress,
    required String tokenSymbol,
    required String network,
    required double amount,
  }) async {
    setBusy(true);
    _errorMessage = null;
    try {
      final request = TransactionPreviewRequest(
        toAddress: toAddress,
        tokenSymbol: tokenSymbol,
        network: network,
        amount: amount.toString(),
      );
      _previewResponse = await _transactionService.previewTransaction(request);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }
}
