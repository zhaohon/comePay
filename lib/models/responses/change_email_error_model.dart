// Model untuk response error change email
class ChangeEmailErrorModel {
  final String error;

  ChangeEmailErrorModel({
    required this.error,
  });

  factory ChangeEmailErrorModel.fromJson(Map<String, dynamic> json) {
    return ChangeEmailErrorModel(
      error: json['error'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
    };
  }
}
