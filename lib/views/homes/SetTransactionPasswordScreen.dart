import 'dart:async';
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

  // 🛡️ Independent state management for buttons
  int _countdown = 0;
  bool _isSendingCode = false;
  bool _isSubmitting = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _transactionPasswordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _countdown = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SetTransactionPasswordViewModel>(
        builder: (context, viewModel, child) {
          // 💡 Removed global viewModel.isLoading check to prevent full screen spinner.
          
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
                        onTap: (_isSendingCode || _countdown > 0)
                            ? null
                            : () async {
                                setState(() {
                                  _isSendingCode = true;
                                });
                                try {
                                  final result =
                                      await viewModel.requestTransactionPassword(
                                    l10n: AppLocalizations.of(context)!,
                                    password: _transactionPasswordController.text,
                                    confirmPassword:
                                        _confirmPasswordController.text,
                                  );
                                  if (result.success) {
                                    _startTimer();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .otpSentToYourEmail),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isSendingCode = false;
                                    });
                                  }
                                }
                              },
                        child: Center(
                          child: _isSendingCode
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Text(
                                  _countdown > 0
                                      ? "$_countdown 秒"
                                      : (viewModel.isOtpRequested
                                          ? AppLocalizations.of(context)!
                                              .resendCode
                                          : AppLocalizations.of(context)!
                                              .getCode),
                                  style: TextStyle(
                                    color: _countdown > 0
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
      bottomNavigationBar: Consumer<SetTransactionPasswordViewModel>(
        builder: (context, viewModel, child) {
          final isButtonEnabled = viewModel.isOtpRequested && !_isSubmitting;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  gradient: isButtonEnabled
                      ? AppColors.primaryGradient
                      : null,
                  color: isButtonEnabled ? null : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: isButtonEnabled
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () async {
                          setState(() {
                            _isSubmitting = true;
                          });
                          try {
                            final result =
                                await viewModel.completeTransactionPassword(
                              l10n: AppLocalizations.of(context)!,
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
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSubmitting = false;
                              });
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.confirm,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          );
        },
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
