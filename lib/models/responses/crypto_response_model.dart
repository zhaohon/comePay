class CryptoResponse {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final List<double> sparklineIn7d;

  CryptoResponse({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.sparklineIn7d,
  });

  factory CryptoResponse.fromJson(Map<String, dynamic> json) {
    return CryptoResponse(
      id: json['id'],
      symbol: json['symbol'],
      name: json['name'],
      image: json['image'],
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      priceChange24h: (json['price_change_24h'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage24h: (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      sparklineIn7d: json['sparkline_in_7d'] != null ? List<double>.from(json['sparkline_in_7d']['price']) : [],
    );
  }
}
