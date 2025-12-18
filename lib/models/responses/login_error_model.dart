// Model untuk response error
class LoginErrorModel {
  final String error;

  LoginErrorModel({
    required this.error,
  });

  factory LoginErrorModel.fromJson(Map<String, dynamic> json) {
    return LoginErrorModel(
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
    };
  }
}
