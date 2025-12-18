class ResetPasswordCreatePasswordResponseModel {
  final String message;
  final String status;

  ResetPasswordCreatePasswordResponseModel({
    required this.message,
    required this.status,
  });

  factory ResetPasswordCreatePasswordResponseModel.fromJson(
      Map<String, dynamic> json) {
    return ResetPasswordCreatePasswordResponseModel(
      message: json['message'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
    };
  }
}
