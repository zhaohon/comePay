import 'dart:async';
import 'dart:developer' as Logger show log;

import 'package:Demo/core/base_viewmodel.dart';
import 'package:Demo/services/global_service.dart';
import 'package:Demo/models/responses/chat_inbox_response_model.dart';
import 'package:Demo/models/responses/chat_history_response_model.dart';
import 'package:Demo/models/requests/send_message_request_model.dart';
import 'package:Demo/services/hive_storage_service.dart';
import 'package:Demo/utils/service_locator.dart';

class MessageServiceCenterViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  // State variables
  List<MessageModel> _messages = [];
  List<ChatHistoryMessage> _chatHistory = [];
  Timer? _refreshTimer;

  // Pagination state
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

  // Chat history pagination state
  int _historyCurrentPage = 1;
  bool _historyHasMorePages = true;
  bool _isLoadingHistoryMore = false;

  // Getters
  bool get historyHasMorePages => _historyHasMorePages;

  // Getters
  List<MessageModel> get messages => _messages;
  List<ChatHistoryMessage> get chatHistory => _chatHistory;
  bool get isLoading => busy;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingHistoryMore => _isLoadingHistoryMore;

  // Business logic methods
  Future<void> getChatInbox({int page = 1}) async {
    if (page == 1) {
      setBusy(true);
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final response = await _globalService.getChatInbox(page, 50);
      if (page == 1) {
        _messages = response.messages;
      } else {
        _messages.addAll(response.messages);
      }
      _currentPage = page;
      // Determine if more pages exist based on pagination total and current page
      final totalMessages = response.pagination.total;
      final limit = response.pagination.limit;
      _hasMorePages = (_currentPage * limit) < totalMessages;
      notifyListeners();
    } catch (e) {
      Logger.log('Exception fetching chat inbox: $e');
    } finally {
      if (page == 1) {
        setBusy(false);
      } else {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> sendMessage(String message) async {
    setBusy(true);
    try {
      final user = HiveStorageService.getUser();
      if (user == null) {
        throw Exception('User not found');
      }
      final request = SendMessageRequestModel(
        userId: user.id,
        sender: 'user',
        message: message,
      );
      await _globalService.sendChatMessage(request);
      // Refresh inbox after sending message
      await getChatInbox(page: 1);
    } catch (e) {
      Logger.log('Exception sending message: $e');
    } finally {
      setBusy(false);
    }
  }

  // Start automatic refresh
  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      getChatInbox(page: 1);
    });
  }

  // Stop automatic refresh
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }

  Future<void> loadMoreMessages() async {
    if (_isLoadingMore || !_hasMorePages) return;
    await getChatInbox(page: _currentPage + 1);
  }

  // Chat history methods
  Future<void> getChatHistory({int page = 1}) async {
    if (page == 1) {
      setBusy(true);
    } else {
      _isLoadingHistoryMore = true;
      notifyListeners();
    }

    try {
      final user = HiveStorageService.getUser();
      if (user == null) {
        throw Exception('User not found');
      }

      final response = await _globalService.getChatHistory(user.id, page, 50);
      if (page == 1) {
        _chatHistory = response.data;
      } else {
        _chatHistory.addAll(response.data);
      }
      _historyCurrentPage = page;
      // Determine if more pages exist based on response data length
      _historyHasMorePages = response.data.length == 50;
      notifyListeners();
    } catch (e) {
      Logger.log('Exception fetching chat history: $e');
    } finally {
      if (page == 1) {
        setBusy(false);
      } else {
        _isLoadingHistoryMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMoreChatHistory() async {
    if (_isLoadingHistoryMore || !_historyHasMorePages) return;
    await getChatHistory(page: _historyCurrentPage + 1);
  }

  Future<void> refreshChatHistory() async {
    await getChatHistory(page: 1);
  }

  // Send message for chat history
  Future<void> sendChatHistoryMessage(String message) async {
    setBusy(true);
    try {
      final user = HiveStorageService.getUser();
      if (user == null) {
        throw Exception('User not found');
      }
      final request = SendMessageRequestModel(
        userId: user.id,
        sender: 'user',
        message: message,
      );
      await _globalService.sendChatMessage(request);
      // Refresh chat history after sending message
      await getChatHistory(page: 1);
    } catch (e) {
      Logger.log('Exception sending chat history message: $e');
      rethrow; // Re-throw to handle in UI
    } finally {
      setBusy(false);
    }
  }
}
