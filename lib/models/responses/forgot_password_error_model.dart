// Model untuk response error forgot password
class ForgotPasswordErrorModel {
  final String error;

  ForgotPasswordErrorModel({
    required this.error,
  });

  factory ForgotPasswordErrorModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordErrorModel(
      error: json['error'] ?? 'Unknown error',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
    };
  }
}
