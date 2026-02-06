import 'package:Demo/core/base_service.dart';
import 'package:Demo/utils/logger.dart';

class ContentService extends BaseService {
  /// Get site content (Company Intro, Privacy, Terms)
  /// GET /site-content
  /// lang: zh, en, ar
  Future<Map<String, dynamic>> getSiteContent(String lang) async {
    try {
      final response =
          await get('/site-content', queryParameters: {'lang': lang});
      if (response['status'] == 'success') {
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to get site content');
      }
    } catch (e) {
      Logger.error('getSiteContent', '/site-content', e, StackTrace.current);
      // Return empty or rethink error handling. For now rethrow to let UI handle/show error.
      rethrow;
    }
  }
}
