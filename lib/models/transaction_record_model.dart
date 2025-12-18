class TransactionRecord {
  final int id;
  final double tradeTotal;
  final double amount;
  final double tradeFee;
  final int tradeType;
  final int tradeReversal;
  final int tradeClear;
  final String tradeRemark;
  final String tradeTime;
  final int tradeException;
  final double officialFee;
  final double extraFee;
  final int feeType;
  final String officialTradeTime;
  final double bankFee;
  final String reversalTime;
  final double reversalAmount;
  final double clearAmount;
  final String clearTime;
  final String officialClearTime;
  final double merchantAmount;
  final String merchantName;
  final String merchantCurrency;
  final String merchantCountry;
  final String merchantCity;
  final int currencyId;
  final String currencyCode;
  final String traceId;
  final int masterId;
  final int cardId;
  final String cardNumber;

  TransactionRecord({
    required this.id,
    required this.tradeTotal,
    required this.amount,
    required this.tradeFee,
    required this.tradeType,
    required this.tradeReversal,
    required this.tradeClear,
    required this.tradeRemark,
    required this.tradeTime,
    required this.tradeException,
    required this.officialFee,
    required this.extraFee,
    required this.feeType,
    required this.officialTradeTime,
    required this.bankFee,
    required this.reversalTime,
    required this.reversalAmount,
    required this.clearAmount,
    required this.clearTime,
    required this.officialClearTime,
    required this.merchantAmount,
    required this.merchantName,
    required this.merchantCurrency,
    required this.merchantCountry,
    required this.merchantCity,
    required this.currencyId,
    required this.currencyCode,
    required this.traceId,
    required this.masterId,
    required this.cardId,
    required this.cardNumber,
  });

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      id: json['id'],
      tradeTotal: json['trade_total'].toDouble(),
      amount: json['amount'].toDouble(),
      tradeFee: json['trade_fee'].toDouble(),
      tradeType: json['trade_type'],
      tradeReversal: json['trade_reversal'],
      tradeClear: json['trade_clear'],
      tradeRemark: json['trade_remark'],
      tradeTime: json['trade_time'],
      tradeException: json['trade_exception'],
      officialFee: json['official_fee'].toDouble(),
      extraFee: json['extra_fee'].toDouble(),
      feeType: json['fee_type'],
      officialTradeTime: json['official_trade_time'],
      bankFee: json['bank_fee'].toDouble(),
      reversalTime: json['reversal_time'],
      reversalAmount: json['reversal_amount'].toDouble(),
      clearAmount: json['clear_amount'].toDouble(),
      clearTime: json['clear_time'],
      officialClearTime: json['official_clear_time'],
      merchantAmount: json['merchant_amount'].toDouble(),
      merchantName: json['merchant_name'],
      merchantCurrency: json['merchant_currency'],
      merchantCountry: json['merchant_country'],
      merchantCity: json['merchant_city'],
      currencyId: json['currency_id'],
      currencyCode: json['currency_code'],
      traceId: json['trace_id'],
      masterId: json['master_id'],
      cardId: json['card_id'],
      cardNumber: json['card_number'],
    );
  }
}

class TransactionRecordResponse {
  final String apiName;
  final int code;
  final List<TransactionRecord> data;
  final String date;
  final String message;
  final String version;

  TransactionRecordResponse({
    required this.apiName,
    required this.code,
    required this.data,
    required this.date,
    required this.message,
    required this.version,
  });

  factory TransactionRecordResponse.fromJson(Map<String, dynamic> json) {
    return TransactionRecordResponse(
      apiName: json['api-name'],
      code: json['code'],
      data: (json['data'] as List).map((item) => TransactionRecord.fromJson(item)).toList(),
      date: json['date'],
      message: json['message'],
      version: json['version'],
    );
  }
}
