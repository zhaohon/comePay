import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:comecomepay/services/card_service.dart';
import 'package:comecomepay/models/card_apply_progress_model.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

class CardApplyProgressScreen extends StatefulWidget {
  final int taskId;

  const CardApplyProgressScreen({
    super.key,
    required this.taskId,
  });

  @override
  State<CardApplyProgressScreen> createState() =>
      _CardApplyProgressScreenState();
}

class _CardApplyProgressScreenState extends State<CardApplyProgressScreen> {
  final CardService _cardService = CardService();

  CardApplyProgressModel? _progress;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPolling = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  /// 格式化时间
  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final date = DateTime.parse(timeStr);
      return DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(date.toLocal()); // Converted to local time
    } catch (e) {
      return timeStr;
    }
  }

  /// 开始轮询开卡进度
  void _startPolling() {
    _loadProgress();
    // 每3秒轮询一次
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _loadProgress();
    });
  }

  /// 加载开卡进度
  Future<void> _loadProgress() async {
    if (_isPolling) return; // 防止重复请求

    setState(() {
      _isPolling = true;
      if (_progress == null) {
        _isLoading = true;
      }
      _errorMessage = null;
    });

    try {
      final progress = await _cardService.getApplyProgress(widget.taskId);

      setState(() {
        _progress = progress;
        _isLoading = false;
        _isPolling = false;
      });

      // 如果已完成或失败，停止轮询
      if (progress.isCompleted || progress.isFailed) {
        _pollTimer?.cancel();

        // 如果完成，显示成功弹窗后返回
        if (progress.isCompleted && mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _showSuccessDialog();
            }
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isPolling = false;
      });
      print('Error loading progress: $e');
    }
  }

  /// 获取状态文本
  String _getStatusText() {
    if (_progress == null) return '加载中...';

    switch (_progress!.status) {
      case 'pending':
        return '等待处理';
      case 'processing':
        return '处理中';
      case 'completed':
        return '开卡成功';
      case 'failed':
        return '开卡失败';
      default:
        return _progress!.status;
    }
  }

  /// 获取状态颜色
  Color _getStatusColor() {
    if (_progress == null) return AppColors.textSecondary;

    switch (_progress!.status) {
      case 'pending':
        return AppColors.warning;
      case 'processing':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  /// 显示成功弹窗
  Future<void> _showSuccessDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 成功图标（带动画）
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.success,
                              AppColors.success.withOpacity(0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.cardApplicationSuccess,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (_progress != null && _progress!.list.isNotEmpty)
                  Text(
                    '已成功创建 ${_progress!.succeed} 张卡片',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '确定',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true && mounted) {
      // 返回时刷新卡片列表
      Navigator.pop(context, true); // 传递true表示需要刷新
    }
  }

  /// 获取进度百分比
  double _getProgressPercentage() {
    if (_progress == null) return 0.0;

    if (_progress!.isCompleted) return 1.0;
    if (_progress!.isFailed) return 0.0;
    if (_progress!.status == 'processing') return 0.5;
    return 0.1; // pending
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        automaticallyImplyLeading: false, // 不显示返回按钮
        title: Text(
          AppLocalizations.of(context)!.cardApplicationProgress,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading && _progress == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        '加载失败',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadProgress,
                        child: Text(AppLocalizations.of(context)!.retryButton),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 任务ID
                      Text(
                        '任务ID: ${widget.taskId}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 状态卡片（优化UI，增加动画）
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.9 + (value * 0.1),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getStatusColor().withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // 状态图标（带动画）
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration:
                                          const Duration(milliseconds: 600),
                                      curve: Curves.elasticOut,
                                      builder: (context, iconValue, child) {
                                        return Transform.scale(
                                          scale: iconValue,
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  _getStatusColor(),
                                                  _getStatusColor()
                                                      .withOpacity(0.7),
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _getStatusColor()
                                                      .withOpacity(0.3),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              _progress!.isCompleted
                                                  ? Icons.check_circle
                                                  : _progress!.isFailed
                                                      ? Icons.error
                                                      : Icons.hourglass_empty,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    // 状态文本
                                    Text(
                                      _getStatusText(),
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(),
                                      ),
                                    ),
                                    const SizedBox(height: 28),

                                    // 进度条（带动画）
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(
                                        begin: 0.0,
                                        end: _getProgressPercentage(),
                                      ),
                                      duration:
                                          const Duration(milliseconds: 1000),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, progressValue, child) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                            value: progressValue,
                                            backgroundColor: AppColors.border,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              _getStatusColor(),
                                            ),
                                            minHeight: 10,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 24),

                                    // 统计信息
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatItem(
                                            '总数',
                                            '${_progress!.total}',
                                            AppColors.textPrimary),
                                        _buildStatItem(
                                            '成功',
                                            '${_progress!.succeed}',
                                            AppColors.success),
                                        _buildStatItem(
                                            '失败',
                                            '${_progress!.failed}',
                                            AppColors.error),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // 时间信息
                      if (_progress!.createdAt.isNotEmpty) ...[
                        Text(
                          '${AppLocalizations.of(context)!.creationTime}: ${_formatTime(_progress!.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_progress!.completedAt != null &&
                            _progress!.completedAt!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${AppLocalizations.of(context)!.completionTime}: ${_formatTime(_progress!.completedAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],

                      // 卡片列表（如果已完成）- 暂时注释
                      // if (_progress!.isCompleted && _progress!.list.isNotEmpty) ...[
                      //   Text(
                      //     '已创建的卡片',
                      //     style: TextStyle(
                      //       fontSize: 18,
                      //       fontWeight: FontWeight.bold,
                      //       color: Colors.grey[800],
                      //     ),
                      //   //   ),
                      //   const SizedBox(height: 16),
                      //   ..._progress!.list.map((item) => _buildCardItem(item)).toList(),
                      // ],

                      // 失败提示
                      if (_progress!.isFailed) ...[
                        Card(
                          color: Colors.red[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red[700]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .cardApplicationFailedRetry,
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                                AppLocalizations.of(context)!.goBackButton),
                          ),
                        ),
                      ],

                      // 处理中提示（优化UI）
                      if (_progress!.isProcessing) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.1),
                                AppColors.accent.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (_isPolling)
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                )
                              else
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  '正在处理中，请稍候...',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - animValue)),
            child: Column(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardItem(CardApplyProgressItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.status == 'succeed' ? Colors.green : Colors.red,
          child: Icon(
            item.status == 'succeed' ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(
          item.maskedPan,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle:
            Text('${AppLocalizations.of(context)!.currency}: ${item.currency}'),
        trailing: Text(
          item.status == 'succeed' ? '成功' : '失败',
          style: TextStyle(
            color: item.status == 'succeed' ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
