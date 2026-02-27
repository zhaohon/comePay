import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/models/card_account_details_model.dart';
import 'package:comecomepay/models/country_model.dart';
import 'package:comecomepay/services/card_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/models/payment_currency_model.dart';
import 'package:dio/dio.dart';
import 'ApplyPhysicalCardSuccessScreen.dart';

class ApplyPhysicalCardScreen extends StatefulWidget {
  final CardAccountDetailsModel? cardDetails;

  const ApplyPhysicalCardScreen({super.key, this.cardDetails});

  @override
  State<ApplyPhysicalCardScreen> createState() =>
      _ApplyPhysicalCardScreenState();
}

class _ApplyPhysicalCardScreenState extends State<ApplyPhysicalCardScreen> {
  final _formKey = GlobalKey<FormState>(); // Form Key for validation

  final CardService _cardService = CardService();
  final Dio dio = Dio();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailCodeController = TextEditingController();

  // Selected Country
  List<Country> _countries = [];
  Country? _selectedCountry;
  bool _isLoadingCountries = true;

  // Fee & Currency data
  List<PaymentCurrencyModel> _currencies = [];
  PaymentCurrencyModel? _selectedCurrency;
  Map<String, Map<String, dynamic>> _walletBalances = {};
  bool _isLoadingFeeInfo = true;

  // Verification Timer
  Timer? _countdownTimer;
  int _remainingTime = 0;

