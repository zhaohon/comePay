import 'package:flutter/material.dart';
import 'package:Demo/l10n/app_localizations.dart';

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
}
