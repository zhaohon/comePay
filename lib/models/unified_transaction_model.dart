/// 统一交易记录模型
/// 整合所有涉及资金变动的交易类型
class UnifiedTransaction {
  final int id;
  final String
      type; // deposit, withdraw, swap, card_fee, commission, transfer, fee
  final String typeLabel; // 中文标签
  final String
      status; // pending, completed, failed, cancelled, approved, rejected, credited
  final String statusLabel; // 状态中文标签
  final double amount; // 交易金额（正数为收入，负数为支出）
  final String currency; // 币种符号
  final String? description; // 交易描述
  final String createdAt; // 创建时间
  final String? completedAt; // 完成时间
  final double? fee; // 手续费
  final String? address; // 链上地址（充值/提现时有值）
  final String? txHash; // 链上交易哈希
  final String? reference; // 交易参考号/订单号
  final double? fromAmount; // 源金额（兑换交易时有值）
  final String? fromCurrency; // 源币种（兑换交易时有值）
  final double? toAmount; // 目标金额（兑换交易时有值）
  final String? toCurrency; // 目标币种（兑换交易时有值）
  final double? exchangeRate; // 汇率（兑换交易时有值）
  final int? sourceId; // 来源表记录ID
  final String? sourceTable; // 数据来源表名

  UnifiedTransaction({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.status,
    required this.statusLabel,
    required this.amount,
    required this.currency,
    this.description,
    required this.createdAt,
    this.completedAt,
    this.fee,
    this.address,
    this.txHash,
    this.reference,
    this.fromAmount,
    this.fromCurrency,
    this.toAmount,
    this.toCurrency,
    this.exchangeRate,
    this.sourceId,
    this.sourceTable,
  });

  factory UnifiedTransaction.fromJson(Map<String, dynamic> json) {
    return UnifiedTransaction(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      typeLabel: json['type_label'] ?? '',
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] ?? '',
      completedAt: json['completed_at'],
      fee: json['fee'] != null ? (json['fee']).toDouble() : null,
      address: json['address'],
      txHash: json['tx_hash'],
      reference: json['reference'],
      fromAmount:
          json['from_amount'] != null ? (json['from_amount']).toDouble() : null,
      fromCurrency: json['from_currency'],
      toAmount:
          json['to_amount'] != null ? (json['to_amount']).toDouble() : null,
      toCurrency: json['to_currency'],
      exchangeRate: json['exchange_rate'] != null
          ? (json['exchange_rate']).toDouble()
          : null,
      sourceId: json['source_id'],
      sourceTable: json['source_table'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'type_label': typeLabel,
      'status': status,
      'status_label': statusLabel,
      'amount': amount,
      'currency': currency,
      'description': description,
      'created_at': createdAt,
      'completed_at': completedAt,
      'fee': fee,
      'address': address,
      'tx_hash': txHash,
      'reference': reference,
      'from_amount': fromAmount,
      'from_currency': fromCurrency,
      'to_amount': toAmount,
      'to_currency': toCurrency,
      'exchange_rate': exchangeRate,
      'source_id': sourceId,
      'source_table': sourceTable,
    };
  }

  /// 判断是否为收入（金额为正数）
  bool get isIncome => amount > 0;

  /// 判断是否为支出（金额为负数）
  bool get isExpense => amount < 0;

  /// 获取格式化的金额字符串（带符号）
  String getFormattedAmount() {
    final absAmount = amount.abs().toStringAsFixed(2);
    if (amount > 0) {
      return '+$absAmount';
    } else if (amount < 0) {
      return '-$absAmount';
    }
    return absAmount;
  }

  /// 获取格式化的时间（只显示日期和时间，不显示秒）
  String getFormattedTime() {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt;
    }
  }
}

/// 统一交易记录分页列表响应数据
class UnifiedTransactionListResponse {
  final List<UnifiedTransaction> items;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  UnifiedTransactionListResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory UnifiedTransactionListResponse.fromJson(Map<String, dynamic> json) {
    return UnifiedTransactionListResponse(
      items: (json['items'] as List?)
              ?.map((item) =>
                  UnifiedTransaction.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'page': page,
      'page_size': pageSize,
      'total': total,
      'total_pages': totalPages,
    };
  }

  /// 是否还有更多数据
  bool get hasMore => page < totalPages;
}

/// 统一交易记录API响应结构
class UnifiedTransactionApiResponse {
  final String status;
  final UnifiedTransactionListResponse data;

  UnifiedTransactionApiResponse({
    required this.status,
    required this.data,
  });

  factory UnifiedTransactionApiResponse.fromJson(Map<String, dynamic> json) {
    return UnifiedTransactionApiResponse(
      status: json['status'] ?? 'success',
      data: UnifiedTransactionListResponse.fromJson(
          json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}
