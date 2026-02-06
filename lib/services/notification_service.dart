import 'package:Demo/core/base_service.dart';
import 'package:Demo/models/notification_model.dart';

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

  /// 获取通知详情（自动标记为已读）
  Future<NotificationDetailResponse> getNotificationDetail(int id) async {
    try {
      final response = await dio.get(
        '/notifications/$id',
      );

      final data = handleResponse(response);
      return NotificationDetailResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
