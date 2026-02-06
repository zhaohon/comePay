import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Demo/utils/app_colors.dart';
import 'package:Demo/l10n/app_localizations.dart';

class CardTransactionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const CardTransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    // Basic fields from API
    final amount = transaction['amount'] ?? 0.0;
    final isPositive = amount > 0;
    final currency =
        transaction['currency'] ?? transaction['currency_code'] ?? 'CNY';
    // final status = transaction['status'] ?? ''; // hidden as not in example

    // Details fields
    final orderId = (transaction['order_id'] ?? '').toString();
    final transactionId =
        (transaction['id'] ?? transaction['transaction_id'] ?? '').toString();
    final type = (transaction['trade_type'] ?? transaction['type'] ?? '0')
        .toString(); // 3, 2 etc.
    final createdTime =
        (transaction['created_time'] ?? transaction['date'] ?? 0);
    final balance = transaction['balance'] ?? 0.0;
    final fee = transaction['fee'] ?? 0.0;

    // Format time
    String transactionTimeStr = '';
    if (createdTime is int) {
      transactionTimeStr =
          DateTime.fromMillisecondsSinceEpoch(createdTime * 1000)
              .toString()
              .split('.')[0];
    } else {
      transactionTimeStr = createdTime.toString();
    }

    // Localized strings
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.billDetail,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount
            Center(
              child: Column(
                children: [
                  Text(
                    '${amount > 0 ? '+' : ''}${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currency,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Transaction Details Title
            Text(
              l10n.transactionDetails,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Detail Items
            if (orderId.isNotEmpty && orderId != '0')
              _buildDetailItemWithCopy(context, l10n.orderId, orderId),

            if (transactionId.isNotEmpty && transactionId != '0')
              _buildDetailItemWithCopy(
                  context, l10n.transactionId, transactionId),

            _buildDetailItem(
                l10n.transactionType, type), // todo: map types if needed

            _buildDetailItem(l10n.transactionTime, transactionTimeStr),

            _buildDetailItem(l10n.balanceLabel, balance.toStringAsFixed(2)),

            _buildDetailItem(l10n.fee, fee.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItemWithCopy(
      BuildContext context, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
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
              Icons.copy,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
