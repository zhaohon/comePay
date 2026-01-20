class NotificationModel {
  final int id;
  final int? userId;
  final String title;
  final String body;
  final String status;
  final String? type;
  final String? data;
  final String? readAt;
  final String createdAt;
  final String updatedAt;

  NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.body,
    required this.status,
    this.type,
    this.data,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      status: json['status'] as String? ?? 'unread',
      type: json['type'] as String?,
      data: json['data'] as String?,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'status': status,
      'type': type,
      'data': data,
      'read_at': readAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class NotificationListResponse {
  final String status;
  final int count;
  final List<NotificationModel> notifications;

  NotificationListResponse({
    required this.status,
    required this.count,
    required this.notifications,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      status: json['status'] as String? ?? 'success',
      count: json['count'] as int? ?? 0,
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map((item) =>
                  NotificationModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class UnreadCountResponse {
  final String status;
  final int count;

  UnreadCountResponse({
    required this.status,
    required this.count,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      status: json['status'] as String? ?? 'success',
      count: json['count'] as int? ?? 0,
    );
  }
}
