class NotificationModel {
  final int id;
  final int? userId;
  final String title;
  final String body;
  final String status;
  final String data;
  final String? readAt;
  final String createdAt;
  final String updatedAt;

  NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.body,
    required this.status,
    required this.data,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      body: json['body'],
      status: json['status'],
      data: json['data'],
      readAt: json['read_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
