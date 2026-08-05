import 'package:comecomepay/views/homes/SendPdpDetailDone.dart'
    show SendPdpDetailDone;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/send_pdp_detail_otp_viewmodel.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/widgets/otp_input.dart';

class SendPdpDetailOtp extends StatelessWidget {
  const SendPdpDetailOtp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SendPdpDetailOtpViewModel(),
      child: const _SendPdpDetailOtpContent(),
    );
  }
}

class _SendPdpDetailOtpContent extends StatefulWidget {
  const _SendPdpDetailOtpContent();

  @override
  _SendPdpDetailOtpContentState createState() =>
      _SendPdpDetailOtpContentState();
}

class _SendPdpDetailOtpContentState extends State<_SendPdpDetailOtpContent> {
  void _onOtpCompleted(BuildContext context, String otp) async {
    final viewModel =
        Provider.of<SendPdpDetailOtpViewModel>(context, listen: false);
    if (otp.length == 5) {
      bool isVerified = await viewModel.verifyPin(otp,
          1); // Assuming id_user is 1, you can get it from storage or provider
      if (isVerified) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SendPdpDetailDone()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(viewModel.errorMessage ??
                  AppLocalizations.of(context)!.verificationFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final viewModel = Provider.of<SendPdpDetailOtpViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Text(AppLocalizations.of(context)!.otpSend,
            style: TextStyle(fontSize: 18 * textScaleFactor)),
        centerTitle: true,
        actions: viewModel.busy
            ? [
                Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.04),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              ]
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.02,
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenHeight * 0.02,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80.0 * textScaleFactor,
                color: Colors.blue,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                AppLocalizations.of(context)!.enterPasswordToConfirmTransaction,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16 * textScaleFactor, color: Colors.black),
              ),
              SizedBox(height: screenHeight * 0.04),
              OtpInput(
                length: 5,
                obscureText: false,
                onCompleted: (val) {
                  _onOtpCompleted(context, val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
