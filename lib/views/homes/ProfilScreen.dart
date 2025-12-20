import 'package:comecomepay/views/homes/AboutUsScreen.dart';
import 'package:comecomepay/views/homes/InviteFriendScreen.dart';
import 'package:comecomepay/views/homes/MessageServiceCenterScreen.dart'
    show MessageServiceCenterScreen;
import 'package:comecomepay/views/homes/ProfilCouponScreen.dart'
    show Profilcouponscreen;
import 'package:comecomepay/views/homes/ProfilLanguageScreen.dart'
    show Profillanguagescreen;
import 'package:comecomepay/views/homes/SecurityScreen.dart'
    show Securityscreen;
import 'package:comecomepay/views/homes/UpdateProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/viewmodels/profile_screen_viewmodel.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

import 'ProfilKycScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? email;
  String? userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final viewModel =
        Provider.of<ProfileScreenViewModel>(context, listen: false);
    final accessToken = HiveStorageService.getAccessToken();
    if (accessToken != null) {
      final success = await viewModel.getProfile(accessToken);
      if (success) {
        setState(() {
          email = viewModel.profileResponse?.user.email;
          userId = viewModel.profileResponse?.user.id.toString();
        });
      } else {
        // Fallback to auth data if profile fetch fails
        final user = HiveStorageService.getUser();
        setState(() {
          email = user?.email;
          userId = user?.id.toString();
        });
      }
    } else {
      // Fallback to auth data if no access token
      final user = HiveStorageService.getUser();
      setState(() {
        email = user?.email;
        userId = user?.id.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdateProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: screenWidth * 0.1,
                      backgroundImage: const AssetImage("assets/profil.png"),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    email ?? AppLocalizations.of(context)!.noEmail,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'ID: ',
                              style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.black),
                            ),
                            TextSpan(
                              text:
                                  userId ?? AppLocalizations.of(context)!.noId,
                              style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: userId ?? ''));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .userIdCopied)),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.003),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check,
                            color: Colors.white, size: screenWidth * 0.03),
                        SizedBox(width: screenWidth * 0.01),
                        Text(AppLocalizations.of(context)!.identityVerified,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.03)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildProfileItem(
              context,
              icon: Icons.person_add,
              title: AppLocalizations.of(context)!.inviteFriend,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InviteFriendScreen()),
                );
              },
            ),
            _buildProfileItem(
              context,
              icon: Icons.camera_alt,
              title: AppLocalizations.of(context)!.kyc,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profilkycscreen()),
                );
              },
            ),
            _buildProfileItem(
              context,
              icon: Icons.language,
              title: AppLocalizations.of(context)!.language,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Profillanguagescreen()),
                );
              },
            ),
            _buildProfileItem(
              context,
              icon: Icons.card_giftcard,
              title: AppLocalizations.of(context)!.coupon,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profilcouponscreen()),
                );
              },
            ),
            _buildProfileItem(
              context,
              icon: Icons.headset_mic,
              title: AppLocalizations.of(context)!.customerServiceCenter,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MessageServiceCenterScreen()),
                );
              },
            ),
            _buildProfileItem(
              context,
              icon: Icons.info,
              title: AppLocalizations.of(context)!.aboutUs,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUsScreen()),
                );
              },
            ),
            _buildProfileItem(
              context,
              icon: Icons.security,
              title: AppLocalizations.of(context)!.security,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Securityscreen()),
                );
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE7ECFE),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
