import 'package:comecomepay/core/base_service.dart';

class ContentService extends BaseService {
  /// Get site content (Company Intro, Privacy, Terms)
  Future<Map<String, dynamic>> getSiteContent(String lang) async {
    final response =
        await get('/site-content', queryParameters: {'lang': lang});
    return response['data'] ?? {};
  }
}
