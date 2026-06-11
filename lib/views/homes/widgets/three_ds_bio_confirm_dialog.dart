import 'dart:async';
import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

/// 3DS 生物识别支付确认弹窗
class ThreeDSBioConfirmDialog extends StatefulWidget {
  /// 交易金额
  final String amount;

  /// 货币单位
  final String currency;

  /// 商户信息
  final String merchantName;

  /// 交易流水号
  final String transactionId;

  /// 创建时间
  final String createdAt;

  /// 倒计时秒数（默认 600 秒 = 10 分钟）
  final int countdownSeconds;

  /// 批准回调
  final VoidCallback? onApprove;

  /// 拒绝回调
  final VoidCallback? onReject;

  const ThreeDSBioConfirmDialog({
    Key? key,
    this.amount = '0.1',
    this.currency = 'HKD',
    this.merchantName = 'Add Card – AlipayHK',
    this.transactionId = 'abfaba85-5693-4ae5-9dda-47d131c24ee7',
    this.createdAt = '2024-12-31 13:42:47',
    this.countdownSeconds = 600,
    this.onApprove,
    this.onReject,
  }) : super(key: key);

  /// 显示弹窗的静态方法
  static Future<void> show(
    BuildContext context, {
    String amount = '0.1',
    String currency = 'HKD',
    String merchantName = 'Add Card – AlipayHK',
    String transactionId = 'abfaba85-5693-4ae5-9dda-47d131c24ee7',
    String createdAt = '2024-12-31 13:42:47',
    int countdownSeconds = 600,
    VoidCallback? onApprove,
    VoidCallback? onReject,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => ThreeDSBioConfirmDialog(
        amount: amount,
        currency: currency,
        merchantName: merchantName,
        transactionId: transactionId,
        createdAt: createdAt,
        countdownSeconds: countdownSeconds,
        onApprove: onApprove,
        onReject: onReject,
      ),
    );
  }

  @override
  State<ThreeDSBioConfirmDialog> createState() =>
      _ThreeDSBioConfirmDialogState();
}

class _ThreeDSBioConfirmDialogState extends State<ThreeDSBioConfirmDialog> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.countdownSeconds;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 0) {
        timer.cancel();
        // 超时自动关闭
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  String _formatCountdown() {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '00:$minutes:$seconds';
  }

  Color get _countdownColor {
    if (_remainingSeconds <= 60) return const Color(0xFFFF3B30);
    if (_remainingSeconds <= 180) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30); // 始终红色，匹配设计图
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部拖拽指示条
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 标题栏
              Center(
                child: Text(
                  AppLocalizations.of(context)!.threeDsPaymentAuth,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 主标题
              Text(
                AppLocalizations.of(context)!.threeDsPendingConfirm,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              // 副标题说明
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  AppLocalizations.of(context)!.threeDsConfirmTip,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A8A8A),
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 倒计时
              Text(
                _formatCountdown(),
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: _countdownColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 24),

              // 交易信息卡片
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(AppLocalizations.of(context)!.threeDsAmount,
                        '${widget.amount} ${widget.currency}'),
                    const Divider(
                        height: 20, thickness: 0.5, color: Color(0xFFE0E0E0)),
                    _buildInfoRow(AppLocalizations.of(context)!.threeDsMerchant,
                        widget.merchantName,
                        valueMaxLines: 2),
                    const Divider(
                        height: 20, thickness: 0.5, color: Color(0xFFE0E0E0)),
                    _buildInfoRow(AppLocalizations.of(context)!.threeDsTxId,
                        widget.transactionId,
                        valueMaxLines: 3),
                    const Divider(
                        height: 20, thickness: 0.5, color: Color(0xFFE0E0E0)),
                    _buildInfoRow(
                        AppLocalizations.of(context)!.threeDsCreatedAt,
                        widget.createdAt,
                        valueMaxLines: 2),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 批准按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.of(context).pop();
                    widget.onApprove?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.threeDsApprove,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 拒绝按钮
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.of(context).pop();
                    widget.onReject?.call();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE91E8C),
                    side:
                        const BorderSide(color: Color(0xFFE91E8C), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.threeDsReject,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {int? valueMaxLines = 1}) {
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
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
