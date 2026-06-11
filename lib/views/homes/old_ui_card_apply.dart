import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/views/homes/CardVerificationScreen.dart';
import 'package:comecomepay/views/homes/CardApplyProgressScreen.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/services/card_fee_service.dart';
import 'package:comecomepay/services/kyc_service.dart';
import 'package:comecomepay/services/card_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/models/card_fee_config_model.dart';
import 'package:comecomepay/models/payment_currency_model.dart';
import 'package:comecomepay/models/card_fee_payment_model.dart';
import 'package:comecomepay/models/card_apply_model.dart';
import 'package:comecomepay/viewmodels/card_viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:comecomepay/models/responses/coupon_detail_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/models/responses/new_coupon_model.dart';

class CardApplyConfirmScreen extends StatefulWidget {
  final CardFeeConfigModel? cardFeeConfig;
  final CouponDetailModel? selectedCoupon;
  final bool skipKycCheck; // 是否跳过KYC检查（已有卡片时使用）

  const CardApplyConfirmScreen({
    Key? key,
    this.cardFeeConfig,
    this.selectedCoupon,
    this.skipKycCheck = false, // 默认不跳过
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
  CouponDetailModel? _localSelectedCoupon; // 本地选中的优惠券

  bool _isLoadingCurrencies = true;
  bool _isLoadingConfig = false;
  bool _isProcessing = false;
  String? _errorMessage;

  // 用于存储用户各币种的完整信息（包括余额、logo等）
  Map<String, Map<String, dynamic>> _walletBalances = {};

  @override
  void initState() {
    super.initState();
    _cardFeeConfig = widget.cardFeeConfig;
    _localSelectedCoupon = widget.selectedCoupon; // 初始化为传入的优惠券

    // 如果跳过KYC检查（已有卡片），直接加载支付数据
    if (widget.skipKycCheck) {
      _loadData();
    } else {
      // 首次申请，需要检查KYC资格
      _checkEligibilityAndLoadData();
    }
  }

  /// 检查KYC资格并加载数据（仅首次申请时使用）
  Future<void> _checkEligibilityAndLoadData() async {
    print('🔍 [CardApplyConfirmScreen] Checking KYC eligibility...');
    try {
      // 检查KYC资格
      final eligibility = await _kycService.checkEligibility();
      print(
          '✅ [CardApplyConfirmScreen] Eligibility: eligible=${eligibility.eligible}, reason="${eligibility.reason}"');

      if (eligibility.eligible) {
        // 已支付，有资格进行KYC，显示提示后跳转
        print(
            '🚀 [CardApplyConfirmScreen] User already paid, showing confirm dialog...');
        if (!mounted) return;

        // 显示提示对话框
        await _showAlreadyPaidDialog();
        return;
      }

      // 未支付，继续正常流程
      print(
          '📝 [CardApplyConfirmScreen] User not paid, loading payment data...');
      await _loadData();
    } catch (e) {
      print('❌ [CardApplyConfirmScreen] Error checking eligibility: $e');
      // 检查失败，继续正常流程（降级处理）
      await _loadData();
    }
  }

  /// 加载数据
  Future<void> _loadData() async {
    await Future.wait([
      _loadCardFeeConfig(),
      _loadPaymentCurrencies(),
      _loadUserBalances(),
    ]);
  }

  /// 显示已支付提示对话框
  Future<void> _showAlreadyPaidDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 图标（紫色）
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),

                // 标题
                Text(
                  AppLocalizations.of(context)!.paymentSuccessful,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // 内容
                Text(
                  AppLocalizations.of(context)!.paymentCompletedKycPrompt,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),

                // 按钮组（返回 | 前往验证）
                Row(
                  children: [
                    // 返回按钮
                    Expanded(
                      child: TextButton(
                        onPressed: () => {
                          // 返回两次
                          Navigator.pop(context),
                          Navigator.pop(context),
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.goBack,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 前往验证按钮（渐变）
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.goToVerify,
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
          ),
        );
      },
    );

    if (result == true && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Cardverificationscreen(),
        ),
      );
    }
  }

