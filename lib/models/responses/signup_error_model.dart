// Model untuk response signup error
class SignupErrorModel {
  final String error;

  SignupErrorModel({
    required this.error,
  });

  factory SignupErrorModel.fromJson(Map<String, dynamic> json) {
    return SignupErrorModel(
      error: json['error'] ?? 'Unknown error',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
    };
  }
}
