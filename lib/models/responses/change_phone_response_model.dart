// Model untuk response change phone
class ChangePhoneResponseModel {
  final String message;
  final String newPhone;
  final String nextStep;
  final String otp;
  final String status;

  ChangePhoneResponseModel({
    required this.message,
    required this.newPhone,
    required this.nextStep,
    required this.otp,
    required this.status,
  });

  factory ChangePhoneResponseModel.fromJson(Map<String, dynamic> json) {
    return ChangePhoneResponseModel(
      message: json['message'] ?? '',
      newPhone: json['new_phone'] ?? '',
      nextStep: json['next_step'] ?? '',
      otp: json['otp'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'new_phone': newPhone,
      'next_step': nextStep,
      'otp': otp,
      'status': status,
    };
  }
}
