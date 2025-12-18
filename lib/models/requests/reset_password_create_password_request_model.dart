class ResetPasswordCreatePasswordRequestModel {
  final String email;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordCreatePasswordRequestModel({
    required this.email,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }
}
