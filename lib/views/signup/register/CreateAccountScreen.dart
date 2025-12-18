import 'package:comecomepay/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
              ),
            ),
          ),

          // Icon pojok kanan atas
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top - 20,
            right: 30,
            child: GestureDetector(
              onTap: () {
                print("Icon kanan atas ditekan");
              },
              child: Image.asset(
                "assets/which.png",
                width: 45,
                height: 45,
              ),
            ),
          ),

          // Konten utama scrollable
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(
                    height: kToolbarHeight +
                        MediaQuery.of(context).padding.top +
                        80),

                // Ilustrasi cloud
                Image.asset(
                  "assets/cloudillustration.png",
                  height: 220,
                ),

                const SizedBox(height: 100), // biar konten tidak menabrak bawah
              ],
            ),
          ),

          // Terms & Conditions + Register di bawah layar
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Checkbox + Terms
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() => _agreeToTerms = value ?? false);
                      },
                      activeColor: Colors.blue,
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _agreeToTerms = !_agreeToTerms;
                      }),
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          children: [
                            TextSpan(text: AppLocalizations.of(context)!.iAgreeWith),
                            TextSpan(
                              text: AppLocalizations.of(context)!.termsAndConditions,
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tombol Register
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _agreeToTerms
                        ? () => Navigator.pushNamed(
                            context, '/create_account_email')
                        : null,
                    child: Text(
                      AppLocalizations.of(context)!.register,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
