import 'dart:async';
import 'package:flutter/material.dart';
import 'package:comecomepay/viewmodels/modify_email_viewmodel.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/utils/app_colors.dart';

class ModifyEmailScreen extends StatefulWidget {
  const ModifyEmailScreen({super.key});

  @override
  State<ModifyEmailScreen> createState() => _ModifyEmailScreenState();
}

class _ModifyEmailScreenState extends State<ModifyEmailScreen> {
  late ModifyEmailViewModel _viewModel;
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _emailOtpController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  // 🛡️ Independent state management for buttons
  int _newEmailCountdown = 0;
  int _oldEmailCountdown = 0;
  bool _isSendingNewEmailCode = false;
  bool _isSendingOldEmailCode = false;
  bool _isSubmitting = false;
  Timer? _newEmailTimer;
  Timer? _oldEmailTimer;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ModifyEmailViewModel>();
  }

  @override
  void dispose() {
    _newEmailTimer?.cancel();
    _oldEmailTimer?.cancel();
    _newEmailController.dispose();
    _emailOtpController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _startNewEmailTimer() {
    _newEmailTimer?.cancel();
    setState(() {
      _newEmailCountdown = 60;
    });
    _newEmailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_newEmailCountdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _newEmailCountdown--;
        });
      }
    });
  }

  void _startOldEmailTimer() {
    _oldEmailTimer?.cancel();
    setState(() {
      _oldEmailCountdown = 60;
    });
    _oldEmailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_oldEmailCountdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _oldEmailCountdown--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ModifyEmailViewModel>(
        builder: (context, viewModel, child) {
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
                AppLocalizations.of(context)!.modifyEmail,
                style: const TextStyle(color: Colors.black),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Warning text
                  Text(
                    AppLocalizations.of(context)!.modifyEmailWarning,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// New Email
                  Text(AppLocalizations.of(context)!.newEmail),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      controller: _newEmailController,
                      onChanged: (value) => viewModel.validateEmail(value),
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.pleaseEnterYourEmail,
                        hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        errorText:
                            viewModel.errorMessage?.contains('email') == true
                                ? viewModel.errorMessage
                                : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// New Email OTP Button
                  Text(AppLocalizations.of(context)!.emailVerificationCode),
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
                            controller: _emailOtpController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!
                                  .pleaseEnterVerificationCode,
                              hintStyle:
                                  const TextStyle(color: Color(0xFFD1D5DB)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          child: GestureDetector(
                            onTap: (_isSendingNewEmailCode || _newEmailCountdown > 0)
                                ? null
                                : () async {
                                    setState(() {
                                      _isSendingNewEmailCode = true;
                                    });
                                    try {
                                      final result =
                                          await viewModel.requestChangeEmail(
                                              _newEmailController.text.trim(),
                                              AppLocalizations.of(context)!);
                                      if (result.success) {
                                        _startNewEmailTimer();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(result.message ??
                                                    AppLocalizations.of(context)!
                                                        .otpSentToNewEmail)),
                                          );
                                        }
                                      } else {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(result.message ??
                                                    AppLocalizations.of(context)!
                                                        .failedToSendOtp)),
                                          );
                                        }
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _isSendingNewEmailCode = false;
                                        });
                                      }
                                    }
                                  },
                            child: Center(
                              child: _isSendingNewEmailCode
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : Text(
                                      _newEmailCountdown > 0
                                          ? "$_newEmailCountdown 秒"
                                          : AppLocalizations.of(context)!.getCode,
                                      style: TextStyle(
                                        color: _newEmailCountdown > 0
                                            ? AppColors.textSecondary
                                            : AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Verification Method Section
                  Text(AppLocalizations.of(context)!.verificationMethod),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.emailVerification,
                        hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Old Email (Current) OTP Button
                  Text(AppLocalizations.of(context)!.enterVerificationCode),
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
                            controller: _verificationCodeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!
                                  .pleaseEnterVerificationCode,
                              hintStyle:
                                  const TextStyle(color: Color(0xFFD1D5DB)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          child: GestureDetector(
                            onTap: (_isSendingOldEmailCode || _oldEmailCountdown > 0)
                                ? null
                                : () async {
                                    final otpCode =
                                        _emailOtpController.text.trim();
                                    if (otpCode.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(AppLocalizations.of(
                                                    context)!
                                                .enterEmailVerificationCodeFirst)),
                                      );
                                      return;
                                    }
                                    
                                    setState(() {
                                      _isSendingOldEmailCode = true;
                                    });
                                    
                                    try {
                                      final result =
                                          await viewModel.verifyNewEmailOtp(
                                              _newEmailController.text.trim(),
                                              otpCode,
                                              AppLocalizations.of(context)!);
                                      if (result.success) {
                                        _startOldEmailTimer();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(result.message ??
                                                    AppLocalizations.of(context)!
                                                        .newEmailVerifiedOtpSentToCurrent)),
                                          );
                                        }
                                      } else {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(result.message ??
                                                    AppLocalizations.of(context)!
                                                        .failedToVerifyNewEmail)),
                                          );
                                        }
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _isSendingOldEmailCode = false;
                                        });
                                      }
                                    }
                                  },
                            child: Center(
                              child: _isSendingOldEmailCode
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : Text(
                                      _oldEmailCountdown > 0
                                          ? "$_oldEmailCountdown 秒"
                                          : AppLocalizations.of(context)!.getCode,
                                      style: TextStyle(
                                        color: _oldEmailCountdown > 0
                                            ? AppColors.textSecondary
                                            : AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// Confirm button at bottom
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _isSubmitting
                          ? null
                          : AppColors.primaryGradient,
                      color: _isSubmitting ? Colors.grey.shade300 : null,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: _isSubmitting
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
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              final verificationCode =
                                  _verificationCodeController.text.trim();
                              if (verificationCode.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .enterVerificationCode)),
                                );
                                return;
                              }
                              
                              setState(() {
                                _isSubmitting = true;
                              });

                              try {
                                final result =
                                    await viewModel.completeChangeEmail(
                                  _newEmailController.text.trim(),
                                  verificationCode,
                                  AppLocalizations.of(context)!,
                                );
                                if (result.success) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(result.message ??
                                              AppLocalizations.of(context)!
                                                  .emailChangedSuccessfully)),
                                    );
                                    Navigator.pop(context);
                                  }
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(result.message ??
                                              AppLocalizations.of(context)!
                                                  .failedToChangeEmail)),
                                    );
                                  }
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isSubmitting = false;
                                  });
                                }
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
              ),
            ),
          );
        },
      ),
    );
  }
}
