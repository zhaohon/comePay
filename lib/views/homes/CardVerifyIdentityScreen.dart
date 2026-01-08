import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

class CardVerifyIdentityScreen extends StatelessWidget {
  const CardVerifyIdentityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '9:41',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Verify your identity',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'It will take only 2 minutes',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // Tombol Identity document
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20), // margin kanan kiri
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(
                    double.infinity, 50), // lebar penuh di dalam padding
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Icon(Icons.description, color: Colors.white),
                  ),
                  const Center(
                    child: Text(
                      'Identity document',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tombol Selfie
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20), // margin kanan kiri
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(
                    double.infinity, 50), // lebar penuh di dalam padding
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  const Center(
                    child: Text(
                      'Selfie',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Tombol Continue di bawah
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Cardselectdocumentscreen');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(AppLocalizations.of(context)!.continueButton),
            ),
          ),
        ],
      ),
    );
  }
}
