class CompleteTransactionPasswordResponseModel {
  final String message;
  final String status;

  CompleteTransactionPasswordResponseModel({
    required this.message,
    required this.status,
  });

  factory CompleteTransactionPasswordResponseModel.fromJson(
      Map<String, dynamic> json) {
    return CompleteTransactionPasswordResponseModel(
      message: json['message'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
    };
  }
}
