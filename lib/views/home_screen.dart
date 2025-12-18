import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../viewmodels/locale_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isHidden = false;
  int totalAssets = 10;

  final List<String> bannerImages = [
    'https://pokepay-server.oss-cn-hongkong.aliyuncs.com/idcard/250826/134230.jpg',
    'https://images.unsplash.com/photo-1550355291-bbee04a92027?ixlib=rb-4.0.3&auto=format&fit=crop&w=1287&q=80',
    'https://images.unsplash.com/photo-1542281286-9e0a16bb7366?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.welcomeToPokePay,
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Assets Section
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF28A745), Color(0xFF218838)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _isHidden ? '**** USD' : '$totalAssets USD',
                              style: TextStyle(
                                fontSize: 24.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            IconButton(
                              icon: Icon(
                                _isHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isHidden = !_isHidden;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          AppLocalizations.of(context)!.totalAssets,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    // Logo on the right
                    Image.asset('assets/pokepay_logo.png', height: 40.0),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(Icons.account_balance,
                      AppLocalizations.of(context)!.account),
                  _buildActionButton(Icons.arrow_downward_outlined,
                      AppLocalizations.of(context)!.deposit),
                  _buildActionButton(Icons.arrow_upward_outlined,
                      AppLocalizations.of(context)!.withdrawal),
                  _buildActionButton(Icons.swap_horiz_outlined,
                      AppLocalizations.of(context)!.swap),
                ],
              ),
              SizedBox(height: 20.0),
              // Banner Slider
              CarouselSlider(
                options: CarouselOptions(
                  height: 150.0,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                ),
                items: bannerImages.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20.0),
              // Fund Flow Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.fundFlow,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Icon(Icons.add, color: Colors.grey),
                ],
              ),
              SizedBox(height: 10.0),
              Container(
                height: 120.0,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 50.0, color: Colors.grey),
                      SizedBox(height: 10.0),
                      Text(
                        AppLocalizations.of(context)!.noRelevantDataYet,
                        style: TextStyle(fontSize: 16.0, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30.0,
          backgroundColor: Colors.grey[200],
          child: Icon(icon, size: 30.0, color: Colors.black),
        ),
        SizedBox(height: 8.0),
        Text(label, style: TextStyle(fontSize: 14.0, color: Colors.black45)),
      ],
    );
  }
}
