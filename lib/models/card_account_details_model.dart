/// 卡片详情（含余额）模型
/// 对应 API: GET /api/v1/card/account-details
class CardAccountDetailsModel {
  final int id;
  final String publicToken;
  final String cardNo; // 脱敏卡号
  final String cardScheme; // "visa" or "mastercard"
  final String currencyCode; // 币种代码，如 "HKD"
  final double balance; // 卡片余额
  final String status; // "normal", "frozen", "cancelled"
  final String expiryDate; // 到期日期
  final int activateTime; // 激活时间（时间戳）
  final bool physical; // 是否为实体卡
  final double rechargeMin; // 充值最小限额
  final double rechargeMax; // 充值最大限额
  final double rechargeFee; // 充值手续费率 (%)
  final double withdrawMin; // 提现最小限额
  final double withdrawMax; // 提现最大限额
  final double withdrawFee; // 提现手续费率 (%)
  final double singleQuota; // 单笔消费限额
  final double dayQuota; // 日消费限额
  final double monthQuota; // 月消费限额
  final double transactionFee; // 消费手续费率 (%)
  final double crossBorderFee; // 跨境手续费率 (%)
  final double upgradeAmount; // 升级实体卡费用

  CardAccountDetailsModel({
    required this.id,
    required this.publicToken,
    required this.cardNo,
    required this.cardScheme,
    required this.currencyCode,
    required this.balance,
    required this.status,
    required this.expiryDate,
    required this.activateTime,
    required this.physical,
    required this.rechargeMin,
    required this.rechargeMax,
    required this.rechargeFee,
    required this.withdrawMin,
    required this.withdrawMax,
    required this.withdrawFee,
    required this.singleQuota,
    required this.dayQuota,
    required this.monthQuota,
    required this.transactionFee,
    required this.crossBorderFee,
    required this.upgradeAmount,
  });

  factory CardAccountDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    return CardAccountDetailsModel(
      id: data['id'] as int? ?? 0,
      publicToken: data['public_token'] as String? ?? '',
      cardNo: data['card_no'] as String? ?? '',
      cardScheme: data['card_scheme'] as String? ?? '',
      currencyCode: data['currency_code'] as String? ?? '',
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? '',
      expiryDate: data['expiry_date'] as String? ?? '',
      activateTime: data['activate_time'] as int? ?? 0,
      physical: data['physical'] as bool? ?? false,
      rechargeMin: (data['recharge_min'] as num?)?.toDouble() ?? 0.0,
      rechargeMax: (data['recharge_max'] as num?)?.toDouble() ?? 0.0,
      rechargeFee: (data['recharge_fee'] as num?)?.toDouble() ?? 0.0,
      withdrawMin: (data['withdraw_min'] as num?)?.toDouble() ?? 0.0,
      withdrawMax: (data['withdraw_max'] as num?)?.toDouble() ?? 0.0,
      withdrawFee: (data['withdraw_fee'] as num?)?.toDouble() ?? 0.0,
      singleQuota: (data['single_quota'] as num?)?.toDouble() ?? 0.0,
      dayQuota: (data['day_quota'] as num?)?.toDouble() ?? 0.0,
      monthQuota: (data['month_quota'] as num?)?.toDouble() ?? 0.0,
      transactionFee: (data['transaction_fee'] as num?)?.toDouble() ?? 0.0,
      crossBorderFee: (data['cross_border_fee'] as num?)?.toDouble() ?? 0.0,
      upgradeAmount: (data['upgrade_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

