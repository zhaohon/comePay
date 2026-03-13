import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

class TransactionUtils {
  static String getLocalizedType(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context)!;
    print(type);
    switch (type) {
      case 'deposit':
        return l10n.typeDeposit;
      case 'withdraw':
        return l10n.typeWithdraw;
      case 'swap':
        return l10n.typeSwap;
      case 'card_fee':
        return l10n.typeCardFee;
      case 'commission':
        return l10n.typeCommission;
      case 'transfer':
        return l10n.typeTransfer;
      case 'fee':
        return l10n.typeFee;
      default:
        return type; // Fallback to raw type if unknown
    }
  }

  static String getLocalizedStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'pending':
        return l10n.statusPending;
      case 'completed':
        return l10n.statusCompleted;
      case 'failed':
        return l10n.statusFailed;
      case 'cancelled':
        return l10n.statusCancelled;
      case 'approved':
        return l10n.statusApproved;
      case 'rejected':
        return l10n.statusRejected;
      case 'credited':
        return l10n.statusCredited;
      default:
        return status;
    }
  }

  /// 卡片交易 trade_type 映射（int 1-12 或 string "consume"）
  static String getCardTradeTypeLabel(BuildContext context, dynamic tradeType) {
    final l10n = AppLocalizations.of(context)!;
    final key = tradeType.toString();
    switch (key) {
      case '1':
        return l10n.cardTradeDeposit;
      case '2':
        return l10n.cardTradeWithdraw;
      case '3':
        return l10n.cardTradeSwap;
      case '4':
        return l10n.cardTradeOpenCard;
      case '5':
        return l10n.cardTradeUpgrade;
      case '6':
        return l10n.cardTradeTransferToCard;
      case '7':
      case '11':
        return l10n.cardTradeRefund;
      case '8':
        return l10n.cardTradeKyc;
      case '9':
        return l10n.cardTradeOpenCardRefund;
      case '10':
        return l10n.cardTradeTransferFee;
      case '12':
        return l10n.cardTradeManualDeposit;
      case 'consume':
        return l10n.cardTradeConsume;
      default:
        return l10n.cardTradeUnknown;
    }
  }

  /// 卡片交易类型对应的图标
  static IconData getCardTradeTypeIcon(dynamic tradeType) {
    final key = tradeType.toString();
    switch (key) {
      case '1':
      case '12':
        return Icons.arrow_downward_rounded; // 充值/手动充值 - 入账
      case '2':
        return Icons.arrow_upward_rounded; // 提现 - 出账
      case '3':
        return Icons.swap_horiz_rounded; // 兑换
      case '4':
        return Icons.credit_card; // 开卡
      case '5':
        return Icons.upgrade_rounded; // 卡升级
      case '6':
        return Icons.input_rounded; // 转入到卡
      case '7':
      case '11':
        return Icons.undo_rounded; // 金额退回
      case '8':
        return Icons.verified_user_outlined; // KYC
      case '9':
        return Icons.money_off_rounded; // 开卡退款
      case '10':
        return Icons.receipt_long_outlined; // 转入手续费
      case 'consume':
        return Icons.shopping_bag_outlined; // 消费
      default:
        return Icons.receipt_outlined;
    }
  }

  /// 卡片交易类型对应的图标背景色
  static Color getCardTradeTypeColor(dynamic tradeType) {
    final key = tradeType.toString();
    switch (key) {
      case '1':
      case '12':
        return const Color(0xFF10B981); // 充值 → 绿色
      case '2':
        return const Color(0xFFEF4444); // 提现 → 红色
      case '3':
        return const Color(0xFF8B5CF6); // 兑换 → 紫色
      case '4':
      case '5':
        return const Color(0xFF3B82F6); // 开卡/升级 → 蓝色
      case '6':
        return const Color(0xFF06B6D4); // 转入到卡 → 青色
      case '7':
      case '9':
      case '11':
        return const Color(0xFFF59E0B); // 退回/退款 → 橙色
      case '8':
        return const Color(0xFF6366F1); // KYC → 靛蓝
      case '10':
        return const Color(0xFF9CA3AF); // 手续费 → 灰色
      case 'consume':
        return const Color(0xFFEC4899); // 消费 → 粉色
      default:
        return const Color(0xFF6B7280);
    }
  }
}
