import 'package:flutter/material.dart';
import 'package:comecomepay/viewmodels/profile_screen_viewmodel.dart';
import 'package:comecomepay/views/homes/ProfilKycDiditScreen.dart';
import 'package:comecomepay/models/requests/didit_initialize_token_request_model.dart';
import 'package:comecomepay/services/hive_storage_service.dart';

class Cardverificationscreen extends StatefulWidget {
  const Cardverificationscreen({Key? key}) : super(key: key);

  @override
  State<Cardverificationscreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<Cardverificationscreen> {
  late ProfileScreenViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();

  // Negara dan kode
  String _selectedCountry = "China";
  String _selectedFlag = 'assets/vn.png';
  String _selectedCode = '+86';

  final List<Map<String, String>> _countries = [
    {'name': 'China', 'code': '+86', 'flag': 'assets/vn.png'},
    {'name': 'Vietnam', 'code': '+84', 'flag': 'assets/vn.png'},
    {'name': 'Indonesia', 'code': '+62', 'flag': 'assets/indonesia.png'},
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileScreenViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Verification",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                _buildTextField("Name", controller: _nameController),
                _buildTextField("Surname", controller: _surnameController),
                const SizedBox(height: 10),

                // Mobile Phone
                const Text(
                  "Mobile Phone",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Image.asset(_selectedFlag, width: 24, height: 24),
                      const SizedBox(width: 8),
                      Text(
                        _selectedCode,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      const VerticalDivider(color: Colors.grey, thickness: 1),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter mobile number',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Country / Region (Dropdown)
                const Text(
                  "Country / Region",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCountry,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: _countries.map((country) {
                        return DropdownMenuItem<String>(
                          value: country['name'],
                          child: Row(
                            children: [
                              Image.asset(country['flag']!,
                                  width: 24, height: 24),
                              const SizedBox(width: 10),
                              Text(country['name']!),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          final selected = _countries.firstWhere(
                              (c) => c['name'] == value,
                              orElse: () => _countries[0]);
                          _selectedCountry = selected['name']!;
                          _selectedFlag = selected['flag']!;
                          _selectedCode = selected['code']!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                _buildTextField("State / Province", controller: _stateController),
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
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Get email from profile
                        final user = HiveStorageService.getUser();
                        final email = user?.email ?? '';

                        // Create request model from form data
                        final request = DiditInitializeTokenRequestModel(
                          address: _addressController.text,
                          agentUid: '${_nameController.text}_${_surnameController.text}_${DateTime.now().millisecondsSinceEpoch}',
                          areaCode: _selectedCode.replaceAll('+', ''),
                          billCountryCode: _selectedCountry == 'China' ? 'CN' : _selectedCountry == 'Vietnam' ? 'VN' : 'ID',
                          city: _cityController.text,
                          email: email,
                          firstEnName: _nameController.text.toUpperCase(),
                          lastEnName: _surnameController.text.toUpperCase(),
                          phone: _phoneNumberController.text,
                          postCode: _postcodeController.text,
                          returnUrl: 'https://yourapp.com/kyc/didit/callback',
                          state: _stateController.text,
                        );

                        final response = await _viewModel.initializeDiditToken(request);

                        if (response != null && response.diditToken.data.url.isNotEmpty) {
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
                                _viewModel.errorMessage ?? 'Failed to initialize KYC',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      "Continue",
                      style:
                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
}
