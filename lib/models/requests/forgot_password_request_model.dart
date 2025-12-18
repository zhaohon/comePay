// Model untuk request forgot password
class ForgotPasswordRequestModel {
  final String email;

  ForgotPasswordRequestModel({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}
