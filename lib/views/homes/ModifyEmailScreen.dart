import 'package:flutter/material.dart';
import 'package:comecomepay/viewmodels/modify_email_viewmodel.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

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
            backgroundColor: Colors.white,

            appBar: AppBar(
              backgroundColor: Colors.white,
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
                  TextField(
                    controller: _newEmailController,
                    onChanged: (value) => viewModel.validateEmail(value),
                    decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context)!.pleaseEnterYourEmail,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorText:
                          viewModel.errorMessage?.contains('email') == true
                              ? viewModel.errorMessage
                              : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Email verification code + Get Code
                  Text(AppLocalizations.of(context)!.emailVerificationCode),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailOtpController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!
                          .pleaseEnterVerificationCode,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: TextButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                final result =
                                    await viewModel.requestChangeEmail(
                                        _newEmailController.text.trim());
                                if (result.success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(result.message ??
                                            AppLocalizations.of(context)!
                                                .otpSentToNewEmail)),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(result.message ??
                                            AppLocalizations.of(context)!
                                                .failedToSendOtp)),
                                  );
                                }
                              },
                        child: Text(
                          viewModel.isLoading
                              ? AppLocalizations.of(context)!.sending
                              : AppLocalizations.of(context)!.getCode,
                          style: TextStyle(
                              color: viewModel.isLoading
                                  ? Colors.grey
                                  : Colors.green),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Verification method
                  Text(AppLocalizations.of(context)!.verificationMethod),
                  const SizedBox(height: 8),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.emailVerification,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Verification code + Get Code
                  Text(AppLocalizations.of(context)!.enterVerificationCode),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _verificationCodeController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!
                          .pleaseEnterVerificationCode,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: TextButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                final otpCode = _emailOtpController.text.trim();
                                if (otpCode.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(result.message ??
                                            AppLocalizations.of(context)!
                                                .newEmailVerifiedOtpSentToCurrent)),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(result.message ??
                                            AppLocalizations.of(context)!
                                                .failedToVerifyNewEmail)),
                                  );
                                }
                              },
                        child: Text(
                          viewModel.isLoading
                              ? AppLocalizations.of(context)!.verifying
                              : AppLocalizations.of(context)!.getCode,
                          style: TextStyle(
                              color: viewModel.isLoading
                                  ? Colors.grey
                                  : Colors.green),
                        ),
                      ),
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
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            final verificationCode =
                                _verificationCodeController.text.trim();
                            if (verificationCode.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .enterVerificationCode)),
                              );
                              return;
                            }
                            final result = await viewModel.completeChangeEmail(
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
                              // Navigate back or to success screen
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.confirm,
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
