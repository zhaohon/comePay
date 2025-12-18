// Model untuk error response complete change phone
class CompleteChangePhoneErrorModel {
  final String error;

  CompleteChangePhoneErrorModel({
    required this.error,
  });

  factory CompleteChangePhoneErrorModel.fromJson(Map<String, dynamic> json) {
    return CompleteChangePhoneErrorModel(
      error: json['error'] ?? 'Unknown error',
    );
  }
}
