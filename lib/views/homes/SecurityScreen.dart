import 'package:comecomepay/views/homes/BindPhoneScreen.dart'
    show BindPhoneScreen;
import 'package:comecomepay/views/homes/ModifyEmailScreen.dart';
import 'package:comecomepay/views/homes/ModifyLoginPasswordScreen.dart'
    show ModifyLoginPasswordScreen;
import 'package:comecomepay/views/homes/SetTransactionPasswordScreen.dart';
import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/models/responses/get_profile_response_model.dart';

class Securityscreen extends StatefulWidget {
  const Securityscreen({super.key});

  @override
  _SecurityscreenState createState() => _SecurityscreenState();
}

class _SecurityscreenState extends State<Securityscreen> {
  GetProfileResponseModel? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final profile = await HiveStorageService.getProfileData();
    setState(() {
      _profileData = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // Responsive scaling factor
    double scale(double value) => value * (width / 390);

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
          localizations.security,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(scale(16)),
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Card Section with white bg + shadow
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(scale(8)),
                          side: const BorderSide(
                            color: Colors.black12,
                            width: 0.3,
                          ),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black26,
                        margin: EdgeInsets.symmetric(
                          vertical: scale(10),
                          horizontal: scale(8),
                        ),
                        child: Column(
                          children: [
                            _buildCardItem(
                              context,
                              icon: Icons.email,
                              title: localizations.email,
                              value: _profileData?.user.email ??
                                  "kas.........@gmail.com",
                              onTap: () {
                                // Navigate to ModifyEmailScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ModifyEmailScreen()),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            _buildCardItem(
                              context,
                              icon: Icons.phone,
                              title: localizations.phone,
                              value: _profileData?.user.phone ??
                                  localizations.unbound,
                              onTap: () {
                                // Navigate to BindPhoneScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BindPhoneScreen()),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            _buildCardItem(
                              context,
                              icon: Icons.lock,
                              title: localizations.transactionPassword,
                              value: localizations.set,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SetTransactionPasswordScreen()),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            _buildCardItem(
                              context,
                              icon: Icons.password,
                              title: localizations.loginPassword,
                              value: localizations.update,
                              onTap: () {
                                // Navigate to ModifyLoginPasswordScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ModifyLoginPasswordScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Spacer jarak
              SizedBox(height: scale(20)),

              // Logout Button - gradient biru
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(scale(8)),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(scale(8)),
                    onTap: () async {
                      await _handleLogout(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: scale(16)),
                      child: Center(
                        child: Text(
                          localizations.logout,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: scale(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final width = MediaQuery.of(context).size.width;
    double scale(double value) => value * (width / 390);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: scale(12),
          vertical: scale(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: scale(22)),
            SizedBox(width: scale(12)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: scale(14),
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: scale(13),
              ),
            ),
            SizedBox(width: scale(12)),
            Icon(Icons.chevron_right, color: Colors.black, size: scale(20)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      // Clear all data from Hive storage (auth and profile)
      await HiveStorageService.clearAllData();

      // Navigate to LoginScreen after a short delay to show the notification
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login_screen',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Show error notification if logout fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.logoutFailed}: ${e.toString()}'),
            backgroundColor: Color(0xFF34495E),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
