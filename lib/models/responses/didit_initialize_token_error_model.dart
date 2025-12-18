// Model for Didit initialize token error response
class DiditInitializeTokenErrorModel {
  final String message;

  DiditInitializeTokenErrorModel({
    required this.message,
  });

  factory DiditInitializeTokenErrorModel.fromJson(Map<String, dynamic> json) {
    return DiditInitializeTokenErrorModel(
      message: json['message'] ?? 'Unknown error',
    );
  }
}
