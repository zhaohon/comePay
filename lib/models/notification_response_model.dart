import 'notification_model.dart';

class NotificationResponseModel {
  final int count;
  final List<NotificationModel> notifications;
  final String status;

  NotificationResponseModel({
    required this.count,
    required this.notifications,
    required this.status,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      count: json['count'],
      notifications: (json['notifications'] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
      status: json['status'],
    );
  }
}
