import 'package:comecomepay/views/homes/SendScreen.dart' show Sendscreen;

import 'package:comecomepay/views/homes/WalletAccountScreen.dart'
    show WalletScreen;
import 'package:comecomepay/views/transactions/unified_transaction_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/locale_provider.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../../viewmodels/home_screen_viewmodel.dart';
import '../../viewmodels/unified_transaction_viewmodel.dart';
import '../../viewmodels/wallet_viewmodel.dart';
import '../../utils/app_colors.dart';
import '../../widgets/transaction_item_widget.dart';
import 'package:comecomepay/views/transactions/transaction_detail_screen.dart';

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

    // Fetch wallet data
    _walletViewModel = Provider.of<WalletViewModel>(context, listen: false);

    // Fetch latest transactions
    final transactionViewModel =
        Provider.of<UnifiedTransactionViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _walletViewModel.fetchWalletData();
      transactionViewModel.fetchLatestTransactions(limit: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<LocaleProvider, NotificationViewModel,
        UnifiedTransactionViewModel, WalletViewModel>(
      builder: (context, localeProvider, notificationViewModel,
          transactionViewModel, walletViewModel, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isSmallScreen = screenWidth < 600;
        final paddingValue = screenWidth * 0.04;

        final notificationCount = notificationViewModel.unreadNotificationCount;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: OrientationBuilder(
            builder: (context, orientation) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: paddingValue),
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
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 16 : 18,
                              ),
                            ),
                            backgroundColor: AppColors.pageBackground,
                            floating: true,
                            snap: true,
                            pinned: false,
                            elevation: 0,
                            centerTitle: false, // 左对齐
                            titleSpacing: 0,
                            actions: [
                              Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Container(
                                    width: isSmallScreen ? 38 : 42,
                                    height: isSmallScreen ? 38 : 42,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
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
                                                minWidth:
                                                    isSmallScreen ? 14 : 16,
                                                minHeight:
                                                    isSmallScreen ? 14 : 16,
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
                                  ))
                            ],
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(screenWidth * 0.05),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFA855F7),
                                        Color(0xFFEC4899)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Stack(
                                    children: [
                                      // 主内容
                                      Column(
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
                                                  fontSize:
                                                      isSmallScreen ? 20 : 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.02),
                                              GestureDetector(
                                                onTap: () {
                                                  _showCurrencyBottomSheet(
                                                      context, walletViewModel);
                                                },
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      walletViewModel
                                                          .selectedCurrency,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: isSmallScreen
                                                            ? 16
                                                            : 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(width: 4),
                                                    Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ],
                                                ),
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
                                                    fontSize: isSmallScreen
                                                        ? 14
                                                        : 16),
                                              ),
                                              // SizedBox(
                                              //     width: screenWidth * 0.02),
                                              // Text(
                                              //   _isVisible
                                              //       ? walletViewModel
                                              //           .totalAssets
                                              //           .toStringAsFixed(2)
                                              //       : "****",
                                              //   style: TextStyle(
                                              //     color: Colors.white,
                                              //     fontSize:
                                              //         isSmallScreen ? 14 : 16,
                                              //     fontWeight: FontWeight.bold,
                                              //   ),
                                              // ),
                                              IconButton(
                                                icon: Icon(Icons.visibility,
                                                    color: Colors.white,
                                                    size: isSmallScreen
                                                        ? 20
                                                        : 24),
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
                                      // 右上角P图标
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'P',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.05),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Row(
                                      spacing: screenWidth * 0.05,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      // runSpacing: screenWidth * 0.05,
                                      // alignment: WrapAlignment.spaceBetween,
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
                                        // buildActionIcon(
                                        //     Icons.account_circle,
                                        //     AppLocalizations.of(context)!
                                        //         .account, () {
                                        //   Navigator.push(
                                        //       context,
                                        //       MaterialPageRoute(
                                        //           builder: (_) =>
                                        //               WalletScreen()));
                                        // }),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: screenWidth * 0.05),
                                // 最新交易标题和更多按钮
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .latestTransactions,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const UnifiedTransactionListScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        '更多',
                                        style: TextStyle(
                                          color: const Color(0xFFA855F7),
                                          fontSize: isSmallScreen ? 14 : 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenWidth * 0.02),
                              ],
                            ),
                          ),
                          // 最新交易记录列表 - 优化版
                          transactionViewModel.isLoading
                              ? SliverToBoxAdapter(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.04,
                                      vertical: screenWidth * 0.02,
                                    ),
                                    padding: EdgeInsets.all(screenWidth * 0.08),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Color(0xFFA855F7),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : transactionViewModel.latestTransactions.isEmpty
                                  ? SliverToBoxAdapter(
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.04,
                                          vertical: screenWidth * 0.02,
                                        ),
                                        padding:
                                            EdgeInsets.all(screenWidth * 0.08),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.receipt_long_outlined,
                                                  size: 35,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                '暂无交易记录',
                                                style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen ? 14 : 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '开始您的第一笔交易吧',
                                                style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen ? 12 : 13,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : SliverToBoxAdapter(
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.04),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            ...List.generate(
                                              transactionViewModel
                                                  .latestTransactions.length,
                                              (index) {
                                                final transaction =
                                                    transactionViewModel
                                                            .latestTransactions[
                                                        index];
                                                final isLast = index ==
                                                    transactionViewModel
                                                            .latestTransactions
                                                            .length -
                                                        1;
                                                return Column(
                                                  children: [
                                                    TransactionItemWidget(
                                                      transaction: transaction,
                                                      isInList: false,
                                                      onTap: () {
                                                        // 导航到交易详情页
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                TransactionDetailScreen(
                                                              transaction:
                                                                  transaction,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    if (!isLast)
                                                      Divider(
                                                        height: 1,
                                                        thickness: 1,
                                                        color: Colors.grey[200],
                                                        indent:
                                                            screenWidth * 0.04 +
                                                                60,
                                                      ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                          // 底部空白 - 在卡片外面
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 100),
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
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Icon(icon, size: 26, color: const Color(0xFFA855F7)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showCurrencyBottomSheet(
      BuildContext context, WalletViewModel walletViewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6, // 最大高度为屏幕的60%
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部关闭按钮
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // 可滚动的货币列表
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...walletViewModel.balances.map((balance) {
                        return InkWell(
                          onTap: () {
                            walletViewModel.selectCurrency(balance.currency);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  balance.currency,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        walletViewModel.selectedCurrency ==
                                                balance.currency
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color: walletViewModel.selectedCurrency ==
                                            balance.currency
                                        ? const Color(0xFFA855F7)
                                        : Colors.black87,
                                  ),
                                ),
                                if (walletViewModel.selectedCurrency ==
                                    balance.currency)
                                  Icon(
                                    Icons.check,
                                    color: const Color(0xFFA855F7),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
