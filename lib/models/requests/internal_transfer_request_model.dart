class InternalTransferRequestModel {
  final double amount;
  final String currency;
  final String description;
  final int recipientUid;
  final String transactionPassword;

  InternalTransferRequestModel({
    required this.amount,
    required this.currency,
    this.description = '',
    required this.recipientUid,
    required this.transactionPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'description': description,
      'recipient_uid': recipientUid,
      'transaction_password': transactionPassword,
    };
  }
}
