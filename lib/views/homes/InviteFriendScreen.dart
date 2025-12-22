import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/invite_friend_viewmodel.dart';

class InviteDialog extends StatefulWidget {
  final InviteFriendViewModel viewModel;

  const InviteDialog(this.viewModel, {super.key});

  @override
  _InviteDialogState createState() => _InviteDialogState();
}

class _InviteDialogState extends State<InviteDialog> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Invitation Code
          _buildCopyBox(
            label:
                "${AppLocalizations.of(context)!.invitationCode} : ${widget.viewModel.invitationCode.isEmpty ? 'Loading...' : widget.viewModel.invitationCode}",
            value: widget.viewModel.invitationCode,
          ),

          const SizedBox(height: 12),

          // Invitation Link
          _buildCopyBox(
            label:
                "${AppLocalizations.of(context)!.invitationLink} : ${widget.viewModel.invitationLink.isEmpty ? 'Loading...' : widget.viewModel.invitationLink}",
            value: widget.viewModel.invitationLink,
          ),

          const SizedBox(height: 20),

          // Share icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareItem("assets/whatsapp.png",
                  AppLocalizations.of(context)!.whatsapp),
              _buildShareItem("assets/telegram.png",
                  AppLocalizations.of(context)!.telegram),
              _buildShareItem(
                  "assets/wechat.png", AppLocalizations.of(context)!.wechat),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Box with copy
  Widget _buildCopyBox({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
            },
          ),
        ],
      ),
    );
  }

  // Share item
  Widget _buildShareItem(String asset, String label) {
    return Column(
      children: [
        Image.asset(asset, height: 40),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class InviteFriendScreen extends StatefulWidget {
  const InviteFriendScreen({super.key});

  @override
  _InviteFriendScreenState createState() => _InviteFriendScreenState();
}

class _InviteFriendScreenState extends State<InviteFriendScreen> {
  final InviteFriendViewModel _viewModel = InviteFriendViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.loadReferral();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0177FF), // biru terang
                  Color(0xFF0B2735), // biru gelap
                ],
                stops: [0.2, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Center(
                            child: Text(
                              localizations.inviteFriend,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Invite Friends Card
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localizations.inviteFriendsRebate,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Colors.yellowAccent,
                                          fontSize: screenWidth * 0.06,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.005),
                                      Text(
                                        localizations
                                            .moreFriendsHigherCommission,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.035),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  child: Center(
                                    child: Image.asset(
                                      "assets/gift.png", // ganti dengan gambar ilustrasi
                                      height: screenHeight * 0.25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Level Section
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildLevelCard(context, "V1", 0, 10, 10, 0.5,
                                      10, screenWidth),
                                  SizedBox(width: screenWidth * 0.03),
                                  _buildLevelCard(context, "V2", 0, 30, 20, 0.8,
                                      10, screenWidth),
                                  SizedBox(width: screenWidth * 0.03),
                                  _buildLevelCard(context, "V3", 5, 50, 30, 1.2,
                                      15, screenWidth),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Node partner section
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: SizedBox(
                              height: 140,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    "assets/diamond.png",
                                    height: screenHeight * 0.2,
                                    width: screenWidth * 0.4,
                                    fit: BoxFit.contain,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localizations.nodePartnerProgram,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        Text(
                                          localizations.applyHighRebate,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.greenAccent,
                                            fontSize: screenWidth * 0.035,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // Invitation steps
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStep(localizations.shareInvitationLink),
                              _buildStep(
                                  localizations.friendCompleteRegistration),
                              _buildStep(localizations.earnRebates),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.04),

                          // Button
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.08),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize:
                                    Size(double.infinity, screenHeight * 0.06),
                              ),
                              onPressed: () async {
                                bool success = await _viewModel.inviteFriend();
                                if (success) {
                                  _showInviteDialog(context);
                                }
                              },
                              child: Text(
                                localizations.shareNowCashback,
                                style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.white),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_viewModel.isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        if (_viewModel.errorMessage.isNotEmpty)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _viewModel.errorMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _viewModel.errorMessage = '';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Bottom sheet dialog
  void _showInviteDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => InviteDialog(_viewModel),
    );
  }

  // Box with copy
  Widget _buildCopyBox({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
            },
          ),
        ],
      ),
    );
  }

  // Share item
  Widget _buildShareItem(String asset, String label) {
    return Column(
      children: [
        Image.asset(asset, height: 40),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Level Card
  Widget _buildLevelCard(
      BuildContext context,
      String level,
      int current,
      int max,
      double rebate,
      double spending,
      double secondary,
      double screenWidth) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      width: screenWidth * 0.4,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              localizations.currentLevel,
              style: TextStyle(
                color: Colors.black87,
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Row(
            children: [
              Icon(Icons.emoji_events,
                  color: Colors.amber, size: screenWidth * 0.05),
              SizedBox(width: screenWidth * 0.01),
              Text(
                level,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: current / max,
                    minHeight: screenWidth * 0.025,
                    backgroundColor: Colors.white,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.015),
              Text(
                "$current/$max",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "${localizations.cardRebate}\n${rebate.toStringAsFixed(0)}%",
                  style: TextStyle(
                      fontSize: screenWidth * 0.025, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  "${localizations.spendingRebate}\n${spending.toStringAsFixed(1)}%",
                  style: TextStyle(
                      fontSize: screenWidth * 0.025, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  "${localizations.secondary}\n${secondary.toStringAsFixed(0)}%",
                  style: TextStyle(
                      fontSize: screenWidth * 0.025, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Step
  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
