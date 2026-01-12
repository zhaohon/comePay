import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/views/homes/my_invitation/MyInvitationScreen.dart';
import 'package:comecomepay/viewmodels/invite_friend_viewmodel.dart';
import 'package:provider/provider.dart';

class InviteFriendScreen extends StatefulWidget {
  const InviteFriendScreen({super.key});

  @override
  _InviteFriendScreenState createState() => _InviteFriendScreenState();
}

class _InviteFriendScreenState extends State<InviteFriendScreen> {
  final InviteFriendViewModel _viewModel = InviteFriendViewModel();
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    // Use addPostFrameCallback to avoid set state during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadData();
    });
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Using a ChangeNotifierProvider if we want to use Consumer down the tree,
    // or just direct usage since we are locally managing the VM instance.
    // For simplicity with the existing pattern, direct usage inside State is fine
    // but wrapping with ChangeNotifierProvider is cleaner for potentially deeper widgets.
    return ChangeNotifierProvider<InviteFriendViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA), // Light background
        appBar: AppBar(
          backgroundColor:
              const Color(0xFFE3F7FA), // Matching the banner background
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            localizations.inviteFriend,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          actions: [
            _buildSmallButton("Rules", () {
              // TODO: Navigate to Rules
            }),
            const SizedBox(width: 8),
            _buildSmallButton("My", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyInvitationScreen(),
                ),
              );
            }),
            const SizedBox(width: 16),
          ],
        ),
        body: _viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _buildBanner(context, localizations),
                            const SizedBox(height: 20),
                            _buildTierCards(context, localizations),
                            const SizedBox(height: 20),
                            _buildNodePartner(context, localizations),
                            const SizedBox(height: 20),
                            _buildInvitationSteps(context, localizations),
                            const SizedBox(
                                height: 100), // Space for bottom button
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_viewModel.errorMessage.isNotEmpty)
                    Center(child: Text(_viewModel.errorMessage)),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildBottomButton(context, localizations),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSmallButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, AppLocalizations localizations) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE3F7FA), // Light cyan/blue
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.inviteFriendsRebate,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0B2735),
                      height: 1.1),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.moreFriendsHigherCommission,
                  style: const TextStyle(
                    color: Color(0xFF546E7A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Image.asset(
              "assets/gift.png",
              fit: BoxFit.contain,
              height: 100, // Adjust based on asset
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCards(BuildContext context, AppLocalizations localizations) {
    // If no configs, show empty or default
    if (_viewModel.tierConfigs.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 180, // Adjust height as needed
          child: PageView.builder(
            controller: _pageController,
            itemCount: _viewModel.tierConfigs.length > 1
                ? _viewModel.tierConfigs.length - 1
                : 0,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              // User requested to remove the first item (default/V0)
              // So we offset the index by 1 when accessing the original list
              // But we keep using 'index' for decoration to ensure V1 gets the first style if desired.
              // Assuming user wants V1 to be the "first" card shown.

              if (index >= _viewModel.tierConfigs.length - 1)
                return const SizedBox.shrink(); // Safety check

              final config =
                  _viewModel.tierConfigs[index + 1]; // Skip the first one (V0)
              final isCurrent =
                  config['tier_level'] == _viewModel.userTier['tier_level'];

              // Mocking progress for other cards or using actual progress if it matches current tier
              // Logic:
              // If card is current tier, show actual progress.
              // If card is lower tier, show completed.
              // If card is higher tier, show 0 or actual if available.
              // For simplicity, showing actual progress only on current tier card, others static or based on logic.

              int currentReferrals = 0;
              int maxReferrals = config['min_referral_count'] ??
                  10; // This might be logic dependent
              if (isCurrent) {
                currentReferrals =
                    _viewModel.tierProgress['current_referrals'] ?? 0;
                maxReferrals = _viewModel.tierProgress['required_referrals'] ??
                    config['max_referral_count'] ??
                    100;
              } else if (config['tier_level'] <
                  (_viewModel.userTier['tier_level'] ?? 1)) {
                currentReferrals = config['max_referral_count'] ?? 10;
                maxReferrals = config['max_referral_count'] ?? 10;
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.all(16),
                decoration: _getTierDecoration(index),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.emoji_events_outlined,
                                color: _getTierColor(index)),
                            const SizedBox(width: 8),
                            Text(
                              config['tier_name'] ?? "V${config['tier_level']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: _getTierColor(index)),
                            ),
                          ],
                        ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD54F),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(localizations.currentLevel /*Current*/,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: maxReferrals > 0
                                  ? (currentReferrals / maxReferrals)
                                      .clamp(0.0, 1.0)
                                  : 0,
                              backgroundColor: Colors.white,
                              color: _getTierColor(index),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "$currentReferrals/$maxReferrals",
                          style: TextStyle(
                              color: _getTierColor(index),
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRebateItem(
                            localizations.cardRebate,
                            "${((config['level1_card_opening_rate'] ?? 0) * 100).toStringAsFixed(0)}%",
                            _getTierColor(index)),
                        _buildRebateItem(
                            localizations.spendingRebate,
                            "${((config['level1_transaction_rate'] ?? 0) * 100).toStringAsFixed(2)}%",
                            _getTierColor(index)),
                        _buildRebateItem(
                            localizations.secondary,
                            "${((config['level2_card_opening_rate'] ?? 0) * 100).toStringAsFixed(0)}%",
                            _getTierColor(index)),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              _viewModel.tierConfigs.length > 1
                  ? _viewModel.tierConfigs.length - 1
                  : 0, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? const Color(0xFF00BFA5)
                    : Colors.grey.shade300,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRebateItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildNodePartner(
      BuildContext context, AppLocalizations localizations) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Row(
        children: [
          Image.asset("assets/join.png",
              width: 60, height: 60), // The megaphone icon
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.nodePartnerProgram,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate or Apply
                  },
                  child: Text(
                    localizations.applyHighRebate,
                    style: const TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInvitationSteps(
      BuildContext context, AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Invitation Steps",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 20),
          _buildStepItem(Icons.refresh, localizations.shareInvitationLink),
          _buildVerticalLine(),
          _buildStepItem(
              Icons.person_outline, localizations.friendCompleteRegistration),
          _buildVerticalLine(),
          _buildStepItem(
              Icons.monetization_on_outlined, localizations.earnRebates),
        ],
      ),
    );
  }

  Widget _buildStepItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF0B2735)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  color: Color(0xFF37474F), fontSize: 14, height: 1.5)),
        )
      ],
    );
  }

  Widget _buildVerticalLine() {
    return Container(
      margin: const EdgeInsets.only(
          left: 19,
          top: 4,
          bottom:
              4), // Center with the icon box approx (box is 20+16=36, center ~18)
      height: 20,
      width: 2,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildBottomButton(
      BuildContext context, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: () {
          _showShareDialog(context, localizations);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B2735), // Dark Blue
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          localizations.shareNowCashback,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors
                .transparent, // To handle the close button outside if needed, or just custom card
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      _buildCopyField(localizations.invitationCode,
                          _viewModel.referralCode),
                      const SizedBox(height: 16),
                      _buildCopyField(localizations.invitationLink,
                          _viewModel.getReferralLink()),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.close, size: 20, color: Colors.grey),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget _buildCopyField(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF78909C))),
                  const SizedBox(height: 4),
                  Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0B2735),
                          fontWeight: FontWeight.w500)),
                ],
              )),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Copied!'),
                    duration: Duration(milliseconds: 500)),
              );
            },
            child: const Icon(Icons.copy_outlined,
                color: Color(0xFF0B2735), size: 20),
          )
        ],
      ),
    );
  }

  BoxDecoration _getTierDecoration(int index) {
    // 0: Greenish
    // 1: Yellowish
    // 2: Brownish
    // 3: Dark
    final i = index % 4;
    List<Color> colors;

    switch (i) {
      case 0:
        colors = [
          const Color.fromRGBO(9, 187, 136, 0.2),
          const Color.fromRGBO(214, 255, 244, 0.2)
        ];
        break;
      case 1:
        colors = [
          const Color.fromRGBO(242, 197, 33, 0.4),
          const Color.fromRGBO(255, 233, 152, 0.4)
        ];
        break;
      case 2:
        colors = [
          const Color.fromRGBO(150, 123, 108, 0.4),
          const Color.fromRGBO(255, 217, 196, 0.4)
        ];
        break;
      case 3:
      default:
        colors = [
          const Color.fromRGBO(33, 30, 22, 1),
          const Color.fromRGBO(33, 30, 22, 0.8)
        ];
        break;
    }

    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  Color _getTierColor(int index) {
    final i = index % 4;
    switch (i) {
      case 0:
        return const Color.fromRGBO(9, 187, 138, 1);
      case 1:
        return const Color.fromRGBO(191, 152, 11, 1);
      case 2:
        return const Color.fromRGBO(110, 91, 81, 1);
      case 3:
        return const Color.fromRGBO(229, 174, 73, 1);
      default:
        return const Color(0xFF00695C);
    }
  }
}
