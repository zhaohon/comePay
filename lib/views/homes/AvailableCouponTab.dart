import 'package:flutter/material.dart';
import 'package:Demo/viewmodels/coupon_viewmodel.dart';
import 'package:Demo/utils/service_locator.dart';
import 'package:Demo/l10n/app_localizations.dart';
import 'package:Demo/utils/app_colors.dart';
import 'package:Demo/models/responses/new_coupon_model.dart';
import 'package:provider/provider.dart';

class AvailableCouponTab extends StatefulWidget {
  const AvailableCouponTab({super.key});

  @override
  State<AvailableCouponTab> createState() => _AvailableCouponTabState();
}

class _AvailableCouponTabState extends State<AvailableCouponTab> {
  final CouponViewModel viewModel = getIt<CouponViewModel>();

  @override
  void initState() {
    super.initState();
    // 加载所有优惠券（不只是有效的）
    Future.microtask(() => viewModel.loadNewCoupons(onlyValid: false));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<CouponViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(localizations.failedToLoadCoupons),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => vm.refreshNewCoupons(),
                    child: Text(localizations.retry),
                  ),
                ],
              ),
            );
          }

          final availableCoupons = vm.getCouponsByStatus('available');

          if (availableCoupons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.card_giftcard,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(localizations.noAvailableCoupons),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => vm.refreshNewCoupons(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableCoupons.length,
              itemBuilder: (context, index) {
                return _buildCouponCard(availableCoupons[index], context);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCouponCard(NewCouponModel coupon, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部：优惠券名称和金额
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Code: ${coupon.code}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${coupon.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      coupon.type.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 内容：详细信息
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  icon: Icons.shopping_bag,
                  label: 'Min Fee',
                  value: '\$${coupon.minFee.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.discount,
                  label: 'Max Discount',
                  value: '\$${coupon.maxDiscount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'Valid Until',
                  value: _formatDate(coupon.validUntil),
                ),
                const SizedBox(height: 12),
                // 状态标签
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          size: 16, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        'Available',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
