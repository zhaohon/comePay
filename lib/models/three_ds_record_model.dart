class ThreeDSRecordModel {
  final int id;
  final String merchantName;
  final String amount;
  final String currency;
  final String? passcode;
  final String receivedAt;
  final int expiresAfter;

  // 额外添加 BIO 相关的字段
  final String? authMethod;
  final String? challengeStatus;
  final String? confirmationStatus;
  final String? confirmedAt;

  ThreeDSRecordModel({
    required this.id,
    required this.merchantName,
    required this.amount,
    required this.currency,
    this.passcode,
    required this.receivedAt,
    required this.expiresAfter,
    this.authMethod,
    this.challengeStatus,
    this.confirmationStatus,
    this.confirmedAt,
  });

  factory ThreeDSRecordModel.fromJson(Map<String, dynamic> json) {
    return ThreeDSRecordModel(
      id: json['id'] as int? ?? 0,
      merchantName: json['merchant_name']?.toString() ?? 'Unknown',
      amount: json['amount']?.toString() ?? '0',
      currency: json['currency']?.toString() ?? '',
      passcode: json['passcode']?.toString(),
      receivedAt: json['received_at']?.toString() ?? '',
      expiresAfter: json['expires_after'] as int? ?? 600,
      authMethod: json['auth_method']?.toString(),
      challengeStatus: json['challenge_status']?.toString(),
      confirmationStatus: json['confirmation_status']?.toString(),
      confirmedAt: json['confirmed_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_name': merchantName,
      'amount': amount,
      'currency': currency,
      'passcode': passcode,
      'received_at': receivedAt,
      'expires_after': expiresAfter,
      'auth_method': authMethod,
      'challenge_status': challengeStatus,
      'confirmation_status': confirmationStatus,
      'confirmed_at': confirmedAt,
    };
  }
}

class GetThreeDSRecordsResponse {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final List<ThreeDSRecordModel> records;

  GetThreeDSRecordsResponse({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.records,
  });

  factory GetThreeDSRecordsResponse.fromJson(Map<String, dynamic> json) {
    return GetThreeDSRecordsResponse(
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      records: (json['records'] as List<dynamic>?)
              ?.map(
                  (e) => ThreeDSRecordModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'total': total,
      'total_pages': totalPages,
      'records': records.map((e) => e.toJson()).toList(),
    };
  }
}
