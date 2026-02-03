import 'package:flutter/material.dart';

import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/utils/app_colors.dart';

import 'package:comecomepay/models/payment_currency_model.dart';
import 'package:comecomepay/models/card_fee_payment_model.dart';
import 'package:comecomepay/views/homes/CardApplyProgressScreen.dart';

import 'package:comecomepay/services/card_fee_service.dart';
import 'package:comecomepay/services/kyc_service.dart';
import 'package:comecomepay/services/card_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/views/homes/CardVerificationScreen.dart';
import 'package:comecomepay/models/card_fee_config_model.dart';
import 'package:comecomepay/models/card_apply_model.dart';
import 'package:dio/dio.dart';
import 'package:comecomepay/models/responses/coupon_detail_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/card_viewmodel.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum CardApplyState {
  loading,
  payment, // Needs to pay
  kycReviewing, // Paid, KYC under review
  kycFailed, // Paid, KYC failed
  kycPendingSubmit, // Paid, KYC not submitted
  kycSuccess, // Paid, KYC success, ready to issue
}

class CardApplyConfirmScreen extends StatefulWidget {
  final CardFeeConfigModel? cardFeeConfig;
  final CouponDetailModel? selectedCoupon;
  final bool skipKycCheck;

  const CardApplyConfirmScreen({
    Key? key,
    this.cardFeeConfig,
    this.selectedCoupon,
    this.skipKycCheck = false,
  }) : super(key: key);

  @override
  State<CardApplyConfirmScreen> createState() => _CardApplyConfirmScreenState();
}

class _CardApplyConfirmScreenState extends State<CardApplyConfirmScreen> {
  final CardFeeService _cardFeeService = CardFeeService();
  final KycService _kycService = KycService();
  final CardService _cardService = CardService();
  final GlobalService _globalService = GlobalService();
  final Dio dio = Dio();

  List<PaymentCurrencyModel> _paymentCurrencies = [];
  PaymentCurrencyModel? _selectedCurrency;
  CardFeeConfigModel? _cardFeeConfig;
  CardFeePaymentModel? _createdPayment;
  CouponDetailModel? _localSelectedCoupon;

  CardApplyState _currentState = CardApplyState.loading;

  String _kycFailReason = '';

  // Storage for user balances
  Map<String, Map<String, dynamic>> _walletBalances = {};
  bool _isProcessing = false;
  // Flag to prevent concurrent _initLogic calls (like double trigger from VisibilityDetector)
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _cardFeeConfig = widget.cardFeeConfig;
    _localSelectedCoupon = widget.selectedCoupon;

