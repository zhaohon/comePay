class PaymentCurrencyModel {
  final String name; // "USDT-TRC20"
  final String symbol; // "USDT"
  final String coinName; // "TRC20-USDT"
  final String logo;

  PaymentCurrencyModel({
    required this.name,
    required this.symbol,
    required this.coinName,
    required this.logo,
  });

  factory PaymentCurrencyModel.fromJson(Map<String, dynamic> json) {
    return PaymentCurrencyModel(
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      coinName: json['coin_name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'symbol': symbol,
      'coin_name': coinName,
      'logo': logo,
    };
  }
}
