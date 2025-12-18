import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/modify_password_viewmodel.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

class ModifyLoginPasswordScreen extends StatelessWidget {
  const ModifyLoginPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ModifyPasswordViewModel>(
      create: (_) => ModifyPasswordViewModel(),
      child: Consumer<ModifyPasswordViewModel>(
        builder: (context, viewModel, child) {
          final TextEditingController _oldPasswordController =
              TextEditingController();
          final TextEditingController _newPasswordController =
              TextEditingController();
          final TextEditingController _confirmPasswordController =
              TextEditingController();

          Widget _buildTextField({
            required String title,
            required String hint,
            TextEditingController? controller,
            bool obscure = false,
          }) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      hintText: hint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
              ],
            );
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.modifyLoginPassword),
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: Colors.black,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.modifyLoginPasswordWarning,
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      title: AppLocalizations.of(context)!.oldPassword,
                      hint: AppLocalizations.of(context)!
                          .pleaseEnterTheOldPassword,
                      controller: _oldPasswordController,
                      obscure: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      title: AppLocalizations.of(context)!.newPassword,
                      hint:
                          AppLocalizations.of(context)!.pleaseEnterANewPassword,
                      controller: _newPasswordController,
                      obscure: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      title: AppLocalizations.of(context)!.confirmNewPassword,
                      hint: AppLocalizations.of(context)!
                          .pleaseEnterToConfirmTheNewPassword,
                      controller: _confirmPasswordController,
                      obscure: true,
                    ),
                    if (viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          viewModel.errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Confirm button di paling bawah
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          final result = await viewModel.changePassword(
                            _oldPasswordController.text,
                            _newPasswordController.text,
                            _confirmPasswordController.text,
                          );
                          if (result.success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result.message!)),
                            );
                            _oldPasswordController.clear();
                            _newPasswordController.clear();
                            _confirmPasswordController.clear();
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result.message!)),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.confirm,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
