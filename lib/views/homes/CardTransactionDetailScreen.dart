import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comecomepay/utils/app_colors.dart';

class CardTransactionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const CardTransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final amount = transaction['amount'] ?? 0.0;
    final isPositive = amount > 0;
    final currency = transaction['currency'] ?? transaction['currency_code'] ?? 'CNY';
    final status = transaction['status'] ?? '';
    final cardNo = (transaction['card_no'] ?? transaction['card_number'] ?? '').toString();
    final transactionType = (transaction['transaction_type'] ?? transaction['type'] ?? '消費').toString();
    final country = (transaction['country'] ?? transaction['country_code'] ?? '').toString();
    final city = (transaction['city'] ?? '').toString();
    final merchant = (transaction['merchant'] ?? transaction['merchant_name'] ?? '').toString();
    final transactionId = (transaction['transaction_id'] ?? transaction['id'] ?? '').toString();
    final transactionTime = (transaction['transaction_time'] ?? transaction['created_at'] ?? transaction['date'] ?? '').toString();
    final deductionInfo = transaction['deduction_info'] ?? transaction['deduction'] ?? {};

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '帳單詳情',
          style: TextStyle(
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
            // 金额显示
            Center(
              child: Column(
                children: [
                  Text(
                    '${isPositive ? '+' : ''}${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currency,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: status == '結算中' || status == 'settling'
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 14,
                          color: status == '結算中' || status == 'settling'
                              ? AppColors.error
                              : AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 交易详情
            Text(
              '交易詳情',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _buildDetailItem('卡號', cardNo),
            _buildDetailItem('交易類型', transactionType),
            if (country.isNotEmpty) _buildDetailItem('國家/地區', country),
            if (city.isNotEmpty) _buildDetailItem('城市', city),
            if (merchant.isNotEmpty) _buildDetailItem('商戶信息', merchant),
            _buildDetailItemWithCopy('交易流水號', transactionId),
            _buildDetailItem('交易時間', transactionTime),

            // 扣款信息
            if (deductionInfo.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Text(
                '扣款信息',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pageBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deductionInfo['currency'] ?? 'USDT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (deductionInfo['amount'] != null)
                            Text(
                              '${deductionInfo['amount'].toStringAsFixed(2)} ${deductionInfo['currency'] ?? 'USDT'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
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
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
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

  Widget _buildDetailItemWithCopy(String label, String value) {
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
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
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
              // TODO: 显示复制成功提示
            },
            child: Icon(
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

