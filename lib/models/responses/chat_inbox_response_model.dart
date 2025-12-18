import 'user_model.dart';
import 'pagination_model.dart';

class MessageModel {
  final int id;
  final int userId;
  final String message;
  final bool isAdmin;
  final String status;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel user;

  MessageModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.isAdmin,
    required this.status,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      message: json['message'] ?? '',
      isAdmin: json['is_admin'] ?? false,
      status: json['status'] ?? '',
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime(1),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime(1),
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'message': message,
      'is_admin': isAdmin,
      'status': status,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}

class ChatInboxResponseModel {
  final List<MessageModel> messages;
  final PaginationModel pagination;

  ChatInboxResponseModel({
    required this.messages,
    required this.pagination,
  });

  factory ChatInboxResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatInboxResponseModel(
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
