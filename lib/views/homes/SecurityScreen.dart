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
import 'package:comecomepay/utils/app_colors.dart';

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

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizations.security,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildCardItem(
                          context,
                          icon: Icons.email,
                          iconColor: const Color(0xFF2196F3),
                          title: localizations.email,
                          value: _maskEmail(_profileData?.user.email ?? ""),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ModifyEmailScreen()),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildCardItem(
                          context,
                          icon: Icons.phone,
                          iconColor: const Color(0xFF4CAF50),
                          title: localizations.phone,
                          value:
                              _profileData?.user.phone ?? localizations.unbound,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BindPhoneScreen()),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildCardItem(
                          context,
                          icon: Icons.lock,
                          iconColor: const Color(0xFFFF9800),
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
                        _buildDivider(),
                        _buildCardItem(
                          context,
                          icon: Icons.password,
                          iconColor: AppColors.primary,
                          title: localizations.loginPassword,
                          value: localizations.update,
                          onTap: () {
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
                ),
              ),

              const SizedBox(height: 20),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => null,
                    ),
                  ),
                  onPressed: () async {
                    await _handleLogout(context);
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        localizations.logout,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
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

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 68),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Colors.grey.shade200,
      ),
    );
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return "Not set";
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 3) {
      return '$username@$domain';
    }

    final visibleStart = username.substring(0, 2);
    final visibleEnd = username.substring(username.length - 1);
    return '$visibleStart....$visibleEnd@$domain';
  }

  Widget _buildCardItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.logout),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              localizations.logout,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Clear all data from Hive storage (auth and profile)
      await HiveStorageService.clearAllData();

      // Navigate to LoginScreen after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
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
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
