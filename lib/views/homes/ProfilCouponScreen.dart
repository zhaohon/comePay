import 'package:comecomepay/views/homes/CouponCodeScreen.dart'
    show CouponCodeScreen;
import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'AvailableCouponTab.dart';
import 'UsedCouponTab.dart';
import 'ExpiredCouponTab.dart';

class Profilcouponscreen extends StatefulWidget {
  const Profilcouponscreen({super.key});

  @override
  _ProfilcouponscreenState createState() => _ProfilcouponscreenState();
}

class _ProfilcouponscreenState extends State<Profilcouponscreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(localizations.coupon),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CouponCodeScreen(),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: localizations.available),
              Tab(text: localizations.used),
              Tab(text: localizations.expired),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AvailableCouponTab(),
            UsedCouponTab(),
            ExpiredCouponTab(),
          ],
        ),
      ),
    );
  }
}
