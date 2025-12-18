import 'package:comecomepay/views/homes/SendScreen.dart' show Sendscreen;

import 'package:comecomepay/views/homes/WalletAccountScreen.dart'
    show WalletScreen;
import 'package:comecomepay/views/homes/TransactionHistoryHistory.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/locale_provider.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../../viewmodels/home_screen_viewmodel.dart';
import '../../viewmodels/transaction_record_viewmodel.dart';
import '../../viewmodels/wallet_viewmodel.dart';

import 'ReceiveScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isVisible = true; // Untuk toggle visibilitas Total Assets
  late WalletViewModel _walletViewModel;

  @override
  void initState() {
    super.initState();
    final notificationViewModel =
        Provider.of<NotificationViewModel>(context, listen: false);
    notificationViewModel.fetchUnreadNotificationCount();
    // Transaction records are now fetched in the Consumer below

    _walletViewModel = Provider.of<WalletViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _walletViewModel.fetchWalletData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<LocaleProvider, NotificationViewModel,
        TransactionRecordViewModel, WalletViewModel>(
      builder: (context, localeProvider, notificationViewModel,
          transactionRecordViewModel, walletViewModel, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isSmallScreen = screenWidth < 600;
        final paddingValue = screenWidth * 0.04;

        final notificationCount = notificationViewModel.unreadNotificationCount;

        return Scaffold(
          backgroundColor: Colors.white,
          body: OrientationBuilder(
            builder: (context, orientation) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: EdgeInsets.all(paddingValue),
                    child: RefreshIndicator(
                      onRefresh: () => walletViewModel.fetchWalletData(),
                      child: CustomScrollView(
                        slivers: [
                          SliverAppBar(
                            title: Text(
                              AppLocalizations.of(context)!
                                  .welcomeToComeComePay,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 18 : 20,
                              ),
                            ),
                            backgroundColor: Colors.white,
                            floating: true,
                            snap: true,
                            pinned: true,
                            elevation: 0,
                            actions: [
                              Container(
                                width: isSmallScreen ? 35 : 40,
                                height: isSmallScreen ? 35 : 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFA3A8AC),
                                  shape: BoxShape.circle,
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/NotificationScreen');
                                      },
                                      child: Icon(
                                        Icons.notifications_none,
                                        color: Colors.white,
                                        size: isSmallScreen ? 20 : 24,
                                      ),
                                    ),
                                    if (notificationCount > 0)
                                      Positioned(
                                        right: -4,
                                        top: -4,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: BoxConstraints(
                                            minWidth: isSmallScreen ? 14 : 16,
                                            minHeight: isSmallScreen ? 14 : 16,
                                          ),
                                          child: Center(
                                            child: Text(
                                              notificationCount > 99
                                                  ? '99+'
                                                  : '$notificationCount',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    isSmallScreen ? 8 : 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(screenWidth * 0.05),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                        0xFF1A4D8F), // Slightly lighter #014799
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            _isVisible
                                                ? walletViewModel
                                                    .getFormattedBalance()
                                                : "****",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isSmallScreen ? 20 : 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.02),
                                          DropdownButton<String>(
                                            value: walletViewModel
                                                .selectedCurrency,
                                            dropdownColor:
                                                const Color(0xFF1A4D8F),
                                            underline: Container(),
                                            iconEnabledColor: Colors.white,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isSmallScreen ? 16 : 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            items: walletViewModel
                                                .listAssets.keys
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                walletViewModel
                                                    .selectCurrency(newValue);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenWidth * 0.015),
                                      Row(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .totalAssets,
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize:
                                                    isSmallScreen ? 14 : 16),
                                          ),
                                          SizedBox(width: screenWidth * 0.02),
                                          Text(
                                            _isVisible
                                                ? walletViewModel.totalAssets
                                                    .toStringAsFixed(2)
                                                : "****",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isSmallScreen ? 14 : 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.visibility,
                                                color: Colors.white,
                                                size: isSmallScreen ? 20 : 24),
                                            onPressed: () {
                                              setState(() {
                                                _isVisible = !_isVisible;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.05),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Wrap(
                                      spacing: screenWidth * 0.05,
                                      runSpacing: screenWidth * 0.05,
                                      alignment: WrapAlignment.spaceAround,
                                      children: [
                                        buildActionIcon(Icons.send,
                                            AppLocalizations.of(context)!.send,
                                            () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      Sendscreen()));
                                        }),
                                        buildActionIcon(
                                            Icons.download,
                                            AppLocalizations.of(context)!
                                                .receive, () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      TokenReceiveScreen()));
                                        }),
                                        buildActionIcon(Icons.swap_horiz,
                                            AppLocalizations.of(context)!.swap,
                                            () {
                                          Navigator.pushNamed(
                                              context, '/SwapDetailScreen');
                                        }),
                                        buildActionIcon(
                                            Icons.account_circle,
                                            AppLocalizations.of(context)!
                                                .account, () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      WalletScreen()));
                                        }),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: screenWidth * 0.05),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .latestTransactions,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.02),
                              ],
                            ),
                          ),
                          // Available Currencies as Latest Transactions
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final currency = walletViewModel
                                    .availableCurrenciesList[index];
                                return Card(
                                  color: Colors.white,
                                  margin: EdgeInsets.symmetric(
                                      vertical: screenWidth * 0.015),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40)),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue[100],
                                      child: Icon(
                                        Icons.currency_exchange,
                                        color: Colors.blue,
                                        size: isSmallScreen ? 16 : 20,
                                      ),
                                    ),
                                    title: Text(
                                      '${currency.chain} - ${currency.native}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Address: ${currency.address}',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                    trailing: Text(
                                      currency.chain,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: walletViewModel
                                  .availableCurrenciesList.length,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenWidth * 0.04),
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    // Navigasi ke riwayat transaksi dengan data available currencies
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TransactionHistoryHistory(
                                          availableCurrencies: walletViewModel
                                              .availableCurrenciesList,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .seeAllTransactions,
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: isSmallScreen ? 14 : 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget buildActionIcon(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE7ECFE),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Icon(icon, size: 28, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
