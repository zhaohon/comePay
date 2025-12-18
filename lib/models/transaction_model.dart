class Transaction {
  final int amount;
  final String currency;
  final String date;
  final String description;
  final String id;
  final String type;

  Transaction({
    required this.amount,
    required this.currency,
    required this.date,
    required this.description,
    required this.id,
    required this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: json['amount'],
      currency: json['currency'],
      date: json['date'],
      description: json['description'],
      id: json['id'],
      type: json['type'],
    );
  }
}
