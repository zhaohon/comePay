class CarddetailModel {
  final int id;
  final int createdTime;
  final int updatedTime;
  final int deletedTime;
  final int agentId;
  final String publicToken;
  final int crossBorderFee;
  final String cardNo;
  final int isRecharge;
  final int isWithdraw;
  final String cardScheme;
  final int cardExpiry;
  final int rechargeMin;
  final int rechargeMax;
  final int withdrawMin;
  final int withdrawMax;
  final int singleQuota;
  final int dayQuota;
  final int monthQuota;
  final int amount;
  final int upgradeAmount;
  final int rechargeFee;
  final int withdrawFee;
  final int transactionFee;
  final String status;
  final String expiryDate;
  final int cardId;
  final int kycId;
  final String memberName;
  final int currencyId;
  final String currencyCode;
  final bool physical;
  final String billAddress;
  final String postalCode;
  final int balance;
  final int activateTime;

  CarddetailModel({
    required this.id,
    required this.createdTime,
    required this.updatedTime,
    required this.deletedTime,
    required this.agentId,
    required this.publicToken,
    required this.crossBorderFee,
    required this.cardNo,
    required this.isRecharge,
    required this.isWithdraw,
    required this.cardScheme,
    required this.cardExpiry,
    required this.rechargeMin,
    required this.rechargeMax,
    required this.withdrawMin,
    required this.withdrawMax,
    required this.singleQuota,
    required this.dayQuota,
    required this.monthQuota,
    required this.amount,
    required this.upgradeAmount,
    required this.rechargeFee,
    required this.withdrawFee,
    required this.transactionFee,
    required this.status,
    required this.expiryDate,
    required this.cardId,
    required this.kycId,
    required this.memberName,
    required this.currencyId,
    required this.currencyCode,
    required this.physical,
    required this.billAddress,
    required this.postalCode,
    required this.balance,
    required this.activateTime,
  });

  factory CarddetailModel.fromJson(Map<String, dynamic> json) {
    return CarddetailModel(
      id: json['id'] ?? 0,
      createdTime: json['created_time'] ?? 0,
      updatedTime: json['updated_time'] ?? 0,
      deletedTime: json['deleted_time'] ?? 0,
      agentId: json['agent_id'] ?? 0,
      publicToken: json['public_token'] ?? '',
      crossBorderFee: json['cross_border_fee'] ?? 0,
      cardNo: json['card_no'] ?? '',
      isRecharge: json['is_recharge'] ?? 0,
      isWithdraw: json['is_withdraw'] ?? 0,
      cardScheme: json['card_scheme'] ?? '',
      cardExpiry: json['card_expiry'] ?? 0,
      rechargeMin: json['recharge_min'] ?? 0,
      rechargeMax: json['recharge_max'] ?? 0,
      withdrawMin: json['withdraw_min'] ?? 0,
      withdrawMax: json['withdraw_max'] ?? 0,
      singleQuota: json['single_quota'] ?? 0,
      dayQuota: json['day_quota'] ?? 0,
      monthQuota: json['month_quota'] ?? 0,
      amount: json['amount'] ?? 0,
      upgradeAmount: json['upgrade_amount'] ?? 0,
      rechargeFee: json['recharge_fee'] ?? 0,
      withdrawFee: json['withdraw_fee'] ?? 0,
      transactionFee: json['transaction_fee'] ?? 0,
      status: json['status'] ?? '',
      expiryDate: json['expiry_date'] ?? '',
      cardId: json['card_id'] ?? 0,
      kycId: json['kyc_id'] ?? 0,
      memberName: json['member_name'] ?? '',
      currencyId: json['currency_id'] ?? 0,
      currencyCode: json['currency_code'] ?? '',
      physical: json['physical'] ?? false,
      billAddress: json['bill_address'] ?? '',
      postalCode: json['postal_code'] ?? '',
      balance: json['balance'] ?? 0,
      activateTime: json['activate_time'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_time': createdTime,
      'updated_time': updatedTime,
      'deleted_time': deletedTime,
      'agent_id': agentId,
      'public_token': publicToken,
      'cross_border_fee': crossBorderFee,
      'card_no': cardNo,
      'is_recharge': isRecharge,
      'is_withdraw': isWithdraw,
      'card_scheme': cardScheme,
      'card_expiry': cardExpiry,
      'recharge_min': rechargeMin,
      'recharge_max': rechargeMax,
      'withdraw_min': withdrawMin,
      'withdraw_max': withdrawMax,
      'single_quota': singleQuota,
      'day_quota': dayQuota,
      'month_quota': monthQuota,
      'amount': amount,
      'upgrade_amount': upgradeAmount,
      'recharge_fee': rechargeFee,
      'withdraw_fee': withdrawFee,
      'transaction_fee': transactionFee,
      'status': status,
      'expiry_date': expiryDate,
      'card_id': cardId,
      'kyc_id': kycId,
      'member_name': memberName,
      'currency_id': currencyId,
      'currency_code': currencyCode,
      'physical': physical,
      'bill_address': billAddress,
      'postal_code': postalCode,
      'balance': balance,
      'activate_time': activateTime,
    };
  }
}



class CarddetailResponseModel {
  final String apiName;
  final int code;
  final CarddetailModel? data;
  final String date;
  final String message;
  final String version;

  CarddetailResponseModel({
    required this.apiName,
    required this.code,
    required this.data,
    required this.date,
    required this.message,
    required this.version,
  });

  factory CarddetailResponseModel.fromJson(Map<String, dynamic> json) {
    return CarddetailResponseModel(
      apiName: json['api-name'] ?? '',
      code: json['code'] ?? 0,
      data: json['data'] != null
          ? CarddetailModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      date: json['date'] ?? '',
      message: json['message'] ?? '',
      version: json['version'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'api-name': apiName,
      'code': code,
      'data': data?.toJson(), // object
      'date': date,
      'message': message,
      'version': version,
    };
  }
}