  // Fees
  double _cardFee = 0.0;
  final double _shippingFee = 0.00;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _fetchFeeInfoAndBalances();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _nameController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    _emailCodeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _remainingTime = 60;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchFeeInfoAndBalances() async {
    try {
      final feeInfo = await _cardService.getPhysicalUpgradeFeeInfo();

      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken != null) {
        final response = await dio.get(
          'http://149.88.65.193:8010/api/v1/wallet/',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          if (data['status'] == 'success' && data['wallet'] != null) {
            final balances = data['wallet']['balances'] as List<dynamic>? ?? [];
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
          }
        }
      }

      setState(() {
        _cardFee = feeInfo.upgradeAmount;
        _currencies = feeInfo.currencies;
        if (_currencies.isNotEmpty) {
          _selectedCurrency = _currencies.first;
        }
        _isLoadingFeeInfo = false;
      });
    } catch (e) {
      debugPrint('Error loading fee info or balances: $e');
      setState(() {
        _isLoadingFeeInfo = false;
      });
    }
  }

  double _getCurrencyBalance(String currencyName) {
    return _walletBalances[currencyName]?['balance'] ?? 0.0;
  }

  String _getCurrencyLogo(String currencyName) {
    return _walletBalances[currencyName]?['logo'] ?? '';
  }

  /// Load countries from JSON
  Future<void> _loadCountries() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/countries.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _countries = jsonList.map((json) => Country.fromJson(json)).toList();
        // Default to China similar to CardVerificationScreen logic
        _selectedCountry = _countries.firstWhere(
          (country) => country.code == 'CN',
          orElse: () => _countries.first,
        );
        _isLoadingCountries = false;
      });
    } catch (e) {
      debugPrint('Error loading countries: $e');
      setState(() {
        _isLoadingCountries = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.applyPhysicalCard,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 卡信息
              _buildSectionTitle(l10n.cardInformation),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  children: [
                    _buildInfoRow(context, l10n.cardHolderName,
                        widget.cardDetails?.memberName ?? 'N/A'),
                    const SizedBox(height: 16),
                    _buildInfoRow(context, l10n.cardOrganization,
                        _formatCardScheme(widget.cardDetails?.cardScheme)),
                    const SizedBox(height: 16),
                    _buildInfoRow(context, l10n.cardNumber,
                        widget.cardDetails?.cardNo ?? '**** **** **** ****'),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                        context,
                        l10n.expiryDateLabel
                            .replaceAll(':', '')
                            .replaceAll('：', '')
                            .trim(),
                        l10n.sameAsVirtualCard,
                        isCustomValue: true),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                        context,
                        l10n.cvvLabel
                            .replaceAll(':', '')
                            .replaceAll('：', '')
                            .trim(),
                        l10n.sameAsVirtualCard,
                        isCustomValue: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. 邮寄地址
              _buildSectionTitle(l10n.mailingAddress),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 姓名
                    _buildTextFieldLabel(l10n.recipientName),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hintText: l10n.enterRecipientName,
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.enterRecipientName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // 居住国家/地区
                    _buildTextFieldLabel(l10n.countryRegionLabel),
                    const SizedBox(height: 8),
                    _buildCountryDropdown(l10n),
                    const SizedBox(height: 20),

                    // 州/省
                    _buildTextFieldLabel(l10n.stateProvinceLabel),
                    const SizedBox(height: 8),
                    _buildTextField(
                        controller: _stateController,
                        hintText: l10n.enterStateProvinceHint,
                        prefixIcon: Icons.map_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.enterStateProvinceHint;
                          }
                          return null;
                        }),
                    const SizedBox(height: 20),

                    // 城市
                    _buildTextFieldLabel(l10n.cityLabel),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _cityController,
                      hintText: l10n.enterCityHint,
                      prefixIcon: Icons.location_city_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.enterCityHint;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // 详细地址
                    _buildTextFieldLabel(l10n.detailedAddressLabel),
                    const SizedBox(height: 8),
                    _buildTextField(
                        controller: _addressController,
                        hintText: l10n.enterDetailedAddressHint,
                        maxLines: 2,
                        prefixIcon: Icons.home_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.enterDetailedAddressHint;
                          }
                          return null;
                        }),
                    const SizedBox(height: 20),

                    // 邮编
                    _buildTextFieldLabel(l10n.postCodeLabel),
                    const SizedBox(height: 8),
                    _buildTextField(
                        controller: _zipController,
                        hintText: l10n.enterPostCodeHint,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.markunread_mailbox_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.enterPostCodeHint;
                          }
                          return null;
                        }),
                    const SizedBox(height: 20),

                    // 手机
                    _buildTextFieldLabel(l10n.mobilePhoneLabel),
                    const SizedBox(height: 8),
                    _buildPhoneInput(l10n),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. 卡片费用
              _buildSectionTitle(l10n.cardFees),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('支付币种',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    _buildPaymentCurrencyDropdown(l10n),
                    const SizedBox(height: 16),
                    _buildFeeRow(l10n.cardFee, _cardFee, currency: "USD"),
                    const SizedBox(height: 16),
                    _buildFeeRow(l10n.shippingFee, _shippingFee,
                        currency: "USD"),
                    const SizedBox(height: 16),
                    // 优惠券行暂且隐藏
                    // _buildCouponRow(l10n),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                    ),
                    _buildFeeRow(l10n.totalFee,
                        _cardFee + _shippingFee /* - _couponDiscount */,
                        isTotal: true, currency: "USD"),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 4. 提交按钮
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // 假设验证通过，先弹出验证码弹窗 (硬编码Mock)
                      _showVerificationDialog(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.checkAndFixInputErrors),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.submit,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFF9CA3AF), size: 20)
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
    );
  }

  Widget _buildCountryDropdown(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: _isLoadingCountries
            ? const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : DropdownButton<Country>(
                value: _selectedCountry,
                hint: Text(l10n.pleaseSelectCountry,
                    style: const TextStyle(
                        color: Color(0xFF9CA3AF), fontSize: 14)),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    size: 20, color: Color(0xFF9CA3AF)),
                onChanged: (Country? newValue) {
                  setState(() {
                    _selectedCountry = newValue;
                  });
                },
                items:
                    _countries.map<DropdownMenuItem<Country>>((Country value) {
                  return DropdownMenuItem<Country>(
                    value: value,
                    child: Row(
                      children: [
                        Text(value.flag, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            value.name,
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildPaymentCurrencyDropdown(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: _isLoadingFeeInfo
            ? const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : DropdownButton<PaymentCurrencyModel>(
                value: _selectedCurrency,
                hint: const Text('请选择支付币种',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    size: 20, color: Color(0xFF9CA3AF)),
                onChanged: (PaymentCurrencyModel? newValue) {
                  setState(() {
                    _selectedCurrency = newValue;
                  });
                },
                items: _currencies.map<DropdownMenuItem<PaymentCurrencyModel>>(
                    (PaymentCurrencyModel value) {
                  final bal = _getCurrencyBalance(value.name);
                  return DropdownMenuItem<PaymentCurrencyModel>(
                    value: value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (_getCurrencyLogo(value.name).isNotEmpty) ...[
                              Image.network(_getCurrencyLogo(value.name),
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.monetization_on,
                                      size: 20)),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              value.name,
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        Text(
                          '余额: \$${bal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: bal >=
                                    (_cardFee +
                                        _shippingFee) // - _couponDiscount
                                ? AppColors.textSecondary
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildPhoneInput(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align to top
      children: [
        // Country Code
        Container(
          width: 100,
          height: 52, // Match TextForm Field height approx
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _selectedCountry?.flag ?? '🏳️',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 4),
              Text(
                _selectedCountry?.dialCode ?? '+86',
                style:
                    const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            // Use TextFormField directly here
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.enterMobileNumberHint;
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: l10n.enterMobileNumberHint,
              hintStyle:
                  const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value,
      {bool isCustomValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isCustomValue ? FontWeight.normal : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFeeRow(String label, double amount,
      {bool isTotal = false, String currency = "USD"}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          "$amount $currency",
          style: TextStyle(
            color:
                isTotal ? AppColors.primary : AppColors.textPrimary, // 合计显示主色
            fontSize: 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatCardScheme(String? scheme) {
    if (scheme == null || scheme.isEmpty) return 'VISA'; // Default fallback
    return scheme.toUpperCase();
  }

  /// 显示交易安全验证弹窗
  void _showVerificationDialog(BuildContext context) {
    // 假设费用
    final fee = _cardFee + _shippingFee; // - _couponDiscount
    // 硬编码测试邮箱
    final maskEmail = "2855675294@qq.com";
    final publicToken = widget.cardDetails?.publicToken ?? "test_token"; // 防止为空

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题与关闭按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "交易信息",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close,
                          color: AppColors.textPrimary, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 提示说明文案 (富文本高亮费用)
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: "我们将从您的账户扣除卡片费用"),
                      TextSpan(
                        text: "${fee.toStringAsFixed(0)}USD",
                        style:
                            const TextStyle(color: Color(0xFFE56973)), // 红色高亮
                      ),
                      const TextSpan(text: "，为了您的账户安全，我们需要对您进行安全验证。"),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 邮箱验证码标题
                const Text(
                  "邮箱验证码",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                // 验证码输入框与获取按钮
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _emailCodeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "请输入邮箱验证码",
                            hintStyle: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _remainingTime > 0
                            ? null
                            : () async {
                                try {
                                  await _cardService
                                      .sendPhysicalUpgradeEmailCode(
                                          publicToken, maskEmail);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('验证码已发送')),
                                    );
                                    // 启动倒计时，并同步更新 Modal 内部的 state
                                    _startCountdown();
                                    setModalState(() {});
                                    // 监听 timer 变化更新 modal
                                    Timer.periodic(const Duration(seconds: 1),
                                        (timer) {
                                      if (!mounted || _remainingTime == 0) {
                                        timer.cancel();
                                      }
                                      setModalState(() {});
                                    });
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('发送失败: $e')),
                                    );
                                  }
                                }
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _remainingTime > 0
                                ? "$_remainingTime 秒后重发"
                                : "获取验证码",
                            style: TextStyle(
                              color: _remainingTime > 0
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF10B981), // 绿色
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 底部倒计时提示
                Text(
                  "6位数字验证码已发送至您的$maskEmail，请在5分钟内输入",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 32),

                // 确认按钮
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A), // 深色按钮
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_emailCodeController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请输入邮箱验证码')),
                        );
                        return;
                      }

                      // 弹出加载中的提示框
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext loadingCtx) {
                          return Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                      color: AppColors.primary),
                                  SizedBox(height: 16),
                                  Text(
                                    "处理中...",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );

                      try {
                        // 1. 验证邮箱验证码
                        final verifyToken =
                            await _cardService.verifyPhysicalUpgradeEmailCode(
                          publicToken,
                          _emailCodeController.text.trim(),
                        );

                        if (context.mounted) {
                          // 关掉加载框
                          Navigator.pop(context);
                          // 先收起底部弹窗
                          Navigator.pop(ctx);

                          // TODO: 接着调用最终的提交升级申请接口
                          // 带着这个 verifyToken 去请求

                          // 假装提交成功跳到成功页
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ApplyPhysicalCardSuccessScreen(),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          // 关掉加载框
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('验证失败: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "确认",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
