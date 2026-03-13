import 'package:flutter/material.dart';
import 'package:comecomepay/services/user_service.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/views/homes/SetTransactionPasswordScreen.dart';

/// 交易密码守卫工具类
/// 封装了「检查交易密码状态 + 弹窗拦截提示」的完整逻辑
/// 使用方式：
/// ```dart
/// final isSet = await TransactionPasswordGuard.check(context);
/// if (!isSet) return; // 用户未设置密码，已弹窗提示
/// // 继续后续业务逻辑...
/// ```
class TransactionPasswordGuard {
  static final UserService _userService = UserService();

  /// 检查交易密码是否已设置
  /// 返回 true：已设置，可以继续操作
  /// 返回 false：未设置，已弹窗提示用户跳转设置页面
  ///
  /// [context] 当前 BuildContext
  /// [onPasswordSet] 可选回调，用户设置密码成功后会被调用
  static Future<bool> check(
    BuildContext context, {
    VoidCallback? onPasswordSet,
  }) async {
    try {
      final isSet = await _userService.getTransactionPasswordStatus();

      if (isSet) {
        return true;
      }

      // 未设置，弹窗提示
      if (context.mounted) {
        _showSetPasswordPrompt(context, onPasswordSet: onPasswordSet);
      }
      return false;
    } catch (e) {
      // 接口异常时，为安全起见提示用户
      debugPrint('TransactionPasswordGuard check error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }

  /// 显示设置交易密码的弹窗提示
  static void _showSetPasswordPrompt(
    BuildContext context, {
    VoidCallback? onPasswordSet,
  }) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.security_rounded,
                color: Colors.orange,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.securityTip,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.transactionPasswordNotSetMessage,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SetTransactionPasswordScreen(),
                ),
              ).then((value) {
                if (value == true && onPasswordSet != null) {
                  onPasswordSet();
                }
              });
            },
            child: Text(
              l10n.goToSet,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
