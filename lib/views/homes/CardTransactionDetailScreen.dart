import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/utils/transaction_utils.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class CardTransactionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const CardTransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    // 金额 & 币种
    final amount = (transaction['amount'] is num)
        ? (transaction['amount'] as num).toDouble()
        : 0.0;
    final isPositive = amount > 0;
    final currency =
        transaction['currency'] ?? transaction['currency_code'] ?? '';

    // 类型
    final tradeType = transaction['trade_type'] ?? '';
    final typeLabel =
        TransactionUtils.getCardTradeTypeLabel(context, tradeType);
    final typeColor = TransactionUtils.getCardTradeTypeColor(tradeType);
    final typeIcon = TransactionUtils.getCardTradeTypeIcon(tradeType);

    // 状态
    final status = transaction['status'] as String? ?? '';

    // IDs
    final tradeId = (transaction['trade_id'] ?? '').toString();
    final transactionId =
        (transaction['transaction_id'] ?? transaction['id'] ?? '').toString();
    final orderId = (transaction['order_id'] ?? '').toString();

    // 商户
    final merchantName = transaction['merchant_name'] as String? ?? '';

    // 描述
    final description = transaction['description'] as String? ?? '';

    // 时间
    final tradeTime = transaction['trade_time'] as String? ?? '';

    // 额外财务字段
    final fee = (transaction['fee'] is num)
        ? (transaction['fee'] as num).toDouble()
        : null;
    final balance = (transaction['balance'] is num)
        ? (transaction['balance'] as num).toDouble()
        : null;

    // created_time (可能是 int 秒级时间戳)
    final createdTime =
        transaction['created_time'] ?? transaction['created_at'];
    String createdTimeStr = '';
    if (createdTime is int && createdTime > 0) {
      createdTimeStr = DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(DateTime.fromMillisecondsSinceEpoch(createdTime * 1000));
    } else if (createdTime is String && createdTime.isNotEmpty) {
      createdTimeStr = _formatDateTime(createdTime);
    }

    final l10n = AppLocalizations.of(context)!;

    final amountColor =
        isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.billDetail,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // 顶部金额区域
            _buildAmountSection(
                amount, currency, amountColor, typeLabel, typeIcon, typeColor),

            const SizedBox(height: 32),

            // 基本交易信息卡片
            _buildBasicInfoCard(
              context,
              l10n,
              tradeType: tradeType,
              typeLabel: typeLabel,
              tradeTime: tradeTime,
              createdTimeStr: createdTimeStr,
              merchantName: merchantName,
              description: description,
              status: status,
            ),

            const SizedBox(height: 16),

            // 财务详情卡片
            _buildFinancialInfoCard(
              context,
              l10n,
              amount: amount,
              currency: currency,
              fee: fee,
              balance: balance,
            ),

            const SizedBox(height: 16),

            // ID 信息卡片
            _buildIdInfoCard(
              context,
              l10n,
              orderId: orderId,
              tradeId: tradeId,
              transactionId: transactionId,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 金额显示区域
  Widget _buildAmountSection(
    double amount,
    String currency,
    Color amountColor,
    String typeLabel,
    IconData typeIcon,
    Color typeColor,
  ) {
    final isPositive = amount > 0;
    return Column(
      children: [
        // 类型图标
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(typeIcon, color: typeColor, size: 28),
        ),
        const SizedBox(height: 12),

        // 类型标签
        Text(
          typeLabel,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // 金额
        Text(
          '${isPositive ? '+' : ''}${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: amountColor,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),

        // 币种
        Text(
          currency,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 基本交易信息卡片
  Widget _buildBasicInfoCard(
    BuildContext context,
    AppLocalizations l10n, {
    required dynamic tradeType,
    required String typeLabel,
    required String tradeTime,
    required String createdTimeStr,
    required String merchantName,
    required String description,
    required String status,
  }) {
    // 决定显示哪个时间
    final displayTime =
        tradeTime.isNotEmpty ? _formatDateTime(tradeTime) : createdTimeStr;

    return _buildCard(
      children: [
        // 交易类型
        _buildInfoRow(l10n.transactionType, typeLabel),

        // 交易时间
        if (displayTime.isNotEmpty) ...[
          _buildDivider(),
          _buildInfoRow(l10n.transactionTime, displayTime),
        ],

        // 商户名称
        if (merchantName.isNotEmpty) ...[
          _buildDivider(),
          _buildInfoRow(l10n.merchantNameLabel, merchantName),
        ],

        // 描述
        if (description.isNotEmpty) ...[
          _buildDivider(),
          _buildInfoRow(l10n.description, description),
        ],

        // 状态
        if (status.isNotEmpty) ...[
          _buildDivider(),
          _buildStatusRow(context, l10n.status, status),
        ],
      ],
    );
  }

  /// 财务详情卡片
  Widget _buildFinancialInfoCard(
    BuildContext context,
    AppLocalizations l10n, {
    required double amount,
    required String currency,
    double? fee,
    double? balance,
  }) {
    final isPositive = amount > 0;
    final amountStr =
        '${isPositive ? '+' : ''}${amount.toStringAsFixed(2)} $currency';

    return _buildCard(
      children: [
        // 交易金额
        _buildInfoRow(
          l10n.amount,
          amountStr,
          valueColor:
              isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),

        // 币种
        _buildDivider(),
        _buildInfoRow(l10n.spentCurrency, currency),

        // 手续费
        if (fee != null) ...[
          _buildDivider(),
          _buildInfoRow(l10n.fee, '${fee.toStringAsFixed(2)} $currency'),
        ],

        // 交易后余额
        if (balance != null) ...[
          _buildDivider(),
          _buildInfoRow(
              l10n.balanceLabel, '${balance.toStringAsFixed(2)} $currency'),
        ],
      ],
    );
  }

  /// ID 信息卡片
  Widget _buildIdInfoCard(
    BuildContext context,
    AppLocalizations l10n, {
    required String orderId,
    required String tradeId,
    required String transactionId,
  }) {
    final hasContent = (orderId.isNotEmpty && orderId != '0') ||
        (tradeId.isNotEmpty && tradeId != '0') ||
        (transactionId.isNotEmpty && transactionId != '0');

    if (!hasContent) return const SizedBox.shrink();

    return _buildCard(
      children: [
        // 订单号
        if (orderId.isNotEmpty && orderId != '0') ...[
          _buildInfoRowWithCopy(context, l10n.orderId, orderId),
        ],

        // 交易ID
        if (tradeId.isNotEmpty && tradeId != '0') ...[
          if (orderId.isNotEmpty && orderId != '0') _buildDivider(),
          _buildInfoRowWithCopy(context, 'Trade ID', tradeId),
        ],

        // 流水号
        if (transactionId.isNotEmpty && transactionId != '0') ...[
          if ((orderId.isNotEmpty && orderId != '0') ||
              (tradeId.isNotEmpty && tradeId != '0'))
            _buildDivider(),
          _buildInfoRowWithCopy(context, l10n.transactionId, transactionId),
        ],
      ],
    );
  }

  /// 通用卡片容器
  Widget _buildCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  /// 信息行
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15,
                color: valueColor ?? const Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 可复制的信息行
  Widget _buildInfoRowWithCopy(
      BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.copySuccess),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: const Icon(
              Icons.copy_rounded,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  /// 状态行（带彩色标签）
  Widget _buildStatusRow(BuildContext context, String label, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w400,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusBgColor(status),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              TransactionUtils.getLocalizedStatus(context, status),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _getStatusTextColor(status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 分隔线
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[100],
      indent: 20,
      endIndent: 20,
    );
  }

  /// 格式化时间
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      return formatter.format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  /// 状态标签背景色
  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFFD1FAE5);
      case 'pending':
        return const Color(0xFFFEF3C7);
      case 'failed':
      case 'rejected':
        return const Color(0xFFFEE2E2);
      case 'approved':
      case 'credited':
        return const Color(0xFFDBEAFE);
      case 'cancelled':
        return const Color(0xFFF3F4F6);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  /// 状态标签文字色
  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF065F46);
      case 'pending':
        return const Color(0xFF92400E);
      case 'failed':
      case 'rejected':
        return const Color(0xFF991B1B);
      case 'approved':
      case 'credited':
        return const Color(0xFF1E40AF);
      case 'cancelled':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
