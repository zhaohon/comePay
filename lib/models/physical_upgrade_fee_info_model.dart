import 'package:comecomepay/models/payment_currency_model.dart';

class PhysicalUpgradeFeeInfoModel {
  final List<PaymentCurrencyModel> currencies;
  final double upgradeAmount;

  PhysicalUpgradeFeeInfoModel({
    required this.currencies,
    required this.upgradeAmount,
  });

  factory PhysicalUpgradeFeeInfoModel.fromJson(Map<String, dynamic> json) {
    var currenciesList = json['currencies'] as List? ?? [];
    List<PaymentCurrencyModel> currencies = currenciesList
        .map((e) => PaymentCurrencyModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PhysicalUpgradeFeeInfoModel(
      currencies: currencies,
      upgradeAmount: (json['upgrade_amount'] is num)
          ? (json['upgrade_amount'] as num).toDouble()
          : double.tryParse(json['upgrade_amount'].toString()) ?? 0.0,
    );
  }
}
