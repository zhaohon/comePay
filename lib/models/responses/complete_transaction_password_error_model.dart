class CompleteTransactionPasswordErrorModel {
  final String error;

  CompleteTransactionPasswordErrorModel({
    required this.error,
  });

  factory CompleteTransactionPasswordErrorModel.fromJson(
      Map<String, dynamic> json) {
    return CompleteTransactionPasswordErrorModel(
      error: json['error'] ?? '',
    );
  }
}
