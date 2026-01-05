import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/notification_model.dart';
import 'package:comecomepay/models/responses/notification_unread_count_response_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/utils/service_locator.dart';

class NotificationViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  List<NotificationModel> _notifications = [];
  String? _errorMessage;
  bool _isRefreshing = false;

  int _unreadNotificationCount = 0;

  List<NotificationModel> get notifications => _notifications;
  String? get errorMessage => _errorMessage;
  bool get isLoading => busy;
  bool get isRefreshing => _isRefreshing;
  int get unreadNotificationCount => _unreadNotificationCount;

  Future<void> getNotifikasi({int limit = 20, int offset = 0}) async {
    setBusy(true);
    _errorMessage = null;
    try {
      final response = await _globalService.getNotifications(limit, offset);
      _notifications = response.notifications;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> refreshNotifications() async {
    _isRefreshing = true;
    notifyListeners();
    try {
      await getNotifikasi();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadNotificationCount() async {
    try {
      final response = await _globalService.getUnreadNotificationCount();
      _unreadNotificationCount = response.count;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      // Rethrow to let HomeScreen know the call failed
      rethrow;
    }
  }
}
