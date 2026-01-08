import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/models/unified_transaction_model.dart';
import 'package:intl/intl.dart';

/// 交易详情页面
/// 显示单个交易的详细信息
class TransactionDetailScreen extends StatelessWidget {
  final UnifiedTransaction transaction;

  const TransactionDetailScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          localizations.transactionDetails,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // 金额显示区域
            _buildAmountSection(),

            const SizedBox(height: 40),

            // 交易信息列表
            _buildInfoSection(localizations),
          ],
        ),
      ),
    );
  }

  /// 金额显示区域
  Widget _buildAmountSection() {
    final amountColor = transaction.isIncome
        ? const Color(0xFF10B981)
        : transaction.isExpense
            ? const Color(0xFFEF4444)
            : const Color(0xFF1F2937);

    return Column(
      children: [
        // 金额
        Text(
          transaction.getFormattedAmount(),
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: amountColor,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        // 币种
        Text(
          transaction.currency,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 交易信息区域
  Widget _buildInfoSection(AppLocalizations localizations) {
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
      child: Column(
        children: [
          _buildInfoRow(localizations.spentCurrency, transaction.currency),
          _buildDivider(),
          _buildInfoRow(localizations.transactionType, transaction.typeLabel),
          _buildDivider(),
          _buildInfoRow(localizations.transactionTime,
              _formatDateTime(transaction.createdAt)),

          // 如果有完成时间，显示完成时间
          if (transaction.completedAt != null &&
              transaction.completedAt!.isNotEmpty) ...[
            _buildDivider(),
            _buildInfoRow(localizations.completionTime,
                _formatDateTime(transaction.completedAt)),
          ],

          // 如果有手续费，显示手续费
          if (transaction.fee != null && transaction.fee! > 0) ...[
            _buildDivider(),
            _buildInfoRow(localizations.fee,
                '${transaction.fee} ${transaction.currency}'),
          ],

          // 如果有地址，显示地址
          if (transaction.address != null &&
              transaction.address!.isNotEmpty) ...[
            _buildDivider(),
            _buildInfoRow(localizations.address, transaction.address!,
                canCopy: true),
          ],

          // 如果有交易哈希，显示交易哈希
          if (transaction.txHash != null && transaction.txHash!.isNotEmpty) ...[
            _buildDivider(),
            _buildInfoRow(localizations.txHash, transaction.txHash!,
                canCopy: true),
          ],

          // 如果是兑换交易，显示兑换信息
          if (transaction.type == 'swap') ...[
            if (transaction.fromAmount != null &&
                transaction.fromCurrency != null) ...[
              _buildDivider(),
              _buildInfoRow(localizations.swapAmount,
                  '${transaction.fromAmount} ${transaction.fromCurrency}'),
            ],
            if (transaction.toAmount != null &&
                transaction.toCurrency != null) ...[
              _buildDivider(),
              _buildInfoRow(localizations.swapTo,
                  '${transaction.toAmount} ${transaction.toCurrency}'),
            ],
            if (transaction.exchangeRate != null) ...[
              _buildDivider(),
              _buildInfoRow(
                  localizations.exchangeRate, '${transaction.exchangeRate}'),
            ],
          ],

          // 如果有描述，显示描述
          if (transaction.description != null &&
              transaction.description!.isNotEmpty) ...[
            _buildDivider(),
            _buildInfoRow(localizations.description, transaction.description!),
          ],

          // 状态
          _buildDivider(),
          _buildInfoRow(localizations.status, transaction.statusLabel,
              valueColor: _getStatusColor(transaction.status)),
        ],
      ),
    );
  }

  /// 信息行
  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, bool canCopy = false}) {
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

  /// 分隔线
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 20,
      endIndent: 20,
    );
  }

  /// 格式化时间为 2025-12-26 12:17:46
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return '';
    }

    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      return formatter.format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  /// 根据状态获取颜色
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF10B981); // 绿色
      case 'pending':
        return const Color(0xFFF59E0B); // 橙色
      case 'failed':
        return const Color(0xFFEF4444); // 红色
      default:
        return const Color(0xFF6B7280); // 灰色
    }
  }
}
