import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/announcement_model.dart';
import 'package:comecomepay/models/notification_model.dart';

class AnnouncementService extends BaseService {
  /// 获取已发布的公告列表
  Future<AnnouncementListResponse> getAnnouncements({
    int page = 1,
    int limit = 20,
    String lang = 'zh',
  }) async {
    final response = await get(
      '/announcements',
      queryParameters: {
        'page': page,
        'limit': limit,
        'lang': lang,
      },
    );

    return AnnouncementListResponse.fromJson(response);
  }

  /// 获取公告详情
  Future<AnnouncementDetailResponse> getAnnouncementDetail(
    int id, {
    String lang = 'zh',
  }) async {
    final response = await get(
      '/announcements/$id',
      queryParameters: {
        'lang': lang,
      },
    );

    return AnnouncementDetailResponse.fromJson(response);
  }

  /// 获取未读公告数量
  Future<UnreadCountResponse> getUnreadCount() async {
    final response = await get('/announcements/unread-count');
    return UnreadCountResponse.fromJson(response);
  }
}
