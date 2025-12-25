import 'package:flutter/material.dart';
import 'package:comecomepay/services/card_fee_service.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/services/kyc_service.dart';
import 'package:comecomepay/models/card_fee_config_model.dart';
import 'package:comecomepay/models/responses/coupon_detail_model.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/views/homes/CardVerificationScreen.dart';
import 'package:comecomepay/utils/app_colors.dart';

class CardApplyCardScreen extends StatefulWidget {
  const CardApplyCardScreen({super.key});

  @override
  State<CardApplyCardScreen> createState() => _CardApplyCardScreenState();
}

class _CardApplyCardScreenState extends State<CardApplyCardScreen> {
  final CardFeeService _cardFeeService = CardFeeService();
  final GlobalService _globalService = GlobalService();
  final KycService _kycService = KycService();

  CardFeeConfigModel? _cardFeeConfig;
  CouponDetailModel? _selectedCoupon;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPaymentStatusAndNavigate();
  }

  /// 检查KYC资格并决定导航
  Future<void> _checkPaymentStatusAndNavigate() async {
    print('🔍 Checking KYC eligibility...');
    try {
      setState(() {
        _isLoading = true;
      });

      // 调用KYC eligibility接口检查用户状态
      print('📡 Calling KYC eligibility API...');
      final eligibility = await _kycService.checkEligibility();
      print(
          '✅ Eligibility response: eligible=${eligibility.eligible}, payment_status=${eligibility.paymentStatus}, reason="${eligibility.reason}"');

      if (eligibility.eligible) {
        // 已支付，有资格进行KYC，显示提示后跳转
        print('🚀 User is eligible for KYC, showing confirm dialog...');
        if (!mounted) return;

        // 显示提示对话框
        await _showAlreadyPaidDialog();
        return;
      } else {
        // 未支付或其他原因不符合资格
        print('⚠️ User not eligible. Reason: ${eligibility.reason}');
        if (eligibility.reason.contains('payment') ||
            eligibility.reason.contains('Card fee')) {
          // 需要支付，继续正常申请流程
          print('📝 Payment required, loading card application form...');
          await _loadCardFeeConfig();
        } else {
          // 其他原因不符合资格
          print('❌ Other eligibility issue: ${eligibility.reason}');
          if (!mounted) return;
          setState(() {
            _errorMessage = eligibility.reason;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error checking eligibility: $e');
      print('Stack trace: ${StackTrace.current}');
      // 检查失败，继续正常流程（降级处理）
      await _loadCardFeeConfig();
    }
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
                  '您已完成开卡费支付，现在可以进行KYC身份验证了。',
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
                        onPressed: () => Navigator.of(context).pop(false),
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
                          child: const Text(
                            '前往验证',
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
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final config = await _cardFeeService.getConfig('virtual');
      setState(() {
        _cardFeeConfig = config;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            '${AppLocalizations.of(context)!.failedToLoadCardFee}: $e';
        _isLoading = false;
      });
      print('Error loading card fee config: $e');
    }
  }

  /// 显示优惠券选择底部弹窗
  Future<void> _showCouponSelectionSheet() async {
    try {
      // 获取可用优惠券列表
      // getMyCoupons使用位置参数: (String status, int page, int limit)
      final response = await _globalService.getMyCoupons(
        '1', // status: 1 = available
        1, // page
        50, // limit
      );

      if (!mounted) return;

      // CouponModel包含coupon属性，类型是CouponDetailModel
      final coupons = response.coupons.map((c) => c.coupon).toList();

      if (coupons.isEmpty) {
        _showMessage(AppLocalizations.of(context)!.noAvailableCoupons);
        return;
      }

      final selected = await showModalBottomSheet<CouponDetailModel>(
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
                  // Coupon list
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          coupons.length + 1, // +1 for "No coupon" option
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        // First item: No coupon option
                        if (index == 0) {
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

                        final coupon = coupons[index - 1];
                        return _buildCouponItem(coupon);
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
          _selectedCoupon = selected;
        });
      } else if (selected == null && _selectedCoupon != null) {
        // 用户选择了"No coupon"
        setState(() {
          _selectedCoupon = null;
        });
      }
    } catch (e) {
      print('Error loading coupons: $e');
      _showMessage(AppLocalizations.of(context)!.failedToLoadCoupons);
    }
  }

  /// 构建优惠券列表项
  Widget _buildCouponItem(CouponDetailModel coupon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Navigator.pop(context, coupon),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      coupon.valueType == 'percentage'
                          ? '-${coupon.value.toStringAsFixed(0)}%'
                          : '-\$${coupon.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              if (coupon.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  coupon.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '${AppLocalizations.of(context)!.code}: ${coupon.code}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)!.applyCard),
      ),
      body: _isLoading
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
                        onPressed: _loadCardFeeConfig,
                        child: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.cardInformation,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // 卡片信息网格布局（一行最多3个）
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = (constraints.maxWidth - 24) / 3; // 减去spacing
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildInfoCard(
                                context,
                                cardWidth,
                                AppLocalizations.of(context)!.cardName,
                                _cardFeeConfig?.description ??
                                    AppLocalizations.of(context)!.comeComePayCard,
                              ),
                              _buildInfoCard(
                                context,
                                cardWidth,
                                AppLocalizations.of(context)!.cardOrganization,
                                'VISA',
                              ),
                              _buildInfoCard(
                                context,
                                cardWidth,
                                AppLocalizations.of(context)!.cardFee,
                                '${_cardFeeConfig?.feeAmount.toStringAsFixed(2) ?? '0.00'} USD',
                              ),
                              _buildInfoCard(
                                context,
                                cardWidth,
                                AppLocalizations.of(context)!.coupon,
                                _selectedCoupon == null
                                    ? AppLocalizations.of(context)!.available
                                    : _selectedCoupon!.name,
                                onTap: _showCouponSelectionSheet,
                              ),
                            ],
                          );
                        },
                      ),
                      const Spacer(),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // 跳转到确认页面，传递选择的优惠券
                            Navigator.pushNamed(
                              context,
                              '/CardCompliteApplyScreen',
                              arguments: {
                                'cardFeeConfig': _cardFeeConfig,
                                'selectedCoupon': _selectedCoupon,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: Text(AppLocalizations.of(context)!.submit                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  /// 构建信息卡片（网格布局）
  Widget _buildInfoCard(
    BuildContext context,
    double width,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (onTap != null) ...[
                  const SizedBox(height: 4),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
