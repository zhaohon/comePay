class CardModel {
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
  final double rechargeMin;
  final double rechargeMax;
  final double withdrawMin;
  final double withdrawMax;
  final double singleQuota;
  final double dayQuota;
  final double monthQuota;
  final double amount;
  final double upgradeAmount;
  final double rechargeFee;
  final double withdrawFee;
  final double transactionFee;
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
  final double balance;
  final int activateTime;
  final int convertedCurrencyId;
  final String convertedCurrencyCode;
  final double convertedRechargeMin;
  final double convertedRechargeMax;
  final double convertedWithdrawMin;
  final double convertedWithdrawMax;
  final double convertedSingleQuota;
  final double convertedDayQuota;
  final double convertedMonthQuota;
  final double convertedAmount;
  final double convertedUpgradeAmount;
  final double convertedRechargeFee;
  final double convertedWithdrawFee;
  final double convertedTransactionFee;
  final double convertedBalance;

  CardModel({
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
    required this.convertedCurrencyId,
    required this.convertedCurrencyCode,
    required this.convertedRechargeMin,
    required this.convertedRechargeMax,
    required this.convertedWithdrawMin,
    required this.convertedWithdrawMax,
    required this.convertedSingleQuota,
    required this.convertedDayQuota,
    required this.convertedMonthQuota,
    required this.convertedAmount,
    required this.convertedUpgradeAmount,
    required this.convertedRechargeFee,
    required this.convertedWithdrawFee,
    required this.convertedTransactionFee,
    required this.convertedBalance,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
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
      rechargeMin: (json['recharge_min'] as num?)?.toDouble() ?? 0.0,
      rechargeMax: (json['recharge_max'] as num?)?.toDouble() ?? 0.0,
      withdrawMin: (json['withdraw_min'] as num?)?.toDouble() ?? 0.0,
      withdrawMax: (json['withdraw_max'] as num?)?.toDouble() ?? 0.0,
      singleQuota: (json['single_quota'] as num?)?.toDouble() ?? 0.0,
      dayQuota: (json['day_quota'] as num?)?.toDouble() ?? 0.0,
      monthQuota: (json['month_quota'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      upgradeAmount: (json['upgrade_amount'] as num?)?.toDouble() ?? 0.0,
      rechargeFee: (json['recharge_fee'] as num?)?.toDouble() ?? 0.0,
      withdrawFee: (json['withdraw_fee'] as num?)?.toDouble() ?? 0.0,
      transactionFee: (json['transaction_fee'] as num?)?.toDouble() ?? 0.0,
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
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      activateTime: json['activate_time'] ?? 0,
      convertedCurrencyId: json['converted_currency_id'] ?? 0,
      convertedCurrencyCode: json['converted_currency_code'] ?? '',
      convertedRechargeMin: (json['converted_recharge_min'] as num?)?.toDouble() ?? 0.0,
      convertedRechargeMax: (json['converted_recharge_max'] as num?)?.toDouble() ?? 0.0,
      convertedWithdrawMin: (json['converted_withdraw_min'] as num?)?.toDouble() ?? 0.0,
      convertedWithdrawMax: (json['converted_withdraw_max'] as num?)?.toDouble() ?? 0.0,
      convertedSingleQuota: (json['converted_single_quota'] as num?)?.toDouble() ?? 0.0,
      convertedDayQuota: (json['converted_day_quota'] as num?)?.toDouble() ?? 0.0,
      convertedMonthQuota: (json['converted_month_quota'] as num?)?.toDouble() ?? 0.0,
      convertedAmount: (json['converted_amount'] as num?)?.toDouble() ?? 0.0,
      convertedUpgradeAmount: (json['converted_upgrade_amount'] as num?)?.toDouble() ?? 0.0,
      convertedRechargeFee: (json['converted_recharge_fee'] as num?)?.toDouble() ?? 0.0,
      convertedWithdrawFee: (json['converted_withdraw_fee'] as num?)?.toDouble() ?? 0.0,
      convertedTransactionFee: (json['converted_transaction_fee'] as num?)?.toDouble() ?? 0.0,
      convertedBalance: (json['converted_balance'] as num?)?.toDouble() ?? 0.0,
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
      'converted_currency_id': convertedCurrencyId,
      'converted_currency_code': convertedCurrencyCode,
      'converted_recharge_min': convertedRechargeMin,
      'converted_recharge_max': convertedRechargeMax,
      'converted_withdraw_min': convertedWithdrawMin,
      'converted_withdraw_max': convertedWithdrawMax,
      'converted_single_quota': convertedSingleQuota,
      'converted_day_quota': convertedDayQuota,
      'converted_month_quota': convertedMonthQuota,
      'converted_amount': convertedAmount,
      'converted_upgrade_amount': convertedUpgradeAmount,
      'converted_recharge_fee': convertedRechargeFee,
      'converted_withdraw_fee': convertedWithdrawFee,
      'converted_transaction_fee': convertedTransactionFee,
      'converted_balance': convertedBalance,
    };
  }
}

class CardResponseModel {
  final String apiName;
  final int code;
  final List<CardModel> data;
  final String date;
  final String message;
  final String version;

  CardResponseModel({
    required this.apiName,
    required this.code,
    required this.data,
    required this.date,
    required this.message,
    required this.version,
  });

  factory CardResponseModel.fromJson(Map<String, dynamic> json) {
    return CardResponseModel(
      apiName: json['api-name'] ?? '',
      code: json['code'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => CardModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      date: json['date'] ?? '',
      message: json['message'] ?? '',
      version: json['version'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'api-name': apiName,
      'code': code,
      'data': data.map((item) => item.toJson()).toList(),
      'date': date,
      'message': message,
      'version': version,
    };
  }
}
