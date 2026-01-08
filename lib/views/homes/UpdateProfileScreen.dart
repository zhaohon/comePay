import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/profile_screen_viewmodel.dart';
import 'package:comecomepay/models/requests/update_profile_request_model.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _accountTypeController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel =
          Provider.of<ProfileScreenViewModel>(context, listen: false);
      if (viewModel.profileResponse != null) {
        _loadProfileData(viewModel);
      } else {
        // Load profile if not loaded
        final accessToken = HiveStorageService.getAccessToken();
        if (accessToken != null) {
          viewModel.getProfile(accessToken);
        }
      }
    });
  }

  void _loadProfileData(ProfileScreenViewModel viewModel) {
    final user = viewModel.profileResponse!.user;
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _phoneController.text = user.phone ?? '';
    _dateOfBirthController.text = user.dateOfBirth ?? '';
    _accountTypeController.text = user.accountType;
    _referralCodeController.text = user.referralCode;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _accountTypeController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileScreenViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.profileResponse != null &&
            _firstNameController.text.isEmpty) {
          _loadProfileData(viewModel);
        }

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.updateProfile,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.pageBackground,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 个人信息卡片
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First Name
                      _buildInputField(
                        controller: _firstNameController,
                        label: AppLocalizations.of(context)!.firstName,
                      ),
                      const SizedBox(height: 16),

                      // Last Name
                      _buildInputField(
                        controller: _lastNameController,
                        label: AppLocalizations.of(context)!.lastName,
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      _buildInputField(
                        controller: _phoneController,
                        label: AppLocalizations.of(context)!.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Date of Birth
                      _buildInputField(
                        controller: _dateOfBirthController,
                        label: AppLocalizations.of(context)!.dateOfBirth,
                        keyboardType: TextInputType.datetime,
                      ),
                      const SizedBox(height: 16),

                      // Account Type
                      _buildInputField(
                        controller: _accountTypeController,
                        label: AppLocalizations.of(context)!.accountType,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),

                      // Referral Code
                      _buildInputField(
                        controller: _referralCodeController,
                        label: AppLocalizations.of(context)!.referralCode,
                        enabled: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ).copyWith(
                      backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => null,
                      ),
                    ),
                    onPressed: viewModel.busy
                        ? null
                        : () async {
                            final request = UpdateProfileRequestModel(
                              firstName: _firstNameController.text,
                              lastName: _lastNameController.text,
                              phone: _phoneController.text,
                              dateOfBirth: _dateOfBirthController.text,
                              accountType: _accountTypeController.text,
                              referralCode: _referralCodeController.text,
                            );

                            final success =
                                await viewModel.updateProfile(request);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .profileUpdatedSuccessfully)),
                              );
                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(viewModel.errorMessage ??
                                        AppLocalizations.of(context)!
                                            .failedToUpdateProfile)),
                              );
                            }
                          },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient:
                            viewModel.busy ? null : AppColors.primaryGradient,
                        color: viewModel.busy ? Colors.grey.shade300 : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: viewModel.busy
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.grey,
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)!.save,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
        filled: true,
        fillColor: enabled ? AppColors.pageBackground : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
