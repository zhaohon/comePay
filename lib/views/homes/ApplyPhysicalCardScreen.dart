import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/models/card_account_details_model.dart';
import 'package:comecomepay/models/country_model.dart';

class ApplyPhysicalCardScreen extends StatefulWidget {
  final CardAccountDetailsModel? cardDetails;

  const ApplyPhysicalCardScreen({super.key, this.cardDetails});

  @override
  State<ApplyPhysicalCardScreen> createState() =>
      _ApplyPhysicalCardScreenState();
}

class _ApplyPhysicalCardScreenState extends State<ApplyPhysicalCardScreen> {
  final _formKey = GlobalKey<FormState>(); // Form Key for validation

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Selected Country
  List<Country> _countries = [];
  Country? _selectedCountry;
  bool _isLoadingCountries = true;

  // Fees
  final double _cardFee = 88.00;
  final double _shippingFee = 0.00;
  final double _couponDiscount = 0.00;

  @override
  void initState() {
    super.initState();
    _loadCountries();
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
                  children: [
                    _buildFeeRow(l10n.cardFee, _cardFee, currency: "USD"),
                    const SizedBox(height: 16),
                    _buildFeeRow(l10n.shippingFee, _shippingFee,
                        currency: "USD"),
                    const SizedBox(height: 16),
                    // 优惠券行
                    _buildCouponRow(l10n),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                    ),
                    _buildFeeRow(l10n.totalFee,
                        _cardFee + _shippingFee - _couponDiscount,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.applicationSubmittedSuccessfully),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      Navigator.pop(context);
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

  Widget _buildCouponRow(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.coupon,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: Select Coupon
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(20), // Pill shape
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.noCouponAvailable,
                  style:
                      const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios,
                    size: 12, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatCardScheme(String? scheme) {
    if (scheme == null || scheme.isEmpty) return 'VISA'; // Default fallback
    return scheme.toUpperCase();
  }
}
