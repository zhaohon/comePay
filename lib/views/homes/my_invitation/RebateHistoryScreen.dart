import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/my_invitation_viewmodel.dart';

class RebateHistoryScreen extends StatefulWidget {
  final String type; // 'card' or 'transaction'
  const RebateHistoryScreen({Key? key, required this.type}) : super(key: key);

  @override
  _RebateHistoryScreenState createState() => _RebateHistoryScreenState();
}

class _RebateHistoryScreenState extends State<RebateHistoryScreen>
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
        // Reload data
        Provider.of<MyInvitationViewModel>(context, listen: false)
            .loadCommissions(
                type: widget.type, level: _currentLevel, refresh: true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MyInvitationViewModel>(context, listen: false)
          .loadCommissions(type: widget.type, level: 1, refresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'card' ? "開卡返傭" : "消費返傭";

    final level1Label = widget.type == 'card' ? "一級開卡返傭" : "一級消費返傭";

    final level2Label = widget.type == 'card' ? "二級開卡返傭" : "二級消費返傭";

    final tab1Label = widget.type == 'card' ? "一級開卡" : "一級消費";
    final tab2Label = widget.type == 'card' ? "二級開卡" : "二級消費";

    // Values from stats
    // We should ideally use stats from VM, but stats keys differ by type.
    // Let's grab them dynamically.

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            title,
            style: const TextStyle(
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
                  onChanged: (_) {},
                ),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            // Stats Row
            Consumer<MyInvitationViewModel>(builder: (context, vm, _) {
              String l1Val = "0";
              String l2Val = "0";

              if (widget.type == 'card') {
                l1Val = "${vm.stats['level1_card_opening_commission'] ?? 0}";
                l2Val = "${vm.stats['level2_card_opening_commission'] ?? 0}";
              } else {
                l1Val = "${vm.stats['level1_transaction_commission'] ?? 0}";
                l2Val = "${vm.stats['level2_transaction_commission'] ?? 0}";
              }

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(level1Label, l1Val),
                    _buildStatItem(level2Label, l2Val),
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
                tabs: [
                  Tab(text: tab1Label),
                  Tab(text: tab2Label),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<MyInvitationViewModel>(
                builder: (context, vm, child) {
                  if (vm.isListLoading && vm.commissions.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vm.commissions.isEmpty) {
                    return const Center(child: Text("暫無數據"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vm.commissions.length,
                    itemBuilder: (context, index) {
                      final item = vm.commissions[index];
                      return _buildCommissionItem(item, widget.type);
                    },
                  );
                },
              ),
            )
          ],
        ));
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

  Widget _buildCommissionItem(dynamic item, String type) {
    // Determine labels based on type
    final amountLabel = type == 'card' ? "支付費用" : "消費結算金額";
    final amountValue =
        "${item['source_amount'] ?? 0} ${item['currency'] ?? ''}";
    final rebateLabel = type == 'card' ? "返佣" : "消費返佣";
    final rebateValue =
        "${item['commission_amount']} ${item['currency'] ?? ''}";

    // Status can be 'pending', 'credited', 'failed'
    // Mapping simply for now
    String status = item['status'] ?? '';
    if (status == 'credited')
      status = "成功";
    else if (status == 'pending')
      status = "處理中";
    else if (status == 'failed') status = "失敗";

    final statusText = (type == 'card' ? "開卡" : "消費") + status;

    final date = item['created_at'] ?? '';
    final email =
        item['referee'] != null ? (item['referee']['email'] ?? '') : '';

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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(email,
                style: const TextStyle(fontSize: 14, color: Color(0xFF546E7A))),
          ]),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(statusText,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF00C853),
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  // Hide this if not needed for specific type, but keeping consistent
                  Text(type == 'card' ? "開卡時間:" : "消費結算時間:",
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF78909C))),
                  Text(date,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF78909C))),
                ],
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(amountLabel,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0B2735),
                        fontWeight: FontWeight.bold)),
                Text(amountValue,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF00C853),
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(rebateLabel,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0B2735),
                        fontWeight: FontWeight.bold)),
                Text(rebateValue,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF00C853),
                        fontWeight: FontWeight.bold)),
              ])
            ],
          )
        ],
      ),
    );
  }
}
