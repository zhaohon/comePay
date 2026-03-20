class PhysicalUpgradeProgressData {
  final String orderNo;
  final String publicToken;
  final String status;
  final String statusDesc;
  final String trackingNo;
  final String? failReason;
  final String? refundStatus;
  final List<PhysicalUpgradeTimelineItem> timeline;

  PhysicalUpgradeProgressData({
    required this.orderNo,
    required this.publicToken,
    required this.status,
    required this.statusDesc,
    required this.trackingNo,
    this.failReason,
    this.refundStatus,
    required this.timeline,
  });

  factory PhysicalUpgradeProgressData.fromJson(Map<String, dynamic> json) {
    var list = json['timeline'] as List? ?? [];
    List<PhysicalUpgradeTimelineItem> timelineList =
        list.map((i) => PhysicalUpgradeTimelineItem.fromJson(i)).toList();

    return PhysicalUpgradeProgressData(
      orderNo: json['order_no'] ?? '',
      publicToken: json['public_token'] ?? '',
      status: json['status'] ?? '',
      statusDesc: json['status_desc'] ?? '',
      trackingNo: json['tracking_no'] ?? '',
      failReason: json['fail_reason'],
      refundStatus: json['refund_status'],
      timeline: timelineList,
    );
  }

  // 辅助方法，用于 UI 渲染状态判断
  bool get hasSubmitted =>
      ['SUBMITTED', 'PROCESSING', 'SHIPPED', 'DELIVERED'].contains(status);

  bool get isShippedOrDelivered => ['SHIPPED', 'DELIVERED'].contains(status);

  DateTime? get applicationTime {
    if (timeline.isEmpty) return null;
    try {
      // 获取最新申请的时间（由于是正序排列，第一个就是 INIT 时间）
      final item = timeline.first;
      return DateTime.parse(item.at).toLocal();
    } catch (e) {
      return null;
    }
  }

  DateTime? get shippedTime {
    try {
      // 找到变更为 SHIPPED 的时间
      final item = timeline.firstWhere((e) => e.status == 'SHIPPED');
      return DateTime.parse(item.at).toLocal();
    } catch (e) {
      return null;
    }
  }
}

class PhysicalUpgradeTimelineItem {
  final String at;
  final String status;
  final String? previousStatus;
  final String? source;
  final String? operator;
  final String? remark;
  final String? externalReqId;

  PhysicalUpgradeTimelineItem({
    required this.at,
    required this.status,
    this.previousStatus,
    this.source,
    this.operator,
    this.remark,
    this.externalReqId,
  });

  factory PhysicalUpgradeTimelineItem.fromJson(Map<String, dynamic> json) {
    return PhysicalUpgradeTimelineItem(
      at: json['at'] ?? '',
      status: json['status'] ?? '',
      previousStatus: json['previous_status'],
      source: json['source'],
      operator: json['operator'],
      remark: json['remark'],
      externalReqId: json['external_req_id'],
    );
  }
}
