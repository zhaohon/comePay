import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CardKycScreen extends StatefulWidget {
  const CardKycScreen({super.key});

  @override
  State<CardKycScreen> createState() => _CardKycScreenState();
}

class _CardKycScreenState extends State<CardKycScreen> {
  String? selectedCountry = "Indonesia";
  final TextEditingController phoneController = TextEditingController();

  final List<Map<String, String>> countries = [
    {"name": "Indonesia", "flag": "assets/indonesia.png", "code": "+62"},
    {"name": "Malaysia", "flag": "assets/indonesia.png", "code": "+60"},
  ];

  void _showVerificationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Send verification via",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // WhatsApp option
              ListTile(
                leading: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
                title: const Text("WhatsApp"),
                onTap: () {
                  Navigator.pushNamed(context, '/CardOtpScreen');
                },
              ),
              const Divider(),

              // SMS option
              ListTile(
                leading: const Icon(Icons.sms, color: Colors.blue),
                title: const Text("SMS"),
                onTap: () {
                  Navigator.pushNamed(context, '/CardOtpScreen');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final country = countries.firstWhere(
          (c) => c["name"] == selectedCountry,
      orElse: () => countries.first,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "KYC",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              "Verify your identity",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 8),

            const Text(
              "Verify your identity to open your Come Come Pay card account and keep it secure and compliant",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // Checklist
            const Row(
              children: [
                Icon(Icons.check, color: Colors.green, size: 20),
                SizedBox(width: 6),
                Text("Get your identity document ready",
                    style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.check, color: Colors.green, size: 20),
                SizedBox(width: 6),
                Text("Must be 18 or older", style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 28),

            // Country dropdown
            const Text(
              "COUNTRY OF RESIDENCY",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: Colors.blue[800],
                  iconEnabledColor: Colors.white,
                  value: selectedCountry,
                  items: countries.map((c) {
                    return DropdownMenuItem(
                      value: c["name"],
                      child: Row(
                        children: [
                          Image.asset(c["flag"]!, width: 24),
                          const SizedBox(width: 8),
                          Text(
                            c["name"]!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCountry = value;
                    });
                  },
                  isExpanded: true,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Phone number
            const Text(
              "MOBILE NUMBER",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(
                    country["code"]!,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "08XXXXXXXXXX",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Disclaimer
            const Text(
              "By continuing you agree that you are accessing this App and its services voluntarily, without any active promotion or solicitation by Come Come Pay",
              style: TextStyle(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 30),

            // Start button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  _showVerificationBottomSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
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
                      "Start",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
