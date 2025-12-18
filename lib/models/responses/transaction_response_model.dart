class TransactionResponse {
  final List<Transaction> transactions;
  final String message;
  final String status;

  TransactionResponse({
    required this.transactions,
    required this.message,
    required this.status,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      transactions: (json['data']['transactions'] as List)
          .map((item) => Transaction.fromJson(item))
          .toList(),
      message: json['message'],
      status: json['status'],
    );
  }
}

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
