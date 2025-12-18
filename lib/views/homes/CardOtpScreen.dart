import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CardOtpScreen extends StatelessWidget {
  final TextEditingController otpController = TextEditingController();

  CardOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Mobile verification",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // WhatsApp Icon
            const Icon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 40),
            const SizedBox(height: 20),

            // Instruction text
            const Text(
              "Enter Whats App OTP we sent to\n+6289666666666666",
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 30),

            // OTP TextField
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                ),
              ),
              child: TextField(
                controller: otpController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: "Enter OTP",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Resend code
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Didn’t get a code? ", style: TextStyle(color: Colors.black54, fontSize: 13)),
                GestureDetector(
                  onTap: () {
                    // TODO: handle resend action
                  },
                  child: const Text(
                    "Send again",
                    style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: verify OTP
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text("Entered OTP: ${otpController.text}")),
                  // );
                  Navigator.pushNamed(context, '/CardCompliteScreen');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "Confirm",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
