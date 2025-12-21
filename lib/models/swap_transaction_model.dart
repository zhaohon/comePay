class SwapTransaction {
  final int id;
  final int userId;
  final int walletId;
  final String fromCurrency;
  final String toCurrency;
  final double fromAmount;
  final double toAmount;
  final double exchangeRate;
  final double fee;
  final String status;
  final String? quoteId;
  final String? pokePayRef;
  final String? pokePayType;
  final String createdAt;
  final String? completedAt;

  SwapTransaction({
    required this.id,
    required this.userId,
    required this.walletId,
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromAmount,
    required this.toAmount,
    required this.exchangeRate,
    required this.fee,
    required this.status,
    this.quoteId,
    this.pokePayRef,
    this.pokePayType,
    required this.createdAt,
    this.completedAt,
  });

  factory SwapTransaction.fromJson(Map<String, dynamic> json) {
    return SwapTransaction(
      id: json['id'],
      userId: json['user_id'],
      walletId: json['wallet_id'],
      fromCurrency: json['from_currency'],
      toCurrency: json['to_currency'],
      fromAmount: (json['from_amount'] ?? 0).toDouble(),
      toAmount: (json['to_amount'] ?? 0).toDouble(),
      exchangeRate: (json['exchange_rate'] ?? 0).toDouble(),
      fee: (json['fee'] ?? 0).toDouble(),
      status: json['status'],
      quoteId: json['quote_id'],
      pokePayRef: json['poke_pay_ref'],
      pokePayType: json['poke_pay_type'],
      createdAt: json['created_at'],
      completedAt: json['completed_at'],
    );
  }
}

class SwapHistoryResponse {
  final List<SwapTransaction> transactions;
  final int page;
  final int limit;
  final int total;

  SwapHistoryResponse({
    required this.transactions,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory SwapHistoryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return SwapHistoryResponse(
      transactions: (data['transactions'] as List?)
              ?.map((t) => SwapTransaction.fromJson(t))
              .toList() ??
          [],
      page: data['pagination']?['page'] ?? 1,
      limit: data['pagination']?['limit'] ?? 20,
      total: data['pagination']?['total'] ?? 0,
    );
  }

  bool get hasMore => transactions.length < total;
}
