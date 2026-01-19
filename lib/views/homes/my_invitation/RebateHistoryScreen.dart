import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/my_invitation_viewmodel.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/utils/app_colors.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final title = widget.type == 'card'
        ? l10n.cardRebateAction
        : l10n.transactionRebateAction;

    final level1Label = widget.type == 'card'
        ? l10n.level1CardRebate
        : l10n.level1TransactionRebate;
    final level2Label = widget.type == 'card'
        ? l10n.level2CardRebate
        : l10n.level2TransactionRebate;

    final tab1Label =
        widget.type == 'card' ? l10n.level1CardTab : l10n.level1TransactionTab;
    final tab2Label =
        widget.type == 'card' ? l10n.level2CardTab : l10n.level2TransactionTab;

    return Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          backgroundColor: AppColors.pageBackground,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            title,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          centerTitle: true,
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
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEAECF0), // Cleaner grey
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
                  labelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  tabs: [
                    Tab(text: tab1Label),
                    Tab(text: tab2Label),
                  ],
                ),
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
                    return Center(child: Text(l10n.noData));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vm.commissions.length,
                    itemBuilder: (context, index) {
                      final item = vm.commissions[index];
                      return _buildCommissionItem(item, widget.type, l10n);
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

  Widget _buildCommissionItem(
      dynamic item, String type, AppLocalizations l10n) {
    // Determine labels based on type
    final amountLabel =
        type == 'card' ? l10n.payFee : l10n.transactionSettlementAmount;
    final amountValue =
        "${item['source_amount'] ?? 0} ${item['currency'] ?? ''}";
    final rebateLabel = type == 'card' ? l10n.rebate : l10n.consumptionRebate;
    final rebateValue =
        "${item['commission_amount']} ${item['currency'] ?? ''}";

    // Status can be 'pending', 'credited', 'failed'
    String status = item['status'] ?? '';
    if (status == 'credited')
      status = l10n.success;
    else if (status == 'pending')
      status = l10n
          .statusPending; // Assuming statusPending key exists or map similar
    else if (status == 'failed')
      status = l10n.failed;
    else if (status == 'cancelled') status = l10n.statusCancelled;

    final statusText =
        (type == 'card' ? l10n.cardOpening : l10n.consumption) + status;

    final date = item['created_at'] ?? '';
    final email =
        item['referee'] != null ? (item['referee']['email'] ?? '') : '';

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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(email,
                style: const TextStyle(fontSize: 14, color: Color(0xFF546E7A))),
          ]),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusText,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF00C853),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                        type == 'card'
                            ? l10n.cardOpeningTimeLabel
                            : l10n.transactionSettlementTimeLabel,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF78909C))),
                    Text(date,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF78909C))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
