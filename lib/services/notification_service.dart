import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/notification_model.dart';

class NotificationService extends BaseService {
  /// 获取通知列表
  Future<NotificationListResponse> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await dio.get(
        '/notifications/',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      final data = handleResponse(response);
      return NotificationListResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// 获取未读通知数量
  Future<UnreadCountResponse> getUnreadCount() async {
    try {
      final response = await dio.get(
        '/notifications/unread-count',
      );

      final data = handleResponse(response);
      return UnreadCountResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// 标记通知为已读
  Future<void> markAsRead(int id) async {
    try {
      final response = await dio.put(
        '/notifications/$id/read',
      );

      handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// 标记所有通知为已读
  Future<void> markAllAsRead() async {
    try {
      final response = await dio.put(
        '/notifications/read-all',
      );

      handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}
