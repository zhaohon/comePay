import 'package:flutter/material.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/services/withdraw_service.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

class WithdrawHistoryPage extends StatefulWidget {
  const WithdrawHistoryPage({super.key});

  @override
  _WithdrawHistoryPageState createState() => _WithdrawHistoryPageState();
}

class _WithdrawHistoryPageState extends State<WithdrawHistoryPage> {
  final WithdrawService _withdrawService = WithdrawService();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWithdrawals();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _currentPage < _totalPages) {
        _loadMore();
      }
    }
  }

  Future<void> _loadWithdrawals({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _items = [];
      });
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _withdrawService.getWithdrawHistory(
        page: _currentPage,
        limit: 20,
      );

      if (mounted) {
        setState(() {
          _items = response.items;
          _totalPages = response.totalPages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final response = await _withdrawService.getWithdrawHistory(
        page: _currentPage,
        limit: 20,
      );

      if (mounted) {
        setState(() {
          _items.addAll(response.items);
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentPage--; // 回退页码
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.loadingFailed}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 格式化时间显示
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return '--';
    }

    try {
      // 解析 ISO 8601 格式时间
      final dateTime = DateTime.parse(dateTimeStr);

      // 转换为本地时间
      final localTime = dateTime.toLocal();

      // 格式化为：2025-12-25 20:03:33
      final year = localTime.year;
      final month = localTime.month.toString().padLeft(2, '0');
      final day = localTime.day.toString().padLeft(2, '0');
      final hour = localTime.hour.toString().padLeft(2, '0');
      final minute = localTime.minute.toString().padLeft(2, '0');
      final second = localTime.second.toString().padLeft(2, '0');

      return '$year-$month-$day $hour:$minute:$second';
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '提现记录',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadWithdrawals(refresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _items.isEmpty) {
      // 加载中状态 - 也支持下拉刷新
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null && _items.isEmpty) {
      // 错误状态 - 支持下拉刷新重试
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.loadingFailed,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPlaceholder,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _loadWithdrawals(refresh: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(AppLocalizations.of(context)!.retryButton),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_items.isEmpty) {
      // 空状态 - 支持下拉刷新
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无提现记录',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '下拉刷新试试',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPlaceholder,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // 有数据 - 使用ListView，支持上拉加载更多
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    '加载中...',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final withdrawal = _items[index];

        // 如果是 null，显示占位符
        if (withdrawal == null) {
          return _buildEmptyCard(index);
        }

        return _buildWithdrawalCard(withdrawal);
      },
    );
  }

  Widget _buildEmptyCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '提现记录 #${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textPlaceholder.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '暂无数据',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalCard(Map<String, dynamic> withdrawal) {
    final amount = withdrawal['amount']?.toString() ?? '--';
    final currency = withdrawal['currency']?.toString() ?? '--';
    final address = withdrawal['address']?.toString() ?? '--';
    final status = withdrawal['status']?.toString() ?? 'pending';
    final createdAt = _formatDateTime(withdrawal['created_at']?.toString());

    // 状态颜色和文本映射
    Color statusColor;
    String statusText;
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        statusColor = AppColors.success;
        statusText = '已通过';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = '待审核';
        break;
      case 'rejected':
      case 'failed':
        statusColor = AppColors.error;
        statusText = '已拒绝';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currency,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '金额',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '地址',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                address.length > 20
                    ? '${address.substring(0, 10)}...${address.substring(address.length - 10)}'
                    : address,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            createdAt,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPlaceholder,
            ),
          ),
        ],
      ),
    );
  }
}
