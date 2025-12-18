// Model untuk request change password
class ChangePasswordRequestModel {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordRequestModel({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'old_password': oldPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }
}
