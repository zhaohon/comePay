import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/my_invitation_viewmodel.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/utils/app_colors.dart';

class MyFriendsScreen extends StatefulWidget {
  const MyFriendsScreen({Key? key}) : super(key: key);

  @override
  _MyFriendsScreenState createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentLevel = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentLevel = _tabController.index + 1;
        });
        // Reload data when tab changes
        Provider.of<MyInvitationViewModel>(context, listen: false)
            .loadReferrals(level: _currentLevel, refresh: true);
      }
    });

    // Initial Load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MyInvitationViewModel>(context, listen: false)
          .loadReferrals(level: 1, refresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.myFriends,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Summary Header
          Consumer<MyInvitationViewModel>(builder: (context, vm, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                      l10n.level1Friends, "${vm.stats['level1_count'] ?? 0}"),
                  _buildStatItem(
                      l10n.level2Friends, "${vm.stats['level2_count'] ?? 0}"),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAECF0),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                dividerColor: Colors.transparent, // Remove the bottom line
                labelStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                tabs: [
                  Tab(text: l10n.level1FriendsTab),
                  Tab(text: l10n.level2FriendsTab),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // List
          Expanded(
            child: Consumer<MyInvitationViewModel>(
              builder: (context, vm, child) {
                if (vm.isListLoading && vm.referrals.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (vm.referrals.isEmpty) {
                  return Center(child: Text(l10n.noData));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: vm.referrals.length,
                  itemBuilder: (context, index) {
                    final item = vm.referrals[index];
                    return _buildFriendItem(item, l10n);
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0B2735),
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF00C853),
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFriendItem(dynamic item, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item['email'] ?? '',
              style: const TextStyle(fontSize: 14, color: Color(0xFF546E7A))),
          const SizedBox(height: 12),
          Text("${l10n.registrationTimeLabel}${item['created_at'] ?? ''}",
              style: const TextStyle(fontSize: 12, color: Color(0xFF78909C))),
        ],
      ),
    );
  }
}
