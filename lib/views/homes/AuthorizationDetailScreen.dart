import 'package:flutter/material.dart';
import 'package:comecomepay/models/three_ds_record_model.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

class AuthorizationDetailScreen extends StatelessWidget {
  final ThreeDSRecordModel record;

  const AuthorizationDetailScreen({Key? key, required this.record})
      : super(key: key);

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString).toLocal();
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCompleted = record.confirmationStatus == 'SUCCESS';
    bool isRejected = record.confirmationStatus == 'FAILURE';
    String statusText = isCompleted
        ? AppLocalizations.of(context)!.statusCompleted
        : (isRejected
            ? AppLocalizations.of(context)!.statusRejected
            : AppLocalizations.of(context)!.threeDsPending);
    Color statusColor = isCompleted
        ? const Color(0xFF4CAF50)
        : (isRejected ? const Color(0xFFE91E8C) : Colors.grey[600]!);
    IconData statusIcon = isCompleted
        ? Icons.check_circle_outline
        : (isRejected ? Icons.highlight_off : Icons.access_time);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.threeDsAuthDetails,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 顶部状态图标
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    statusIcon,
                    size: 64,
                    color: statusColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // 信息卡片
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildRow(AppLocalizations.of(context)!.threeDsAmount,
                      '${record.amount} ${record.currency}'),
                  const Divider(
                      height: 32, thickness: 0.5, color: Color(0xFFE0E0E0)),
                  _buildRow(AppLocalizations.of(context)!.threeDsMerchant,
                      record.merchantName),
                  const Divider(
                      height: 32, thickness: 0.5, color: Color(0xFFE0E0E0)),
                  // 交易流水号可能很长，允许多行，右对齐
                  _buildRow(AppLocalizations.of(context)!.threeDsTxId,
                      record.id.toString(),
                      valueMaxLines:
                          null), // 如果后端没返回 UUID 用 id 兜底，如果有单独的 transactionId 可以改
                  const Divider(
                      height: 32, thickness: 0.5, color: Color(0xFFE0E0E0)),
                  _buildRow(AppLocalizations.of(context)!.threeDsAuthTime,
                      _formatDate(record.confirmedAt ?? record.receivedAt)),
                  const Divider(
                      height: 32, thickness: 0.5, color: Color(0xFFE0E0E0)),
                  _buildRow(AppLocalizations.of(context)!.threeDsTxTime,
                      _formatDate(record.receivedAt)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {int? valueMaxLines = 1}) {
    return Row(
      crossAxisAlignment: (valueMaxLines == null || valueMaxLines > 1)
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8A8A8A),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: valueMaxLines,
            overflow: valueMaxLines == null
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
