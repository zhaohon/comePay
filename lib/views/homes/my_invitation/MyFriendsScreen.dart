import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/my_invitation_viewmodel.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "我的好友",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text("選擇時間",
                    style: TextStyle(fontSize: 12, color: Color(0xFF0B2735))),
                icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                items: ["2025", "2024"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                onChanged: (_) {}, // Mock action
              ),
            ),
          )
        ],
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
                      "一級好友人數", "${vm.stats['level1_referrals'] ?? 0}"),
                  _buildStatItem(
                      "二級好友人數", "${vm.stats['level2_referrals'] ?? 0}"),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "一級好友"),
                Tab(text: "二級好友"),
              ],
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
                  return const Center(child: Text("暫無數據"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: vm.referrals.length,
                  itemBuilder: (context, index) {
                    final item = vm.referrals[index];
                    return _buildFriendItem(item);
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

  Widget _buildFriendItem(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item['email'] ?? '',
              style: const TextStyle(fontSize: 14, color: Color(0xFF546E7A))),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Card Activated
              Row(
                children: [
                  Text("開卡: ",
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0B2735),
                          fontWeight: FontWeight.bold)),
                  Text(
                    (item['is_card_activated'] == true) ? "是" : "否",
                    style: TextStyle(
                        fontSize: 12,
                        color: (item['is_card_activated'] == true)
                            ? const Color(0xFF00C853)
                            : Colors.red, // Green or Red
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // Physical Card
              Row(
                children: [
                  Text("升級實體卡: ",
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0B2735),
                          fontWeight: FontWeight.bold)),
                  Text(
                    (item['has_physical_card'] == true) ? "是" : "否",
                    style: TextStyle(
                        fontSize: 12,
                        color: (item['has_physical_card'] == true)
                            ? const Color(0xFF00C853)
                            : Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("註冊時間: ${item['created_at'] ?? ''}",
              style: const TextStyle(fontSize: 12, color: Color(0xFF78909C))),
        ],
      ),
    );
  }
}
