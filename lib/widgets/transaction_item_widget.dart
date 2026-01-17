import 'package:comecomepay/models/unified_transaction_model.dart';
import 'package:comecomepay/utils/transaction_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 交易记录Item组件 - 完全按照设计稿
/// 复用于首页和列表页
class TransactionItemWidget extends StatelessWidget {
  final UnifiedTransaction transaction;
  final VoidCallback? onTap;
  final bool isInList; // 是否在列表页（列表页使用卡片样式，首页使用无边距样式）

  const TransactionItemWidget({
    Key? key,
    required this.transaction,
    this.onTap,
    this.isInList = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: isInList
          ? EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 20,
              vertical: isSmallScreen ? 6 : 8,
            )
          : EdgeInsets.zero,
      decoration: isInList
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: isInList ? BorderRadius.circular(16) : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 20,
              vertical: isSmallScreen ? 16 : 18,
            ),
            child: Row(
              children: [
                // 左侧图标
                _buildIcon(isSmallScreen),
                SizedBox(width: isSmallScreen ? 12 : 14),

                // 中间内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 交易类型标签
                      Text(
                        TransactionUtils.getLocalizedType(
                            context, transaction.type),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1F2937),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 交易时间 - 格式：2025-12-31 14:45
                      Text(
                        _formatTime(transaction.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF9CA3AF),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12),

                // 右侧金额和箭头
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 金额
                        Text(
                          transaction.getFormattedAmount(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getAmountColor(),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 币种
                        Text(
                          transaction.currency,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    if (isInList) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 格式化时间为 2025-12-31 14:45
  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return '';
    }

    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final formatter = DateFormat('yyyy-MM-dd HH:mm');
      return formatter.format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  /// 构建交易类型图标
  Widget _buildIcon(bool isSmallScreen) {
    final iconData = _getIconData();
    final iconColor = _getIconColor();
    final backgroundColor = _getIconBackgroundColor();

    return Container(
      width: isSmallScreen ? 48 : 52,
      height: isSmallScreen ? 48 : 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: isSmallScreen ? 24 : 26,
        ),
      ),
    );
  }

  /// 根据交易类型获取图标
  IconData _getIconData() {
    switch (transaction.type) {
      case 'deposit':
        return Icons.add_circle_outline;
      case 'withdraw':
        return Icons.remove_circle_outline;
      case 'swap':
        return Icons.swap_horiz_rounded;
      case 'card_fee':
        return Icons.credit_card_rounded;
      case 'commission':
        return Icons.money;
      case 'transfer':
        return Icons.send_rounded;
      case 'fee':
        return Icons.payment_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  /// 根据交易类型获取图标颜色
  Color _getIconColor() {
    if (transaction.isIncome) {
      return const Color(0xFF10B981); // 绿色，收入
    } else {
      return const Color(0xFFEF4444); // 红色，支出
    }
  }

  /// 根据交易类型获取图标背景色
  Color _getIconBackgroundColor() {
    if (transaction.isIncome) {
      return const Color(0xFFD1FAE5); // 浅绿色背景
    } else {
      return const Color(0xFFFEE2E2); // 浅红色背景
    }
  }

  /// 根据金额正负获取文字颜色
  Color _getAmountColor() {
    if (transaction.isIncome) {
      return const Color(0xFF10B981); // 绿色，收入
    } else if (transaction.isExpense) {
      return const Color(0xFFEF4444); // 红色，支出
    } else {
      return const Color(0xFF1F2937);
    }
  }
}
