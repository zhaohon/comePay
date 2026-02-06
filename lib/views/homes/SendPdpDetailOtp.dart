import 'package:Demo/views/homes/SendPdpDetailDone.dart' show SendPdpDetailDone;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Demo/viewmodels/send_pdp_detail_otp_viewmodel.dart';
import 'package:Demo/l10n/app_localizations.dart';

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
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(5, (index) => TextEditingController());
    _focusNodes = List.generate(5, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onOtpCompleted(BuildContext context) async {
    final viewModel =
        Provider.of<SendPdpDetailOtpViewModel>(context, listen: false);
    String otp = _controllers.map((controller) => controller.text).join();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    width: 45.0 * textScaleFactor,
                    height: 45.0 * textScaleFactor,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: TextStyle(fontSize: 18 * textScaleFactor),
                      decoration: InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 4) {
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index + 1]);
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index - 1]);
                        }
                        // Aksi saat kotak terakhir diisi
                        if (index == 4 && value.isNotEmpty) {
                          _onOtpCompleted(context);
                        }
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