  /// 加载开卡费配置
  Future<void> _loadCardFeeConfig() async {
    if (_cardFeeConfig != null) return;

    try {
      setState(() {
        _isLoadingConfig = true;
        _errorMessage = null;
      });

      final config = await _cardFeeService.getConfig('virtual');
      setState(() {
        _cardFeeConfig = config;
        _isLoadingConfig = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            '${AppLocalizations.of(context)!.failToLoadCardFeeConfig}: $e';
        _isLoadingConfig = false;
      });
      print('Error loading card fee config: $e');
    }
  }

  /// 加载支付币种列表
  Future<void> _loadPaymentCurrencies() async {
    try {
      setState(() {
        _isLoadingCurrencies = true;
        _errorMessage = null;
      });

      final currencies = await _cardFeeService.getCurrencies();
      setState(() {
        _paymentCurrencies = currencies;
        _isLoadingCurrencies = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            '${AppLocalizations.of(context)!.failToLoadPaymentCurrencies}: $e';
        _isLoadingCurrencies = false;
      });
      print('Error loading payment currencies: $e');
    }
  }

  /// 加载用户钱包余额
  Future<void> _loadUserBalances() async {
    try {
      // 使用wallet API直接获取余额
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) return;

      final response = await dio.get(
        'https://app.comecomepay.com/api/v1/wallet/',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == 'success' && data['wallet'] != null) {
          final balances = data['wallet']['balances'] as List<dynamic>? ?? [];

          setState(() {
            // 将balances数组转换为Map，以currency为key
            _walletBalances = {};
            for (var balance in balances) {
              final currency = balance['currency'] as String;
              // balance就是实际余额，不需要除以decimals
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
      print('Error loading user balances: $e');
      // 不阻塞UI，只打印错误
    }
  }

  /// 获取币种的用户余额
  double _getCurrencyBalance(String currencyName) {
    return _walletBalances[currencyName]?['balance'] ?? 0.0;
  }

  /// 获取币种的logo
  String _getCurrencyLogo(String currencyName) {
    return _walletBalances[currencyName]?['logo'] ?? '';
  }

  /// 获取币种的显示名称
  String _getCurrencyCoinName(String currencyName) {
    return _walletBalances[currencyName]?['coin_name'] ?? currencyName;
  }

  /// 显示支付币种选择底部弹窗
  Future<void> _showCurrencySelectionSheet() async {
    if (_paymentCurrencies.isEmpty) {
      _showMessage(AppLocalizations.of(context)!.noPaymentCurrenciesAvailable);
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

  /// 构建支付币种列表项
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
                          // 如果图片加载失败，显示默认头像
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

  /// 获取实际支付金额
  double _getActualPayment() {
    if (_createdPayment != null) {
      return _createdPayment!.actualPayment;
    }

    if (_cardFeeConfig == null) return 0.0;

    // 如果有优惠券，需要计算折扣
    double amount = _cardFeeConfig!.feeAmount;
    if (_localSelectedCoupon != null) {
      final coupon = _localSelectedCoupon!;
      if (coupon.valueType == 'percentage') {
        // 百分比折扣
        amount = amount * (1 - coupon.value / 100);
      } else {
        // 固定金额折扣
        amount = amount - coupon.value;
      }
    }
    return amount.clamp(0.0, double.infinity);
  }

  /// 创建支付订单并显示确认对话框
  Future<void> _handleSubmit() async {
    if (_selectedCurrency == null) {
      _showMessage(AppLocalizations.of(context)!.pleaseSelectPaymentCurrency);
      return;
    }

    final actualPayment = _getActualPayment();
    final balance = _getCurrencyBalance(_selectedCurrency!.name);

    if (balance < actualPayment) {
      _showMessage(AppLocalizations.of(context)!.balanceInsufficient);
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
      });

      // 步骤1: 创建支付订单
      final payment = await _cardFeeService.createPayment(
        cardType: 'virtual',
        couponCode: _localSelectedCoupon?.code,
      );

      setState(() {
        _createdPayment = payment;
      });

      // 步骤2: 显示确认对话框
      final confirmed = await _showPaymentConfirmDialog();

      if (confirmed == true) {
        // 步骤3: 完成支付
        await _completePayment(payment.transactionRef);
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showMessage('${AppLocalizations.of(context)!.failToCreatePayment}: $e');
      print('Error creating payment: $e');
    }
  }

  /// 显示支付确认底部弹窗
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
                            'Original Fee',
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
                              'Transaction Ref',
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
                          style: TextStyle(
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

  /// 构建支付详情行
  Widget _buildPaymentDetailRow(
    String label,
    String value, {
    bool isWhiteText = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: isWhiteText
                ? Colors.white.withOpacity(0.9)
                : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor ??
                (isWhiteText ? Colors.white : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  /// 完成支付
  Future<void> _completePayment(String transactionRef) async {
    try {
      // 步骤1: 调用CompletePayment（发起支付请求）
      await _cardFeeService.completePayment(
        transactionRef: transactionRef,
        paymentCurrency: _selectedCurrency!.name,
      );

      // 步骤2: 轮询支付状态，等待支付真正完成
      final paymentCompleted = await _pollPaymentStatus(transactionRef);

      setState(() {
        _isProcessing = false;
      });

      if (!paymentCompleted) {
        if (!mounted) return;
        _showMessage(
            'Payment processing timeout. Please check payment status.');
        return;
      }

      // 步骤3: 支付成功
      // 无论eligibility如何，支付成功后都应该进入KYC流程（或者进入Cardverificationscreen进行状态判断）
      // 这里的eligibility.eligible通常表示已支付

      if (!mounted) return;
      _showMessage(AppLocalizations.of(context)!.paymentSuccessful);

      // 跳转到KYC页面
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Cardverificationscreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (!mounted) return;
      _showMessage('Payment error: $e');
      print('Error completing payment: $e');
    }
  }

  /// 轮询支付状态
  /// 返回true表示支付成功，false表示超时或失败
  Future<bool> _pollPaymentStatus(String transactionRef) async {
    const maxAttempts = 10; // 最多尝试10次
    const pollInterval = Duration(seconds: 2); // 每2秒检查一次

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        // 等待一段时间后再查询
        if (attempt > 0) {
          await Future.delayed(pollInterval);
        }

        print('Polling payment status, attempt ${attempt + 1}/$maxAttempts');

        // 查询支付状态
        final paymentStatus = await _cardFeeService.getPaymentStatus();

        if (paymentStatus != null &&
            paymentStatus.transactionRef == transactionRef) {
          if (paymentStatus.status == 'completed') {
            print('Payment completed successfully');
            return true;
          } else if (paymentStatus.status == 'failed') {
            print('Payment failed');
            return false;
          }
          // 如果是pending，继续轮询
          print(
              'Payment status: ${paymentStatus.status}, continuing to poll...');
        }
      } catch (e) {
        print('Error polling payment status: $e');
        // 继续尝试
      }
    }

    // 超时
    print('Payment status polling timeout');
    return false;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isLoadingCurrencies || _isLoadingConfig;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.applyVirtualCard,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 卡信息
                      _buildSectionTitle(
                          AppLocalizations.of(context)!.cardInformation),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        AppLocalizations.of(context)!.cardName,
                        AppLocalizations.of(context)!.typeCardFee ??
                            'Come Come Pay Card',
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
                              gradient:
                                  _selectedCurrency != null && !_isProcessing
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
            const Text(
              'Coupon',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                Text(
                  _localSelectedCoupon == null
                      ? 'Select Coupon'
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
        _showMessage('No available coupons');
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
                        const Text(
                          'Select Coupon',
                          style: TextStyle(
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
                  // Coupon list
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: coupons.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        // Last item: No coupon option (移到最下方)
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
                                    const Text(
                                      'No Coupon',
                                      style: TextStyle(
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
                                        'Code: ${coupon.code}',
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
                                        'Min Fee: \$${coupon.minFee.toStringAsFixed(2)}',
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
        _showMessage('Failed to load coupons');
      }
    }
  }
}
