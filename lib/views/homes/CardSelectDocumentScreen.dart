import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

import 'CardScanKtpScreen.dart';

class Cardselectdocumentscreen extends StatefulWidget {
  const Cardselectdocumentscreen({super.key});

  @override
  State<Cardselectdocumentscreen> createState() => _CardselectdocumentscreenState();
}


void onContinue(BuildContext context) async {
  try {
    // 1. Minta izin kamera
    var status = await Permission.camera.request();

    if (status.isGranted) {
      // 2. Ambil kamera yang tersedia
      final cameras = await availableCameras();

      if (!context.mounted) return; // safety kalau widget sudah dispose

      // 3. Navigate ke halaman scan KTP
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanKtpOverlayScreen(cameras: cameras),
        ),
      );
    } else if (status.isDenied) {
      // kalau user tolak sekali
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izin kamera diperlukan untuk melanjutkan")),
      );
    } else if (status.isPermanentlyDenied) {
      // kalau user blokir permission selamanya
      openAppSettings(); // buka setting aplikasi
    }
  } catch (e) {
    print("Error open camera: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kamera tidak tersedia")),
      );
    }
  }
}

class _CardselectdocumentscreenState extends State<Cardselectdocumentscreen> {
  String selectedCountry = "Indonesia";
  String selectedFlag = "assets/indonesia.png";

  final List<Map<String, String>> countries = [
    {"name": "Indonesia", "flag": "assets/indonesia.png"},
    {"name": "Malaysia", "flag": "assets/indonesia.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          "Verification",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title 1
            const Text(
              "Select country where your ID document was issued",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            /// Country Dropdown Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              onPressed: () {
                _showCountryPicker(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(selectedFlag, width: 24, height: 24),
                      const SizedBox(width: 8),
                      Text(
                        selectedCountry,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.black),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// Title 2
            const Text(
              "Select your document type",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            /// Document Buttons
            _buildGradientButton("Driver Licence", Icons.description, () {}),
            const SizedBox(height: 12),
            _buildGradientButton("ID card", Icons.credit_card, () {}),
            const SizedBox(height: 12),
            _buildGradientButton("Passport", Icons.book, () {}),

            const Spacer(),

            /// Continue Button
            _buildGradientButton(
              "Continue",
              null,
                  () => onContinue(context),
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Custom Gradient Button
  Widget _buildGradientButton(
      String text,
      IconData? icon,
      VoidCallback onPressed, {
        bool isFullWidth = true,
      }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment:
          isFullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show country picker
  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: countries.map((country) {
            return ListTile(
              leading: Image.asset(country["flag"]!, width: 28, height: 28),
              title: Text(country["name"]!),
              onTap: () {
                setState(() {
                  selectedCountry = country["name"]!;
                  selectedFlag = country["flag"]!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
