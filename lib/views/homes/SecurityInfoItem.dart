import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comecomepay/utils/app_colors.dart';

class SecurityInfoItem extends StatefulWidget {
  final String label;
  final String value;

  const SecurityInfoItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  State<SecurityInfoItem> createState() => _SecurityInfoItemState();
}

class _SecurityInfoItemState extends State<SecurityInfoItem> {
  bool _isCopied = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              Text(
                widget.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  if (widget.value.isEmpty || widget.value == '***') return;

                  await Clipboard.setData(ClipboardData(text: widget.value));

                  if (mounted) {
                    setState(() {
                      _isCopied = true;
                    });

                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        setState(() {
                          _isCopied = false;
                        });
                      }
                    });
                  }
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isCopied
                      ? const Icon(
                          Icons.check_circle,
                          key: ValueKey('check'),
                          size: 18,
                          color: Colors.green,
                        )
                      : const Icon(
                          Icons.copy,
                          key: ValueKey('copy'),
                          size: 18,
                          color: AppColors.primary,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
