import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/profile_screen_viewmodel.dart';
import 'package:comecomepay/models/requests/update_profile_request_model.dart';
import 'package:comecomepay/services/hive_storage_service.dart';

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
      final viewModel = Provider.of<ProfileScreenViewModel>(context, listen: false);
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
        if (viewModel.profileResponse != null && _firstNameController.text.isEmpty) {
          _loadProfileData(viewModel);
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Update Profile',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // First Name
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Last Name
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Date of Birth
                TextField(
                  controller: _dateOfBirthController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 16),

                // Account Type
                TextField(
                  controller: _accountTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Account Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Referral Code
                TextField(
                  controller: _referralCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Referral Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: viewModel.busy ? null : () async {
                      final request = UpdateProfileRequestModel(
                        firstName: _firstNameController.text,
                        lastName: _lastNameController.text,
                        phone: _phoneController.text,
                        dateOfBirth: _dateOfBirthController.text,
                        accountType: _accountTypeController.text,
                        referralCode: _referralCodeController.text,
                      );

                      final success = await viewModel.updateProfile(request);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated successfully')),
                        );
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(viewModel.errorMessage ?? 'Failed to update profile')),
                        );
                      }
                    },
                    child: viewModel.busy
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
}
