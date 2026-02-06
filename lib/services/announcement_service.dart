import 'package:Demo/core/base_service.dart';
import 'package:Demo/models/announcement_model.dart';
import 'package:Demo/models/notification_model.dart';

class AnnouncementService extends BaseService {
  /// 获取已发布的公告列表
  Future<AnnouncementListResponse> getAnnouncements({
    int page = 1,
    int limit = 20,
    String lang = 'zh',
  }) async {
    try {
      final response = await dio.get(
        '/announcements',
        queryParameters: {
          'page': page,
          'limit': limit,
          'lang': lang,
        },
      );

      final data = handleResponse(response);
      return AnnouncementListResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// 获取公告详情
  Future<AnnouncementDetailResponse> getAnnouncementDetail(
    int id, {
    String lang = 'zh',
  }) async {
    try {
      final response = await dio.get(
        '/announcements/$id',
        queryParameters: {
          'lang': lang,
        },
      );

      final data = handleResponse(response);
      return AnnouncementDetailResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// 获取未读公告数量
  Future<UnreadCountResponse> getUnreadCount() async {
    try {
      final response = await dio.get(
        '/announcements/unread-count',
      );

      final data = handleResponse(response);
      return UnreadCountResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
