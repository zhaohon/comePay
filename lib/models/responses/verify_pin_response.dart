// Model untuk response verifikasi PIN
class VerifyPinResponse {
  final String apiName;
  final int code;
  final VerifyPinData data;
  final String date;
  final String message;
  final String version;

  VerifyPinResponse({
    required this.apiName,
    required this.code,
    required this.data,
    required this.date,
    required this.message,
    required this.version,
  });

  factory VerifyPinResponse.fromJson(Map<String, dynamic> json) {
    return VerifyPinResponse(
      apiName: json['api-name'] ?? '',
      code: json['code'] ?? 0,
      data: VerifyPinData.fromJson(json['data'] ?? {}),
      date: json['date'] ?? '',
      message: json['message'] ?? '',
      version: json['version'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'api-name': apiName,
      'code': code,
      'data': data.toJson(),
      'date': date,
      'message': message,
      'version': version,
    };
  }
}

class VerifyPinData {
  final bool verified;
  final String message;

  VerifyPinData({
    required this.verified,
    required this.message,
  });

  factory VerifyPinData.fromJson(Map<String, dynamic> json) {
    return VerifyPinData(
      verified: json['verified'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verified': verified,
      'message': message,
    };
  }
}
