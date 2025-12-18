// Model untuk error response change password
class ChangePasswordErrorModel {
  final String error;

  ChangePasswordErrorModel({
    required this.error,
  });

  factory ChangePasswordErrorModel.fromJson(Map<String, dynamic> json) {
    return ChangePasswordErrorModel(
      error: json['error'] ?? 'Unknown error',
    );
  }
}
