class NotificationUnreadCountResponseModel {
  final int count;
  final String status;

  NotificationUnreadCountResponseModel({
    required this.count,
    required this.status,
  });

  factory NotificationUnreadCountResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationUnreadCountResponseModel(
      count: json['count'] ?? 0,
      status: json['status'] ?? 'error',
    );
  }
}

class NotificationUnreadCountErrorModel {
  final String error;

  NotificationUnreadCountErrorModel({
    required this.error,
  });

  factory NotificationUnreadCountErrorModel.fromJson(Map<String, dynamic> json) {
    return NotificationUnreadCountErrorModel(
      error: json['error'] ?? 'Unknown error',
    );
  }
}
