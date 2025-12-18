class CardTrade {
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

  CardTrade({
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

  factory CardTrade.fromJson(Map<String, dynamic> json) {
    return CardTrade(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trade_total': tradeTotal,
      'amount': amount,
      'trade_fee': tradeFee,
      'trade_type': tradeType,
      'trade_reversal': tradeReversal,
      'trade_clear': tradeClear,
      'trade_remark': tradeRemark,
      'trade_time': tradeTime,
      'trade_exception': tradeException,
      'official_fee': officialFee,
      'extra_fee': extraFee,
      'fee_type': feeType,
      'official_trade_time': officialTradeTime,
      'bank_fee': bankFee,
      'reversal_time': reversalTime,
      'reversal_amount': reversalAmount,
      'clear_amount': clearAmount,
      'clear_time': clearTime,
      'official_clear_time': officialClearTime,
      'merchant_amount': merchantAmount,
      'merchant_name': merchantName,
      'merchant_currency': merchantCurrency,
      'merchant_country': merchantCountry,
      'merchant_city': merchantCity,
      'currency_id': currencyId,
      'currency_code': currencyCode,
      'trace_id': traceId,
      'master_id': masterId,
      'card_id': cardId,
      'card_number': cardNumber,
    };
  }
}

class CardTradeData {
  final int pageSize;
  final int pageNum;
  final List<CardTrade> trades;
  final int total;

  CardTradeData({
    required this.pageSize,
    required this.pageNum,
    required this.trades,
    required this.total,
  });

  factory CardTradeData.fromJson(Map<String, dynamic> json) {
    return CardTradeData(
      pageSize: json['page_size'],
      pageNum: json['page_num'],
      trades: (json['trades'] as List).map((item) => CardTrade.fromJson(item)).toList(),
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page_size': pageSize,
      'page_num': pageNum,
      'trades': trades.map((trade) => trade.toJson()).toList(),
      'total': total,
    };
  }
}

class CardTradeResponse {
  final String requestId;
  final int code;
  final String errstr;
  final CardTradeData data;

  CardTradeResponse({
    required this.requestId,
    required this.code,
    required this.errstr,
    required this.data,
  });

  factory CardTradeResponse.fromJson(Map<String, dynamic> json) {
    return CardTradeResponse(
      requestId: json['request_id'],
      code: json['code'],
      errstr: json['errstr'],
      data: CardTradeData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'code': code,
      'errstr': errstr,
      'data': data.toJson(),
    };
  }
}
