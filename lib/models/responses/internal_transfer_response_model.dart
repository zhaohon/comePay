class InternalTransferResponseModel {
  final String status;
  final String message;
  final String currency;
  final double newBalance;
  final int recipientUid;
  final String recipientWalletId;
  final int transactionId;

  InternalTransferResponseModel({
    required this.status,
    required this.message,
    required this.currency,
    required this.newBalance,
    required this.recipientUid,
    required this.recipientWalletId,
    required this.transactionId,
  });

  factory InternalTransferResponseModel.fromJson(Map<String, dynamic> json) {
    return InternalTransferResponseModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      currency: json['currency'] ?? '',
      newBalance: (json['new_balance'] ?? 0).toDouble(),
      recipientUid: json['recipient_uid'] ?? 0,
      recipientWalletId: json['recipient_wallet_id'] ?? '',
      transactionId: json['transaction_id'] ?? 0,
    );
  }
}
