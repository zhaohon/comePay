/// 开卡进度中的卡片项
class CardApplyProgressItemModel {
  final String publicToken;
  final String maskedPan;
  final String currency;
  final int kycId;
  final String status; // "succeed" or "failed"

  CardApplyProgressItemModel({
    required this.publicToken,
    required this.maskedPan,
    required this.currency,
    required this.kycId,
    required this.status,
  });

  factory CardApplyProgressItemModel.fromJson(Map<String, dynamic> json) {
    return CardApplyProgressItemModel(
      publicToken: json['public_token'] as String? ?? '',
      maskedPan: json['masked_pan'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
      kycId: json['kyc_id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
    );
  }
}

/// 开卡进度响应模型
class CardApplyProgressModel {
  final int taskId;
  final String status; // "pending", "processing", "completed", "failed"
  final int total;
  final int succeed;
  final int failed;
  final String createdAt;
  final String? completedAt;
  final String? lastPolledAt;
  final List<CardApplyProgressItemModel> list;

  CardApplyProgressModel({
    required this.taskId,
    required this.status,
    required this.total,
    required this.succeed,
    required this.failed,
    required this.createdAt,
    this.completedAt,
    this.lastPolledAt,
    required this.list,
  });

  factory CardApplyProgressModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    final listData = data['list'] as List<dynamic>? ?? [];
    final items = listData
        .map((item) => CardApplyProgressItemModel.fromJson(
            item as Map<String, dynamic>))
        .toList();

    return CardApplyProgressModel(
      taskId: data['task_id'] as int? ?? 0,
      status: data['status'] as String? ?? '',
      total: data['total'] as int? ?? 0,
      succeed: data['succeed'] as int? ?? 0,
      failed: data['failed'] as int? ?? 0,
      createdAt: data['created_at'] as String? ?? '',
      completedAt: data['completed_at'] as String?,
      lastPolledAt: data['last_polled_at'] as String?,
      list: items,
    );
  }

  /// 判断是否已完成
  bool get isCompleted => status == 'completed';

  /// 判断是否失败
  bool get isFailed => status == 'failed';

  /// 判断是否处理中
  bool get isProcessing => status == 'processing' || status == 'pending';
}

