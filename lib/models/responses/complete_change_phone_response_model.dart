// Model untuk response complete change phone
class CompleteChangePhoneResponseModel {
  final String message;
  final String phone;
  final String status;

  CompleteChangePhoneResponseModel({
    required this.message,
    required this.phone,
    required this.status,
  });

  factory CompleteChangePhoneResponseModel.fromJson(Map<String, dynamic> json) {
    return CompleteChangePhoneResponseModel(
      message: json['message'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
