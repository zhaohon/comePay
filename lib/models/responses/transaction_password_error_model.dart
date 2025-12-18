class TransactionPasswordErrorModel {
  final String error;

  TransactionPasswordErrorModel({
    required this.error,
  });

  factory TransactionPasswordErrorModel.fromJson(Map<String, dynamic> json) {
    return TransactionPasswordErrorModel(
      error: json['error'] ?? '',
    );
  }
}
