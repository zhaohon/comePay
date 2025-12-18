class ChatHistoryMessage {
  final int id;
  final int userId;
  final String sender;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  ChatHistoryMessage({
    required this.id,
    required this.userId,
    required this.sender,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatHistoryMessage.fromJson(Map<String, dynamic> json) {
    return ChatHistoryMessage(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      sender: json['sender'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'sender': sender,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ChatHistoryResponse {
  final String apiName;
  final int code;
  final List<ChatHistoryMessage> data;
  final String date;
  final String message;
  final String version;

  ChatHistoryResponse({
    required this.apiName,
    required this.code,
    required this.data,
    required this.date,
    required this.message,
    required this.version,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      apiName: json['api-name'] ?? '',
      code: json['code'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ChatHistoryMessage.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      date: json['date'] ?? '',
      message: json['message'] ?? '',
      version: json['version'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'api-name': apiName,
      'code': code,
      'data': data.map((e) => e.toJson()).toList(),
      'date': date,
      'message': message,
      'version': version,
    };
  }
}
