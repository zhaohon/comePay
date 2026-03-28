import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/notification_model.dart';

class NotificationService extends BaseService {
  /// 获取通知列表
  Future<NotificationListResponse> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await get(
      '/notifications/',
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );

    return NotificationListResponse.fromJson(response);
  }

  /// 获取未读通知数量
  Future<UnreadCountResponse> getUnreadCount() async {
    final response = await get('/notifications/unread-count');
    return UnreadCountResponse.fromJson(response);
  }

  /// 获取通知详情（自动标记为已读）
  Future<NotificationDetailResponse> getNotificationDetail(int id) async {
    final response = await get('/notifications/$id');
    return NotificationDetailResponse.fromJson(response);
  }
}
