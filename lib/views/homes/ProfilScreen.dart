import 'package:comecomepay/views/homes/AboutUsScreen.dart';
import 'package:comecomepay/views/homes/InviteFriendScreen.dart';
import 'package:comecomepay/views/homes/MessageServiceCenterScreen.dart' show MessageServiceCenterScreen;
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
    final viewModel = Provider.of<ProfileScreenViewModel>(context, listen: false);
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
            Card(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.white,
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Icon(Icons.person_add, color: Colors.blue),
                    ),
                    title: Text(AppLocalizations.of(context)!.inviteFriend),
                    trailing: Icon(Icons.play_arrow_sharp, color: Colors.blue),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InviteFriendScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.blue),
                    ),
                    title: Text(AppLocalizations.of(context)!.kyc),
                    trailing: Icon(Icons.play_arrow_sharp, color: Colors.blue),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profilkycscreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Icon(Icons.language, color: Colors.blue),
                    ),
                    title: Text(AppLocalizations.of(context)!.language),
                    trailing: Icon(Icons.play_arrow_sharp, color: Colors.blue),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profillanguagescreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.white,
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Icon(Icons.card_giftcard, color: Colors.blue),
                    ),
                    title: Text(AppLocalizations.of(context)!.coupon),
                    trailing: Icon(Icons.play_arrow_sharp, color: Colors.blue),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profilcouponscreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Icon(Icons.headset_mic, color: Colors.blue),
                    ),
                    title: Text(
                        AppLocalizations.of(context)!.customerServiceCenter),
                    trailing: Icon(Icons.play_arrow_sharp, color: Colors.blue),
                      onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MessageServiceCenterScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.white,
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Icon(Icons.info, color: Colors.blue),
                    ),
                    title: Text(AppLocalizations.of(context)!.aboutUs),
                    trailing: Icon(Icons.play_arrow_sharp, color: Colors.blue),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AboutUsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Icon(Icons.security, color: Colors.blue),
                    ),
                    title: Text(AppLocalizations.of(context)!.security),
                    trailing: Icon(Icons.play_arrow_sharp, color: Colors.blue),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Securityscreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
