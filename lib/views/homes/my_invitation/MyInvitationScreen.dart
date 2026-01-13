import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/my_invitation_viewmodel.dart';
import 'MyFriendsScreen.dart';
import 'RebateHistoryScreen.dart';

class MyInvitationScreen extends StatelessWidget {
  const MyInvitationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyInvitationViewModel()..loadStats(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "我的邀請",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Consumer<MyInvitationViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final stats = viewModel.stats;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // AppLocalizations keys might be missing for new features.
                  // Using fallback strings directly.
                  _buildSummaryCard(
                    context,
                    title:
                        "邀請好友總人數", // AppLocalizations.of(context)!.totalFriends
                    totalValue: "${stats['total_referrals'] ?? 0}",
                    level1Label: "一級好友人數",
                    level1Value: "${stats['level1_count'] ?? 0}",
                    level2Label: "二級好友人數",
                    level2Value: "${stats['level2_count'] ?? 0}",
                    actionLabel: "我的好友",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider.value(
                            value:
                                viewModel, // Pass existing VM or create new? prefer new for list state
                            child: const MyFriendsScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    context,
                    title: "開卡總返傭",
                    totalValue:
                        "(${((stats['level1_card_opening_commission'] ?? 0) + (stats['level2_card_opening_commission'] ?? 0)).toStringAsFixed(2)})",
                    level1Label: "一級好友開卡返傭",
                    level1Value:
                        "${stats['level1_card_opening_commission'] ?? 0}",
                    level2Label: "二級好友開卡返傭",
                    level2Value:
                        "${stats['level2_card_opening_commission'] ?? 0}",
                    actionLabel: "開卡返傭",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider.value(
                            value: viewModel,
                            child: const RebateHistoryScreen(type: 'card'),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    context,
                    title: "消費總返傭",
                    totalValue:
                        "(${((stats['level1_transaction_commission'] ?? 0) + (stats['level2_transaction_commission'] ?? 0)).toStringAsFixed(2)})",
                    level1Label: "一級好友消費返傭",
                    level1Value:
                        "${stats['level1_transaction_commission'] ?? 0}",
                    level2Label: "二級好友消費返傭",
                    level2Value:
                        "${stats['level2_transaction_commission'] ?? 0}",
                    actionLabel: "消費返傭",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider.value(
                            value: viewModel,
                            child:
                                const RebateHistoryScreen(type: 'transaction'),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String totalValue,
    required String level1Label,
    required String level1Value,
    required String level2Label,
    required String level2Value,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$title $totalValue",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B2735),
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Text(
                        actionLabel,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF546E7A)),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios,
                          size: 10, color: Color(0xFF546E7A))
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level1Label,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF78909C)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      level1Value,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF00C853), // Green for values
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .end, // Align right usually looks cleaner for 2 columns
                  children: [
                    Text(
                      level2Label,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF78909C)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      level2Value,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF00C853),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
