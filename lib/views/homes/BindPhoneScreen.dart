import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/bind_phone_viewmodel.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

class BindPhoneScreen extends StatefulWidget {
  const BindPhoneScreen({super.key});

  @override
  State<BindPhoneScreen> createState() => _BindPhoneScreenState();
}

class _BindPhoneScreenState extends State<BindPhoneScreen> {
  late TextEditingController newPhoneController;
  late TextEditingController phoneOtpController;
  late TextEditingController emailOtpController;

  @override
  void initState() {
    super.initState();
    newPhoneController = TextEditingController();
    phoneOtpController = TextEditingController();
    emailOtpController = TextEditingController();
  }

  @override
  void dispose() {
    newPhoneController.dispose();
    phoneOtpController.dispose();
    emailOtpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BindPhoneViewModel>(
      create: (_) => BindPhoneViewModel(),
      child: Consumer<BindPhoneViewModel>(
        builder: (context, viewModel, child) {
          final size = MediaQuery.of(context).size;
          final width = size.width;
          final height = size.height;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.07, vertical: height * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title di bawah toolbar
                    Text(
                      AppLocalizations.of(context)!.bindPhone,
                      style: TextStyle(
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.01),

                    // Warning text
                    Text(
                      AppLocalizations.of(context)!.bindPhoneWarning,
                      style: TextStyle(
                        fontSize: width * 0.035,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: height * 0.03),

                    // New Phone
                    Text(AppLocalizations.of(context)!.newPhone,
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: height * 0.01),
                    TextField(
                      controller: newPhoneController,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text("+62",
                              style: TextStyle(fontSize: width * 0.04)),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText:
                            AppLocalizations.of(context)!.pleaseEnterYourNumber,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: height * 0.03),

                    // Phone Verification Code
                    Text(AppLocalizations.of(context)!.phoneVerificationCode,
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: height * 0.01),
                    TextField(
                      controller: phoneOtpController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: AppLocalizations.of(context)!
                            .pleaseEnterVerificationCode,
                        suffixIcon: TextButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () async {
                                  final result =
                                      await viewModel.requestChangePhone(
                                          newPhoneController.text);
                                  if (result.success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(result.message ??
                                              AppLocalizations.of(context)!
                                                  .otpSentToYourPhone)),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(result.message ??
                                              AppLocalizations.of(context)!
                                                  .errorOccurred)),
                                    );
                                  }
                                },
                          child: Text(
                            viewModel.isLoading
                                ? AppLocalizations.of(context)!.sending
                                : AppLocalizations.of(context)!.getCode,
                            style: TextStyle(
                                fontSize: width * 0.035, color: Colors.blue),
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: height * 0.03),

                    // Verification Method
                    Text(AppLocalizations.of(context)!.verificationMethod,
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: height * 0.01),
                    TextFormField(
                      initialValue:
                          AppLocalizations.of(context)!.emailVerification,
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(height: height * 0.03),

                    // Email Verification Code
                    TextField(
                      controller: emailOtpController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: AppLocalizations.of(context)!
                            .pleaseEnterVerificationCode,
                        suffixIcon: TextButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () async {
                                  final email =
                                      HiveStorageService.getUser()?.email;
                                  if (email == null || email.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(AppLocalizations.of(
                                                  context)!
                                              .emailNotFoundPleaseLoginAgain)),
                                    );
                                    return;
                                  }
                                  final result =
                                      await viewModel.verifyNewPhoneOtp(
                                          email,
                                          newPhoneController.text,
                                          phoneOtpController.text);
                                  if (result.success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(result.message ??
                                              AppLocalizations.of(context)!
                                                  .emailOtpSentSuccessfully)),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(result.message ??
                                              AppLocalizations.of(context)!
                                                  .errorOccurred)),
                                    );
                                  }
                                },
                          child: Text(
                            viewModel.isLoading
                                ? AppLocalizations.of(context)!.sending
                                : AppLocalizations.of(context)!.getCode,
                            style: TextStyle(
                                fontSize: width * 0.035, color: Colors.blue),
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: height * 0.05),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                final result =
                                    await viewModel.completeChangePhone(
                                        newPhoneController.text,
                                        emailOtpController.text);
                                if (result.success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(result.message ??
                                            AppLocalizations.of(context)!
                                                .phoneNumberChangedSuccessfully)),
                                  );
                                  // Navigate back or to profile screen
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(result.message ??
                                            AppLocalizations.of(context)!
                                                .errorOccurred)),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding:
                              EdgeInsets.symmetric(vertical: height * 0.02),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(
                          viewModel.isLoading
                              ? AppLocalizations.of(context)!.confirming
                              : AppLocalizations.of(context)!.confirm,
                          style: TextStyle(
                            fontSize: width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
