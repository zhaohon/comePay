// Note: kyc_model.dart has KycModel.
// latest_kyc in response might be slightly different or same.
// Doc says LatestKycInfo. Let's create a specific model or reuse if partial match.
// KycModel has many fields. LatestKycInfo has a subset + pokepay_status.
// I will create a dedicated inner class or file for LatestKycInfo if needed,
// but for simplicity I can put it in the same file.

class KycStatusResponseModel {
  final bool canSubmitKyc;
  final LatestKycInfo? latestKyc;
  final String message;
  final String userKycStatus;

  KycStatusResponseModel({
    required this.canSubmitKyc,
    this.latestKyc,
    required this.message,
    required this.userKycStatus,
  });

  factory KycStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return KycStatusResponseModel(
      canSubmitKyc: json['can_submit_kyc'] ?? false,
      latestKyc: json['latest_kyc'] != null
          ? LatestKycInfo.fromJson(json['latest_kyc'])
          : null,
      message: json['message'] ?? '',
      userKycStatus: json['user_kyc_status'] ?? '',
    );
  }
}

class LatestKycInfo {
  final String agentUid;
  final String createdAt;
  final String failReason;
  final int id;
  final int pokepayStatus;
  final String status;
  final String updatedAt;

  LatestKycInfo({
    required this.agentUid,
    required this.createdAt,
    required this.failReason,
    required this.id,
    required this.pokepayStatus,
    required this.status,
    required this.updatedAt,
  });

  factory LatestKycInfo.fromJson(Map<String, dynamic> json) {
    return LatestKycInfo(
      agentUid: json['agent_uid'] ?? '',
      createdAt: json['created_at'] ?? '',
      failReason: json['fail_reason'] ?? '',
      id: json['id'] ?? 0,
      pokepayStatus: json['pokepay_status'] ?? 0,
      status: json['status'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
