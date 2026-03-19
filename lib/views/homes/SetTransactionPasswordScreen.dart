import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/set_transaction_password_viewmodel.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/utils/app_colors.dart';

class SetTransactionPasswordScreen extends StatefulWidget {
  const SetTransactionPasswordScreen({super.key});

  @override
  State<SetTransactionPasswordScreen> createState() =>
      _SetTransactionPasswordScreenState();
}

class _SetTransactionPasswordScreenState
    extends State<SetTransactionPasswordScreen> {
  final TextEditingController _transactionPasswordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  @override
  void dispose() {
    _transactionPasswordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.setTransactionPassword),
        backgroundColor: AppColors.pageBackground,
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
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
                viewModel.clearError();
              }
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
                    style: const TextStyle(color: Colors.red, fontSize: 13),
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
                    value: AppLocalizations.of(context)!.emailVerification,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    title: AppLocalizations.of(context)!.verificationCode,
                    hint: AppLocalizations.of(context)!
                        .pleaseEnterVerificationCode,
                    controller: _verificationCodeController,
                    suffix: SizedBox(
                      width: 110,
                      child: GestureDetector(
                        onTap: viewModel.isOtpRequested
                            ? null
                            : () async {
                                final result =
                                    await viewModel.requestTransactionPassword(
                                  password: _transactionPasswordController.text,
                                  confirmPassword:
                                      _confirmPasswordController.text,
                                );
                                if (result.success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .otpSentToYourEmail),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              },
                        child: Center(
                          child: Text(
                            viewModel.isOtpRequested
                                ? '已发送'
                                : AppLocalizations.of(context)!.getCode,
                            style: TextStyle(
                              color: viewModel.isOtpRequested
                                  ? AppColors.textSecondary
                                  : AppColors.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<SetTransactionPasswordViewModel>(
          builder: (context, viewModel, child) {
            return SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  gradient: !viewModel.isOtpRequested
                      ? null
                      : AppColors.primaryGradient,
                  color:
                      !viewModel.isOtpRequested ? Colors.grey.shade300 : null,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: !viewModel.isOtpRequested
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: ElevatedButton(
                  onPressed: !viewModel.isOtpRequested
                      ? null
                      : () async {
                          final result =
                              await viewModel.completeTransactionPassword(
                            otpCode: _verificationCodeController.text,
                          );
                          if (result.success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message ??
                                    AppLocalizations.of(context)!
                                        .transactionPasswordSetSuccessfully),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.confirm,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
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
    String? value,
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: value != null
                      ? TextEditingController(text: value)
                      : controller,
                  obscureText: obscure,
                  readOnly: readOnly,
                  style: TextStyle(
                    color: readOnly && value != null ? Colors.black : null,
                    fontWeight:
                        readOnly && value != null ? FontWeight.w400 : null,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  keyboardType:
                      obscure ? TextInputType.number : TextInputType.text,
                ),
              ),
              if (suffix != null) suffix,
            ],
          ),
        ),
      ],
    );
  }
}
