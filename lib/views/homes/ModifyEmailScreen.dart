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

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ModifyEmailViewModel>();
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _emailOtpController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
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
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: true,
            ),

            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Warning text merah
                  Text(
                    AppLocalizations.of(context)!.modifyEmailWarning,
                    style: TextStyle(
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

                  /// Email verification code + Get Code
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
                            onTap: viewModel.isLoading
                                ? null
                                : () async {
                                    final result =
                                        await viewModel.requestChangeEmail(
                                            _newEmailController.text.trim());
                                    if (result.success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(result.message ??
                                                AppLocalizations.of(context)!
                                                    .otpSentToNewEmail)),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(result.message ??
                                                AppLocalizations.of(context)!
                                                    .failedToSendOtp)),
                                      );
                                    }
                                  },
                            child: Center(
                              child: viewModel.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!.getCode,
                                      style: const TextStyle(
                                        color: AppColors.primary,
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

                  /// Verification method
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

                  /// Verification code + Get Code
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
                            onTap: viewModel.isLoading
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
                                    final result =
                                        await viewModel.verifyNewEmailOtp(
                                            _newEmailController.text.trim(),
                                            otpCode);
                                    if (result.success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(result.message ??
                                                AppLocalizations.of(context)!
                                                    .newEmailVerifiedOtpSentToCurrent)),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(result.message ??
                                                AppLocalizations.of(context)!
                                                    .failedToVerifyNewEmail)),
                                      );
                                    }
                                  },
                            child: Center(
                              child: viewModel.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!.getCode,
                                      style: const TextStyle(
                                        color: AppColors.primary,
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

            /// Confirm button di paling bawah
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: viewModel.isLoading
                          ? null
                          : AppColors.primaryGradient,
                      color: viewModel.isLoading ? Colors.grey.shade300 : null,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: viewModel.isLoading
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
                      onPressed: viewModel.isLoading
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
                              final result =
                                  await viewModel.completeChangeEmail(
                                _newEmailController.text.trim(),
                                verificationCode,
                              );
                              if (result.success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(result.message ??
                                          AppLocalizations.of(context)!
                                              .emailChangedSuccessfully)),
                                );
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(result.message ??
                                          AppLocalizations.of(context)!
                                              .failedToChangeEmail)),
                                );
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
                      child: viewModel.isLoading
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
