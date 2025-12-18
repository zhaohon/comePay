// Model untuk response complete change email sukses
class CompleteChangeEmailResponseModel {
  final String message;
  final String newEmail;
  final String status;

  CompleteChangeEmailResponseModel({
    required this.message,
    required this.newEmail,
    required this.status,
  });

  factory CompleteChangeEmailResponseModel.fromJson(Map<String, dynamic> json) {
    return CompleteChangeEmailResponseModel(
      message: json['message'] ?? '',
      newEmail: json['new_email'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'new_email': newEmail,
      'status': status,
    };
  }
}
