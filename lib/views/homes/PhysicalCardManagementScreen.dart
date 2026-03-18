import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/models/card_account_details_model.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/models/responses/get_profile_response_model.dart';
import 'package:comecomepay/views/homes/ActivatePhysicalCardScreen.dart'
    show ActivatePhysicalCardScreen;
import 'package:comecomepay/views/homes/QueryPinScreen.dart';

class PhysicalCardManagementScreen extends StatefulWidget {
  final CardAccountDetailsModel? cardDetails;

  const PhysicalCardManagementScreen({
    super.key,
    this.cardDetails,
  });

  @override
  State<PhysicalCardManagementScreen> createState() =>
      _PhysicalCardManagementScreenState();
}

class _PhysicalCardManagementScreenState
    extends State<PhysicalCardManagementScreen> {
  GetProfileResponseModel? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final profile = await HiveStorageService.getProfileData();
    if (mounted) {
      setState(() {
        _profileData = profile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left,
              color: Color(0xFF1A1D1E), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizations.physicalCard,
          style: const TextStyle(
            color: Color(0xFF1A1D1E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    title: localizations.queryPinCode,
                    onTap: () {
                      if (widget.cardDetails == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QueryPinScreen(
                            publicToken: widget.cardDetails!.publicToken,
                            email: _profileData?.user.email ?? "",
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    title: localizations.resetPinCode,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ActivatePhysicalCardScreen(
                            isReset: true,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    title: localizations.reissuePhysicalCard,
                    onTap: () {
                      // TODO: Implement Reissue logic or navigate to screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(localizations.featureComingSoon)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A1D1E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFC4C4C4),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
