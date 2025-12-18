class CreateWalletErrorModel {
  final String error;
  final String? message;

  CreateWalletErrorModel({
    required this.error,
    this.message,
  });

  factory CreateWalletErrorModel.fromJson(Map<String, dynamic> json) {
    return CreateWalletErrorModel(
      error: json['error'] ?? '',
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
    };
  }
}