    if (widget.skipKycCheck) {
      // If skipping checks (e.g. re-entering), we rely on VisibilityDetector or specific logic
      // But typically VisibilityDetector will handle the initial load now.
    }
    // _initLogic(); // Removed to avoid double loading with VisibilityDetector
  }

  Future<void> _initLogic() async {
    // Debounce: If already loading, skip
    if (_isLoadingData) return;
    _isLoadingData = true;

    // 不要强制设为loading，否则会导致 VisibilityDetector 循环触发 (Content -> Loading -> Content -> Visibility Changed -> Loop)
    // 初始状态已在变量声明时设为 loading，所以首次进入仍会转圈。
    // 返回刷新时，不仅转圈直接刷新数据即可（静默刷新或使用 overlay loading，此处选择保留当前UI静默刷新）。

    // setState(() {
    //   _currentState = CardApplyState.loading;
    // });

    try {
      // 1. Check Card Fee Stats FIRST (New Logic with /CardFee/GetStats)
      final statsRes = await _cardFeeService.getCardStats();
      print(
          'CardApplyConfirmScreen: Needs Payment: ${statsRes.needsPaymentForNextCard}');

      // Logic: If needs payment is TRUE, then NOT paid.
      // If needs payment is FALSE, then Has Paid.
      final bool hasPaid = !statsRes.needsPaymentForNextCard;

      // New Rule: Check if user can apply for a new card (Max limit check)
      if (!statsRes.canApplyNewCard) {
        // Show blocking dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.hint),
              content: Text(AppLocalizations.of(context)!
                  .maxCardLimitReached(statsRes.maxCards.toString())),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Close screen
                  },
                  child: Text(AppLocalizations.of(context)!.confirm),
                ),
              ],
            );
          },
        );
        return; // Stop execution
      }

      // Logic: If NOT paid, show payment.
      if (!hasPaid) {
        // Not paid -> Payment State
        await _loadPaymentData();
        setState(() {
          _currentState = CardApplyState.payment;
        });
        return; // Stop here if not paid
      }

      // 2. If Eligible (Paid) - Check KYC Status for FIRST card only
      if (statsRes.successCards == 0) {
        // First card scenario - Need to check KYC
        try {
          final kycStatus = await _kycService.getKycStatus();
          final status = kycStatus.userKycStatus;
          print('=== KYC Debug Info ===');
          print('User KYC Status: $status');
          print('Latest KYC Status: ${kycStatus.latestKyc?.status}');
          print(
              'Latest KYC PokepayStatus: ${kycStatus.latestKyc?.pokepayStatus}');
          print('Can Submit KYC: ${kycStatus.canSubmitKyc}');
          print('Message: ${kycStatus.message}');
          print('=====================');

          // Check for approved status (could be various values)
          if (status == 'approved' ||
              status == 'verified' ||
              status == 'success' ||
              kycStatus.latestKyc?.pokepayStatus == 2) {
            // KYC Passed -> Show Receive Card
            setState(() {
              _currentState = CardApplyState.kycSuccess;
            });
          } else if (status == 'under_review' ||
              status == 'pending' ||
              status == 'reviewing') {
            // KYC Under Review
            setState(() {
              _currentState = CardApplyState.kycReviewing;
            });
          } else if (status == 'rejected' || status == 'failed') {
            // KYC Failed
            setState(() {
              _currentState = CardApplyState.kycFailed;
              _kycFailReason =
                  kycStatus.latestKyc?.failReason ?? kycStatus.message;
            });
          } else {
            // KYC Not Submitted (not_submitted or other)
            // Always show KYC pending submit screen with button to go to KYC
            setState(() {
              _currentState = CardApplyState.kycPendingSubmit;
            });
          }
        } catch (e) {
          print('Error checking KYC status: $e');
          // If error checking KYC, show KYC pending submit screen
          setState(() {
            _currentState = CardApplyState.kycPendingSubmit;
          });
        }
        return;
      }

      // Otherwise (successCards > 0), show Receive Card directly
      setState(() {
        _currentState = CardApplyState.kycSuccess;
      });
      return;
    } catch (e) {
      print('Error in card apply logic: $e');
      // If error, fallback to payment view or error view?
      // Let's show error snackbar and maybe stay loading or go to payment
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      // Ensure we reset the flag so retry or subsequent refresh works
      _isLoadingData = false;
    }
  }

  Future<void> _loadPaymentData() async {
    try {
      await _loadCardFeeConfig();
      await _loadUserBalances();

      final currencies = await _cardFeeService.getCurrencies();
      setState(() {
        _paymentCurrencies = currencies;
        if (currencies.isNotEmpty && _selectedCurrency == null) {
          _selectedCurrency = currencies[0];
        }
      });
    } catch (e) {
      print('Error loading payment data: $e');
    }
  }

  // --- Dialogs ---

  void _goToKyc() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Cardverificationscreen()),
    );
  }

  Future<void> _handleReceiveCard() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final request = CardApplyRequestModel(physical: false);
      final response = await _cardService.applyCard(request);

      if (!mounted) return;

      // Refresh Card List on Home/Card Screen
      try {
        Provider.of<CardViewModel>(context, listen: false).refreshCardList();
      } catch (e) {
        print('Error refreshing card list: $e');
      }

      // Navigate to success/progress screen
      // Use push instead of pushReplacement to wait for the result
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CardApplyProgressScreen(taskId: response.taskId),
        ),
      );

      // If progress screen returns true (success), we pop back to CardScreen with true
      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .failedToReceiveCard(e.toString())),
            backgroundColor: Colors.red),
      );
    }
  }

  // --- Helpers for Payment (Existing) ---

  Future<void> _loadCardFeeConfig() async {
    if (_cardFeeConfig != null) return;
    try {
      final config = await _cardFeeService.getConfig('virtual');
      setState(() {
        _cardFeeConfig = config;
      });
    } catch (e) {
      print('Error loading config: $e');
    }
  }

  Future<void> _loadUserBalances() async {
    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) return;
      final response = await dio.get(
        'http://149.88.65.193:8010/api/v1/wallet/',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == 'success' && data['wallet'] != null) {
          final balances = data['wallet']['balances'] as List<dynamic>? ?? [];
          setState(() {
            _walletBalances = {};
            for (var balance in balances) {
              final currency = balance['currency'] as String;
              final actualBalance =
                  (balance['balance'] as num?)?.toDouble() ?? 0.0;
              _walletBalances[currency] = {
                'balance': actualBalance,
                'logo': balance['logo'] ?? '',
                'coin_name': balance['coin_name'] ?? currency,
                'symbol': balance['symbol'] ?? '',
              };
            }
          });
        }
      }
    } catch (e) {
      print('Error loading balances: $e');
    }
  }

  double _getCurrencyBalance(String currencyName) {
    return _walletBalances[currencyName]?['balance'] ?? 0.0;
  }

  String _getCurrencyLogo(String currencyName) {
    return _walletBalances[currencyName]?['logo'] ?? '';
  }

  String _getCurrencyCoinName(String currencyName) {
    return _walletBalances[currencyName]?['coin_name'] ?? currencyName;
  }

  double _getActualPayment() {
    if (_createdPayment != null) return _createdPayment!.actualPayment;
    if (_cardFeeConfig == null) return 0.0;
    double amount = _cardFeeConfig!.feeAmount;
    if (_localSelectedCoupon != null) {
      if (_localSelectedCoupon!.valueType == 'percentage') {
        amount = amount * (1 - _localSelectedCoupon!.value / 100);
      } else {
        amount = amount - _localSelectedCoupon!.value;
      }
    }
    return amount.clamp(0.0, double.infinity);
  }

  Future<void> _handleSubmit() async {
    if (_selectedCurrency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context)!.pleaseSelectPaymentCurrency)),
      );
      return;
    }
    if (_getCurrencyBalance(_selectedCurrency!.name) < _getActualPayment()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.balanceInsufficient)),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final payment = await _cardFeeService.createPayment(
        cardType: 'virtual',
        couponCode: _localSelectedCoupon?.code,
      );
      setState(() => _createdPayment = payment);

      final confirmed = await _showPaymentConfirmDialog();
      if (confirmed == true) {
        // Pay
        await _completePayment(payment.transactionRef);
      } else {
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.failToCreatePayment}: $e')),
      );
    }
  }

  /// 显示支付确认底部弹窗 (Restored Detailed Version)
  Future<bool?> _showPaymentConfirmDialog() async {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽指示器
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // 标题
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.confirmPayment,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 支付详情卡片
              if (_createdPayment != null) ...[
                // 费用明细卡片（白色背景）
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 原始费用
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.originalFee,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '\$${_createdPayment!.originalFee.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      // 如果有优惠券折扣
                      if (_createdPayment!.couponDiscount > 0) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.couponDiscount,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '-\$${_createdPayment!.couponDiscount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.shade200, height: 1),
                      const SizedBox(height: 16),
                      // 实际支付金额（大号突出）
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.actualPayment,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => AppColors
                                    .primaryGradient
                                    .createShader(bounds),
                                child: Text(
                                  '\$${_createdPayment!.actualPayment.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                _selectedCurrency?.name ?? 'USD',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 交易参考号
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long,
                          size: 24, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.transactionRef,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _createdPayment!.transactionRef,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // 按钮组
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.confirmPayment,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _completePayment(String ref) async {
    if (_selectedCurrency == null) return;

    try {
      final successPayment = await _cardFeeService.completePayment(
        transactionRef: ref,
        paymentCurrency: _selectedCurrency!.name,
      );

      if (successPayment.status == 'completed' ||
          successPayment.status == 'success' ||
          successPayment.status == 'pending') {
        // Start polling for final status
        await _startPaymentPolling();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!
                .paymentNotCompleted(successPayment.status))));
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context)!.paymentFailed(e.toString()))));
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _startPaymentPolling() async {
    int retries = 0;
    while (retries < 30) {
      // Poll for 60 seconds (30 * 2s)
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      try {
        final statsRes = await _cardFeeService.getCardStats();
        // If needsPaymentForNextCard is false, it means payment is done/not needed
        if (!statsRes.needsPaymentForNextCard) {
          // Payment Success, Refresh Logic
          _initLogic();
          return;
        }
      } catch (e) {
        print('Polling error: $e');
      }
      retries++;
    }

    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context)!.paymentVerificationTimedOut)));
    }
  }

  /// 构建支付币种列表项 (Restored Old UI)
  Widget _buildCurrencyItem(PaymentCurrencyModel currency) {
    final balance = _getCurrencyBalance(currency.name);
    final actualPayment = _getActualPayment();
    final hasEnoughBalance = balance >= actualPayment;

    final isSelected =
        _selectedCurrency != null && _selectedCurrency!.name == currency.name;

    return Card(
      color: isSelected
          ? Colors.blue.shade50
          : hasEnoughBalance
              ? Colors.white
              : Colors.grey.shade100,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: hasEnoughBalance
            ? () {
                Navigator.pop(context, currency);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 使用wallet API返回的logo
              _getCurrencyLogo(currency.name).isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        _getCurrencyLogo(currency.name),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return CircleAvatar(
                            backgroundColor: hasEnoughBalance
                                ? Colors.blue.shade100
                                : Colors.grey.shade300,
                            radius: 20,
                            child: Text(
                              currency.symbol.substring(0, 1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: hasEnoughBalance
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : CircleAvatar(
                      backgroundColor: hasEnoughBalance
                          ? Colors.blue.shade100
                          : Colors.grey.shade300,
                      radius: 20,
                      child: Text(
                        currency.symbol.substring(0, 1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: hasEnoughBalance ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCurrencyCoinName(currency.name),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: hasEnoughBalance ? Colors.black : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currency.name,
                      style: TextStyle(
                        color: hasEnoughBalance
                            ? Colors.grey
                            : Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    balance.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: hasEnoughBalance ? Colors.black : Colors.red,
                    ),
                  ),
                  if (!hasEnoughBalance)
                    Text(
                      AppLocalizations.of(context)!.insufficient,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示支付币种选择底部弹窗 (Restored Old UI)
  Future<void> _showCurrencySelectionSheet() async {
    if (_paymentCurrencies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              AppLocalizations.of(context)!.noPaymentCurrenciesAvailable)));
      return;
    }

    final selected = await showModalBottomSheet<PaymentCurrencyModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.selectNetwork,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Currency list
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _paymentCurrencies.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final currency = _paymentCurrencies[index];
                      return _buildCurrencyItem(currency);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedCurrency = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text(_getTitle()),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: VisibilityDetector(
        key: const Key('card_apply_confirm_screen'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction == 1.0) {
            _initLogic();
          }
        },
        child: _buildBody(),
      ),
    );
  }

  String _getTitle() {
    switch (_currentState) {
      case CardApplyState.payment:
        return AppLocalizations.of(context)!.confirmPayment;
      case CardApplyState.kycReviewing:
        return AppLocalizations.of(context)!.reviewing;
      case CardApplyState.kycFailed:
        return AppLocalizations.of(context)!.verificationFailedTitle;
      case CardApplyState.kycSuccess:
        return AppLocalizations.of(context)!.success;
      default:
        return '';
    }
  }

  Widget _buildBody() {
    if (_currentState == CardApplyState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentState == CardApplyState.payment) {
      return _buildPaymentView();
    }

    return _buildStatusView();
  }

  Widget _buildStatusView() {
    IconData icon;
    Color color;
    String title;
    String message;
    List<Widget> actions = [];

    switch (_currentState) {
      case CardApplyState.kycReviewing:
        icon = Icons.access_time_filled;
        color = Colors.orange;
        title = AppLocalizations.of(context)!.underReview;
        message = AppLocalizations.of(context)!.kycReviewDesc;
        break;
      case CardApplyState.kycFailed:
        icon = Icons.cancel;
        color = Colors.red;
        title = AppLocalizations.of(context)!.verificationFailedTitle;
        message = _kycFailReason.isNotEmpty
            ? AppLocalizations.of(context)!
                .verificationFailedReason(_kycFailReason)
            : AppLocalizations.of(context)!.verificationFailedDesc;
        actions.add(
          ElevatedButton(
            onPressed: _goToKyc,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(AppLocalizations.of(context)!.retryVerification,
                style: const TextStyle(color: Colors.white)),
          ),
        );
        break;
      case CardApplyState.kycSuccess:
        icon = Icons.check_circle;
        color = Colors.green;
        title = AppLocalizations.of(context)!.verificationPassed;
        message = AppLocalizations.of(context)!.receiveCardEligibilityDesc;
        actions.add(
          ElevatedButton(
            onPressed: _handleReceiveCard,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(AppLocalizations.of(context)!.receiveCardNow,
                style: const TextStyle(color: Colors.white)),
          ),
        );
        break;
      case CardApplyState.kycPendingSubmit:
        icon = Icons.verified_user;
        color = Colors.blue;
        title = AppLocalizations.of(context)!.verificationRequiredTitle;
        message = AppLocalizations.of(context)!.kycRequiredDesc;
        actions.add(
          ElevatedButton(
            onPressed: _goToKyc,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(AppLocalizations.of(context)!.goToVerify,
                style: const TextStyle(color: Colors.white)),
          ),
        );
        break;
      default:
        return const SizedBox();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color),
            const SizedBox(height: 24),
            Text(title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 32),
            ...actions,
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡信息
          _buildSectionTitle(AppLocalizations.of(context)!.cardInformation),
          const SizedBox(height: 12),
          _buildInfoRow(
            AppLocalizations.of(context)!.cardName,
            AppLocalizations.of(context)!.typeCardFee ?? 'Come Come Pay Card',
            isClickable: false,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            AppLocalizations.of(context)!.cardOrganization,
            'VISA',
            isClickable: false,
          ),
          const SizedBox(height: 24),

          // 卡费
          _buildSectionTitle(AppLocalizations.of(context)!.cardFee),
          const SizedBox(height: 12),
          _buildInfoRow(
            AppLocalizations.of(context)!.originalFee,
            '${_cardFeeConfig?.feeAmount.toStringAsFixed(2) ?? '0.00'} USD',
            isClickable: false,
          ),
          const SizedBox(height: 8),
          _buildCurrencySelectionRow(),
          const SizedBox(height: 8),
          // 优惠券选择行（可点击）
          _buildCouponSelectionRow(),
          const SizedBox(height: 32),

          // 提交按钮
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _selectedCurrency == null || _isProcessing
                  ? null
                  : _handleSubmit,
              borderRadius: BorderRadius.circular(12),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: _selectedCurrency != null && !_isProcessing
                      ? AppColors.primaryGradient
                      : null,
                  color: _selectedCurrency == null || _isProcessing
                      ? Colors.grey.shade300
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  alignment: Alignment.center,
                  child: _isProcessing
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          AppLocalizations.of(context)!.submit,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _selectedCurrency != null
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    required bool isClickable,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? Colors.black,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isClickable) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelectionRow() {
    return GestureDetector(
      onTap: _showCurrencySelectionSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.selectNetwork,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                Text(
                  _selectedCurrency == null
                      ? AppLocalizations.of(context)!.pleaseSelect
                      : _selectedCurrency!.coinName,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        _selectedCurrency == null ? Colors.grey : Colors.black,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建优惠券选择行
  Widget _buildCouponSelectionRow() {
    return GestureDetector(
      onTap: _showCouponSelectionSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.coupon,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                Text(
                  _localSelectedCoupon == null
                      ? AppLocalizations.of(context)!.selectCoupon
                      : _localSelectedCoupon!.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: _localSelectedCoupon == null
                        ? Colors.grey
                        : Colors.green,
                    fontWeight: _localSelectedCoupon != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 显示优惠券选择底部弹窗
  Future<void> _showCouponSelectionSheet() async {
    try {
      // 使用新的 getCoupons API，只获取有效优惠券
      final response = await _globalService.getCoupons(onlyValid: true);

      if (!mounted) return;

      final coupons = response.coupons;

      if (coupons.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No available coupons')));
        return;
      }

      final selected = await showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.selectCoupon,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: coupons.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == coupons.length) {
                          return Card(
                            child: InkWell(
                              onTap: () => Navigator.pop(context, null),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(Icons.cancel_outlined,
                                        color: Colors.grey.shade600),
                                    const SizedBox(width: 12),
                                    Text(
                                      AppLocalizations.of(context)!.noCoupon,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final coupon = coupons[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: InkWell(
                            onTap: () => Navigator.pop(context, coupon),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          coupon.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          coupon.type == 'percentage'
                                              ? '-${coupon.value.toStringAsFixed(0)}%'
                                              : '-\$${coupon.value.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.receipt_long,
                                          size: 14,
                                          color: Colors.grey.shade600),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${AppLocalizations.of(context)!.code}: ${coupon.code}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.shopping_bag,
                                          size: 14,
                                          color: Colors.grey.shade600),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${AppLocalizations.of(context)!.minFee}: \$${coupon.minFee.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
      if (selected != null && mounted) {
        setState(() {
          _localSelectedCoupon = CouponDetailModel(
            id: selected.id,
            code: selected.code,
            name: selected.name,
            description: '',
            value: selected.value,
            valueType: selected.type,
            minTransactionAmount: selected.minFee,
            maxDiscount: selected.maxDiscount,
            usageLimit: 0,
            usageLimitPerUser: 0,
            usedCount: 0,
            status: 'active',
            expiresAt: selected.validUntil,
            createdBy: 0,
            createdAt: selected.assignedAt,
            updatedAt: selected.assignedAt,
          );
        });
      } else if (selected == null && _localSelectedCoupon != null && mounted) {
        setState(() {
          _localSelectedCoupon = null;
        });
      }
    } catch (e) {
      print('Error loading coupons: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load coupons')));
      }
    }
  }
}
