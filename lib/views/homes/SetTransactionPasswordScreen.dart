import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/set_transaction_password_viewmodel.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

class SetTransactionPasswordScreen extends StatelessWidget {
  const SetTransactionPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SetTransactionPasswordViewModel>(context);

    final TextEditingController _transactionPasswordController =
        TextEditingController();
    final TextEditingController _confirmPasswordController =
        TextEditingController();
    final TextEditingController _verificationCodeController =
        TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.setTransactionPassword),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<SetTransactionPasswordViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
              viewModel.clearError();
            });
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.setTransactionPasswordWarning,
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    title: AppLocalizations.of(context)!.transactionPassword,
                    hint: AppLocalizations.of(context)!
                        .pleaseEnterThe6DigitTransactionCode,
                    controller: _transactionPasswordController,
                    obscure: true,
                    readOnly: viewModel.isOtpRequested,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    title: AppLocalizations.of(context)!
                        .confirmTransactionPassword,
                    hint: AppLocalizations.of(context)!
                        .pleaseEnterTheConfirmationTransactionPassword,
                    controller: _confirmPasswordController,
                    obscure: true,
                    readOnly: viewModel.isOtpRequested,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    title: AppLocalizations.of(context)!.verificationMethod,
                    hint: AppLocalizations.of(context)!.emailVerification,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    title: AppLocalizations.of(context)!.verificationCode,
                    hint: AppLocalizations.of(context)!
                        .pleaseEnterVerificationCode,
                    controller: _verificationCodeController,
                    suffix: TextButton(
                      onPressed: () async {
                        final result =
                            await viewModel.requestTransactionPassword(
                          password: _transactionPasswordController.text,
                          confirmPassword: _confirmPasswordController.text,
                        );
                        if (result.success) {
                          // OTP sent, user can now enter code
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .otpSentToYourEmail),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Clear password fields on success
                          _transactionPasswordController.clear();
                          _confirmPasswordController.clear();
                        }
                        // Error handled by Consumer
                      },
                      child: Text(AppLocalizations.of(context)!.getCode),
                    ),
                  ),
                  const SizedBox(height: 80), // biar tidak ketutup tombol bawah
                ],
              ),
            ),
          );
        },
      ),

      // Confirm button di paling bawah
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final result = await viewModel.completeTransactionPassword(
                otpCode: _verificationCodeController.text,
              );
              if (result.success) {
                // Transaction password set successfully
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message ??
                        AppLocalizations.of(context)!
                            .transactionPasswordSetSuccessfully),
                    backgroundColor: Colors.green,
                  ),
                );
                // Navigate back or to next screen
                Navigator.of(context).pop();
              }
              // Error handled by Consumer
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.confirm,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String title,
    required String hint,
    TextEditingController? controller,
    bool obscure = false,
    Widget? suffix,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: suffix,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            keyboardType: obscure ? TextInputType.number : TextInputType.text,
          ),
        ),
      ],
    );
  }
}
