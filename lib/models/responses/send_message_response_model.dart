class SendMessageResponseModel {
  final int id;
  final int userId;
  final String sender;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  SendMessageResponseModel({
    required this.id,
    required this.userId,
    required this.sender,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory SendMessageResponseModel.fromJson(Map<String, dynamic> json) {
    return SendMessageResponseModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      sender: json['sender'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
