// Model untuk response email validation error
class EmailValidationErrorModel {
  final String error;

  EmailValidationErrorModel({
    required this.error,
  });

  factory EmailValidationErrorModel.fromJson(Map<String, dynamic> json) {
    return EmailValidationErrorModel(
      error: json['error'] ?? 'Unknown error',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
    };
  }
}
