import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comecomepay/viewmodels/profile_screen_viewmodel.dart';
import 'package:comecomepay/views/homes/ProfilKycDiditScreen.dart';
import 'package:comecomepay/models/requests/didit_initialize_token_request_model.dart';
import 'package:comecomepay/models/country_model.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/services/kyc_service.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

class Cardverificationscreen extends StatefulWidget {
  const Cardverificationscreen({Key? key}) : super(key: key);

  @override
  State<Cardverificationscreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<Cardverificationscreen> {
  late ProfileScreenViewModel _viewModel;
  final KycService _kycService = KycService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();

  // 国家数据
  List<Country> _countries = [];
  Country? _selectedCountry;
  bool _isLoadingCountries = true;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileScreenViewModel();
    _loadCountries(); // 加载国家数据
    _checkEligibility(); // 检查KYC资格
  }

  /// 从JSON文件加载国家数据
  Future<void> _loadCountries() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/countries.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _countries = jsonList.map((json) => Country.fromJson(json)).toList();
        // 默认选择中国
        _selectedCountry = _countries.firstWhere(
          (country) => country.code == 'CN',
          orElse: () => _countries.first,
        );
        _isLoadingCountries = false;
      });
    } catch (e) {
      print('Error loading countries: $e');
      setState(() {
        _isLoadingCountries = false;
      });
    }
  }

  /// 检查用户是否有资格进行KYC认证
  Future<void> _checkEligibility() async {
    try {
      final eligibility = await _kycService.checkEligibility();

      if (!eligibility.eligible) {
        // 用户没有资格进行KYC
        if (!mounted) return;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.paymentRequired),
            content: Text(
              eligibility.reason.isEmpty
                  ? 'You need to complete the card fee payment before proceeding with KYC verification.'
                  : eligibility.reason,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to previous screen
                },
                child: Text(AppLocalizations.of(context)!.goBack),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error checking KYC eligibility: $e');
      // 发生错误时，允许用户继续（可选：也可以阻止）
      // 这里选择打印错误但不阻止用户
    }
  }

  @override
  Widget build(BuildContext context) {
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
          AppLocalizations.of(context)!.verification,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNameTextField("Name", controller: _nameController),
                _buildNameTextField("Surname", controller: _surnameController),
                const SizedBox(height: 10),

                // Mobile Phone
                const Text(
                  "Mobile Phone",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCountry?.flag ?? '🏳️',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedCountry?.dialCode ?? '+86',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter mobile number',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Country / Region (Dropdown)
                const Text(
                  "Country / Region",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: _isLoadingCountries
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButton<Country>(
                            value: _selectedCountry,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: _countries.map((country) {
                              return DropdownMenuItem<Country>(
                                value: country,
                                child: Row(
                                  children: [
                                    Text(
                                      country.flag,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(country.name),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCountry = value;
                              });
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 15),

                _buildTextField("State / Province",
                    controller: _stateController),
                _buildTextField("City", controller: _cityController),
                _buildTextField("Detailed Address",
                    controller: _addressController),
                _buildTextField("Post Code", controller: _postcodeController),

                const SizedBox(height: 25),
                Text(
                  "By continuing you agree that you are accessing this App and its service voluntarily, without any active promotion or solicitation by Come Come Pay",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          // Validate Name and Surname contain only uppercase English letters
                          if (!_validateEnglishUppercase(
                              _nameController.text, 'Name')) {
                            return;
                          }
                          if (!_validateEnglishUppercase(
                              _surnameController.text, 'Surname')) {
                            return;
                          }
                          // Get email from profile
                          final user = HiveStorageService.getUser();
                          final email = user?.email ?? '';

                          // Create request model from form data
                          final request = DiditInitializeTokenRequestModel(
                            address: _addressController.text,
                            agentUid:
                                '${_nameController.text}_${_surnameController.text}_${DateTime.now().millisecondsSinceEpoch}',
                            areaCode: (_selectedCountry?.dialCode ?? '+86')
                                .replaceAll('+', ''),
                            billCountryCode: _selectedCountry?.code ?? 'CN',
                            city: _cityController.text,
                            email: email,
                            firstEnName: _nameController.text.toUpperCase(),
                            lastEnName: _surnameController.text.toUpperCase(),
                            phone: _phoneNumberController.text,
                            postCode: _postcodeController.text,
                            returnUrl: 'https://yourapp.com/kyc/didit/callback',
                            state: _stateController.text,
                          );

                          final response =
                              await _viewModel.initializeDiditToken(request);

                          if (response != null &&
                              response.diditToken.data.url.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilkycDiditScreen(
                                  url: response.diditToken.data.url,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _viewModel.errorMessage ??
                                      'Failed to initialize KYC',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          height: 52,
                          alignment: Alignment.center,
                          child: Text(
                            AppLocalizations.of(context)!.continueButton,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameTextField(String label,
      {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            inputFormatters: [
              // Convert to uppercase automatically
              UpperCaseTextFormatter(),
              // Allow only English letters (A-Z)
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
            ],
            decoration: InputDecoration(
              hintText: 'Enter $label (uppercase English only)',
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  bool _validateEnglishUppercase(String value, String fieldName) {
    // Check if the value contains only uppercase English letters
    final regex = RegExp(r'^[A-Z]+$');
    if (!regex.hasMatch(value)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.invalidInput),
          content: Text(
            '$fieldName must contain only uppercase English letters (A-Z).\n\nCurrent value: $value',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.okButton),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }
}

// Custom formatter to convert input to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
