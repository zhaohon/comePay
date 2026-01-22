import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/services/notification_service.dart';
import 'package:comecomepay/services/announcement_service.dart';
import 'package:comecomepay/models/notification_model.dart';
import 'package:comecomepay/models/announcement_model.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/viewmodels/notification_viewmodel.dart';
import 'NotificationDetailScreen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();
  final AnnouncementService _announcementService = AnnouncementService();

  // Notification data
  List<NotificationModel> _notifications = [];
  bool _isLoadingNotifications = false;
  bool _hasMoreNotifications = true;
  int _notificationOffset = 0;
  final int _notificationLimit = 20;

  // Announcement data
  List<AnnouncementItem> _announcements = [];
  bool _isLoadingAnnouncements = false;
  bool _hasMoreAnnouncements = true;
  int _announcementPage = 1;
  final int _announcementLimit = 20;

  String? _errorMessage;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _tabController.addListener(() {
        setState(() {}); // Rebuild when tab changes
      });
      _loadNotifications();
      _loadAnnouncements();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (_isLoadingNotifications) return;

    setState(() {
      _isLoadingNotifications = true;
      _errorMessage = null;
      if (refresh) {
        _notificationOffset = 0;
        _notifications.clear();
        _hasMoreNotifications = true;
      }
    });

    try {
      final response = await _notificationService.getNotifications(
        limit: _notificationLimit,
        offset: _notificationOffset,
      );

      setState(() {
        if (refresh) {
          _notifications = response.notifications;
        } else {
          _notifications.addAll(response.notifications);
        }
        _notificationOffset += response.notifications.length;
        _hasMoreNotifications =
            response.notifications.length >= _notificationLimit;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingNotifications = false;
      });
    }
  }

  Future<void> _loadAnnouncements({bool refresh = false}) async {
    if (_isLoadingAnnouncements) return;

    setState(() {
      _isLoadingAnnouncements = true;
      _errorMessage = null;
      if (refresh) {
        _announcementPage = 1;
        _announcements.clear();
        _hasMoreAnnouncements = true;
      }
    });

    try {
      final locale = Localizations.localeOf(context).languageCode;
      final response = await _announcementService.getAnnouncements(
        page: _announcementPage,
        limit: _announcementLimit,
        lang: locale,
      );

      setState(() {
        if (refresh) {
          _announcements = response.items;
        } else {
          _announcements.addAll(response.items);
        }
        _announcementPage++;
        _hasMoreAnnouncements = response.items.length >= _announcementLimit;
        _isLoadingAnnouncements = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingAnnouncements = false;
      });
    }
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _tabController.index == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return AppLocalizations.of(context)!.invalidDate;
    }
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.messageCenter,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      AppLocalizations.of(context)!.accountNotification,
                      0,
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      AppLocalizations.of(context)!.systemAnnouncement,
                      1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(),
          _buildAnnouncementList(),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    if (_isLoadingNotifications && _notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadNotifications(refresh: true),
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState(AppLocalizations.of(context)!.noNotifications);
    }

    return RefreshIndicator(
      onRefresh: () => _loadNotifications(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length + (_hasMoreNotifications ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            _loadNotifications();
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final notification = _notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildAnnouncementList() {
    if (_isLoadingAnnouncements && _announcements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _announcements.isEmpty) {
      return _buildErrorState();
    }

    if (_announcements.isEmpty && !_isLoadingAnnouncements) {
      return _buildAnnouncementEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadAnnouncements(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _announcements.length + (_hasMoreAnnouncements ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _announcements.length) {
            _loadAnnouncements();
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final announcement = _announcements[index];
          return _buildAnnouncementCard(announcement);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return RefreshIndicator(
      onRefresh: () => _loadAnnouncements(refresh: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'Error',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadAnnouncements(refresh: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA855F7),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementEmptyState() {
    return RefreshIndicator(
      onRefresh: () => _loadAnnouncements(refresh: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.campaign_outlined,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noAnnouncements,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return RefreshIndicator(
      onRefresh: () => _loadNotifications(refresh: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none_outlined,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final isUnread = notification.status == 'unread';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationDetailScreen(
                  id: notification.id,
                  type: 'notification',
                ),
              ),
            ).then((_) {
              // Refresh the list and unread counts
              _loadNotifications(refresh: true);
              // Refresh unread counts in ViewModel for home screen
              Provider.of<NotificationViewModel>(context, listen: false)
                  .refreshUnreadCounts();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date header
                Text(
                  _formatDate(notification.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Title with unread indicator
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // Body text
                Text(
                  notification.body,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.6,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementItem announcement) {
    final isUnread = !announcement.isRead; // Show red dot if NOT read

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationDetailScreen(
                  id: announcement.id,
                  type: 'announcement',
                ),
              ),
            ).then((_) {
              // Refresh the list and unread counts
              _loadAnnouncements(refresh: true);
              // Refresh unread counts in ViewModel for home screen
              Provider.of<NotificationViewModel>(context, listen: false)
                  .refreshUnreadCounts();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date header
                Text(
                  _formatDate(announcement.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Title with unread indicator
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // Content preview
                Text(
                  announcement.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.6,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
