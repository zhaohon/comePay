class TransactionPasswordRequestModel {
  final String transactionPassword;
  final String confirmTransactionPassword;

  TransactionPasswordRequestModel({
    required this.transactionPassword,
    required this.confirmTransactionPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'transaction_password': transactionPassword,
      'confirm_transaction_password': confirmTransactionPassword,
    };
  }
}
