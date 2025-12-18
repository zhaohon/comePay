class TransactionPreviewRequest {
  final String toAddress;
  final String tokenSymbol;
  final String network;
  final String amount;

  TransactionPreviewRequest({
    required this.toAddress,
    required this.tokenSymbol,
    required this.network,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'to_address': toAddress,
      'token_symbol': tokenSymbol,
      'network': network,
      'amount': amount,
    };
  }
}
