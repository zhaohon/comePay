class TransactionPreviewResponse {
  final String apiName;
  final int code;
  final TransactionPreviewData data;
  final String date;
  final String message;
  final String version;

  TransactionPreviewResponse({
    required this.apiName,
    required this.code,
    required this.data,
    required this.date,
    required this.message,
    required this.version,
  });

  factory TransactionPreviewResponse.fromJson(Map<String, dynamic> json) {
    return TransactionPreviewResponse(
      apiName: json['api-name'],
      code: json['code'],
      data: TransactionPreviewData.fromJson(json['data']),
      date: json['date'],
      message: json['message'],
      version: json['version'],
    );
  }
}

class TransactionPreviewData {
  final String confirmId;
  final String fromUser;
  final String toAddress;
  final String tokenSymbol;
  final String network;
  final double amount;
  final double fee;
  final double total;

  TransactionPreviewData({
    required this.confirmId,
    required this.fromUser,
    required this.toAddress,
    required this.tokenSymbol,
    required this.network,
    required this.amount,
    required this.fee,
    required this.total,
  });

  factory TransactionPreviewData.fromJson(Map<String, dynamic> json) {
    return TransactionPreviewData(
      confirmId: json['confirm_id'],
      fromUser: json['from_user'],
      toAddress: json['to_address'],
      tokenSymbol: json['token_symbol'],
      network: json['network'],
      amount: json['amount'].toDouble(),
      fee: json['fee'].toDouble(),
      total: json['total'].toDouble(),
    );
  }
}
