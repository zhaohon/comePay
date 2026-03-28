import 'package:comecomepay/views/homes/AboutUsScreen.dart';
import 'package:comecomepay/views/homes/InviteFriendScreen.dart';
import 'package:comecomepay/views/homes/MessageServiceCenterScreen.dart'
    show MessageServiceCenterScreen;
import 'package:comecomepay/views/homes/ProfilCouponScreen.dart'
    show Profilcouponscreen;
import 'package:comecomepay/views/homes/ProfilLanguageScreen.dart'
    show Profillanguagescreen;
import 'package:comecomepay/views/homes/SecurityScreen.dart'
    show Securityscreen;
import 'package:comecomepay/views/homes/UpdateProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/viewmodels/profile_screen_viewmodel.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/views/debug/token_refresh_test_page.dart';
import 'package:shimmer/shimmer.dart';

import 'ProfilKycScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? email;
  String? userId;

  @override
  void initState() {
    super.initState();
    // 1. 立即从本地缓存读取基本信息，实现“秒开”无闪烁
    final user = HiveStorageService.getUser();
    if (user != null) {
      email = user.email;
      userId = user.id.toString();
    }

    // 2. 异步初始化 ViewModel 缓存并触发网络刷新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCachedProfile();
    });
  }

  Future<void> _loadCachedProfile() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final viewModel =
          Provider.of<ProfileScreenViewModel>(context, listen: false);

      // 先尝试加载详细缓存
      await viewModel.loadCachedData();
      if (viewModel.profileResponse != null) {
        if (mounted) {
          setState(() {
            email = viewModel.profileResponse?.user.email;
            userId = viewModel.profileResponse?.user.id.toString();
          });
        }
      }

      // 然后后台静默刷新最新数据
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    print('DEBUG: ProfilScreen _loadProfile (Silent Refresh) called');
    final viewModel =
        Provider.of<ProfileScreenViewModel>(context, listen: false);
    final accessToken = HiveStorageService.getAccessToken();
    if (accessToken != null) {
      final l10n = AppLocalizations.of(context)!;
      // getProfile 内部有 setBusy(true)，我们需要确保它不阻塞主UI显示
      // 我们通过传递 isSilent: true 来实现
      await viewModel.getProfile(l10n, isSilent: true);

      if (mounted && viewModel.profileResponse != null) {
        setState(() {
          email = viewModel.profileResponse?.user.email;
          userId = viewModel.profileResponse?.user.id.toString();
        });
      }
    }

    // 无论如何，后台同步一下 KYC 状态
    final l10n = AppLocalizations.of(context)!;
    viewModel.fetchKycStatus(l10n);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 100),
          children: [
            // 用户信息卡片
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdateProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: const AssetImage("assets/profil.png"),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    email ?? AppLocalizations.of(context)!.noEmail,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ID: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        userId ?? AppLocalizations.of(context)!.noId,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy,
                            size: 18, color: Colors.grey.shade600),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: userId ?? ''));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .userIdCopied)),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Dynamic KYC Status Tag（加载中显示骨架屏，避免先展示初始化状态再闪变）
                  Consumer<ProfileScreenViewModel>(
                    builder: (context, model, child) {
                      if (model.isKycStatusLoading) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: 120,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                      final statusResponse = model.kycStatusResponse;
                      final kycStatus = statusResponse?.userKycStatus ?? 'none';

                      Color backgroundColor;
                      String text;
                      IconData icon;

                      switch (kycStatus) {
                        case 'verified':
                          backgroundColor = AppColors.success;
                          text = AppLocalizations.of(context)!.identityVerified;
                          icon = Icons.check;
                          break;
                        case 'pending':
                        case 'processing':
                        case 'pending_submit':
                          backgroundColor = AppColors.warning;
                          text = AppLocalizations.of(context)!.underReview;
                          icon = Icons.hourglass_empty;
                          break;
                        case 'rejected':
                        case 'failed':
                          backgroundColor = AppColors.error;
                          text = AppLocalizations.of(context)!.verifyFailed;
                          icon = Icons.error_outline;
                          break;
                        default:
                          backgroundColor = Colors.grey;
                          text = AppLocalizations.of(context)!.unverified;
                          icon = Icons.info_outline;
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 账户设置分组
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildProfileItem(
                    context,
                    icon: Icons.person_add,
                    title: AppLocalizations.of(context)!.inviteFriend,
                    iconColor: const Color(0xFF2196F3),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InviteFriendScreen()),
                      );
                    },
                  ),
                  _buildDivider(),
                  // _buildProfileItem(
                  //   context,
                  //   icon: Icons.camera_alt,
                  //   title: AppLocalizations.of(context)!.kyc,
                  //   iconColor: const Color(0xFF9C27B0),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => Profilkycscreen()),
                  //     );
                  //   },
                  // ),
                  // _buildDivider(),
                  _buildProfileItem(
                    context,
                    icon: Icons.language,
                    title: AppLocalizations.of(context)!.language,
                    iconColor: const Color(0xFFFF9800),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profillanguagescreen()),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildProfileItem(
                    context,
                    icon: Icons.card_giftcard,
                    title: AppLocalizations.of(context)!.coupon,
                    iconColor: const Color(0xFFE91E63),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profilcouponscreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 帮助和支持分组
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildProfileItem(
                    context,
                    icon: Icons.headset_mic,
                    title: AppLocalizations.of(context)!.customerServiceCenter,
                    iconColor: const Color(0xFF00BCD4),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MessageServiceCenterScreen()),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildProfileItem(
                    context,
                    icon: Icons.info,
                    title: AppLocalizations.of(context)!.aboutUs,
                    iconColor: const Color(0xFF607D8B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AboutUsScreen()),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildProfileItem(
                    context,
                    icon: Icons.security,
                    title: AppLocalizations.of(context)!.security,
                    iconColor: const Color(0xFFF44336),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Securityscreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 68),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Colors.grey.shade200,
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
