// Model for Didit token data
class DiditTokenData {
  final int code;
  final DiditTokenInnerData data;
  final String errstr;
  final String requestId;

  DiditTokenData({
    required this.code,
    required this.data,
    required this.errstr,
    required this.requestId,
  });

  factory DiditTokenData.fromJson(Map<String, dynamic> json) {
    return DiditTokenData(
      code: json['code'] ?? 0,
      data: DiditTokenInnerData.fromJson(json['data'] ?? {}),
      errstr: json['errstr'] ?? '',
      requestId: json['request_id'] ?? '',
    );
  }
}

// Inner data model
class DiditTokenInnerData {
  final String sessionId;
  final String url;

  DiditTokenInnerData({
    required this.sessionId,
    required this.url,
  });

  factory DiditTokenInnerData.fromJson(Map<String, dynamic> json) {
    return DiditTokenInnerData(
      sessionId: json['session_id'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

// Model for Didit initialize token success response
class DiditInitializeTokenResponseModel {
  final DiditTokenData diditToken;
  final int userKycId;
  final String verificationId;

  DiditInitializeTokenResponseModel({
    required this.diditToken,
    required this.userKycId,
    required this.verificationId,
  });

  factory DiditInitializeTokenResponseModel.fromJson(Map<String, dynamic> json) {
    return DiditInitializeTokenResponseModel(
      diditToken: DiditTokenData.fromJson(json['didit_token'] ?? {}),
      userKycId: json['user_kyc_id'] ?? 0,
      verificationId: json['verification_id'] ?? '',
    );
  }
}
