import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/responses/transaction_response_model.dart';
import 'package:comecomepay/models/requests/transaction_preview_request_model.dart';
import 'package:comecomepay/models/responses/transaction_preview_response_model.dart';

class TransactionService extends BaseService {
  Future<TransactionResponse> fetchTransactionHistory(
      String transactionId) async {
    final response = await get(
        '/api/v1/card/transaction-details?transaction_id=$transactionId');
    return TransactionResponse.fromJson(response);
  }

  Future<TransactionPreviewResponse> previewTransaction(
      TransactionPreviewRequest request) async {
    final response = await post(
        'http://149.88.65.193:8010/api/transaction/preview',
        data: request.toJson());
    return TransactionPreviewResponse.fromJson(response);
  }
}
