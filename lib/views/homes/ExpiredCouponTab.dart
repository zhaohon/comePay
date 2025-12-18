import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/viewmodels/coupon_viewmodel.dart';
import 'package:comecomepay/utils/service_locator.dart';

class ExpiredCouponTab extends StatefulWidget {
  const ExpiredCouponTab({super.key});

  @override
  State<ExpiredCouponTab> createState() => _ExpiredCouponTabState();
}

class _ExpiredCouponTabState extends State<ExpiredCouponTab> {
  final CouponViewModel viewModel = getIt<CouponViewModel>();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_onViewModelChanged);
    viewModel.getCoupons('expired');
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    viewModel.removeListener(_onViewModelChanged);
    scrollController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      viewModel.loadMoreCoupons('expired');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (viewModel.isLoading && viewModel.coupons.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null && viewModel.coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text(localizations.failedToLoadCoupons,
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => viewModel.refreshCoupons('expired'),
              child: Text(localizations.retry),
            ),
          ],
        ),
      );
    }

    if (viewModel.coupons.isEmpty && !viewModel.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(localizations.noExpiredCoupons,
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshCoupons('expired'),
      child: ListView.builder(
        controller: scrollController,
        itemCount: viewModel.coupons.length + (viewModel.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == viewModel.coupons.length) {
            return Center(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator()));
          }

          final coupon = viewModel.coupons[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.card_giftcard, color: Colors.red),
              title: Text(coupon.coupon.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coupon.coupon.description),
                  SizedBox(height: 4),
                  Text(
                    '${localizations.expiredLabel}: ${coupon.coupon.expiresAt.toString().split(' ')[0]}',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
              trailing: Text(
                coupon.coupon.valueType == 'percentage'
                    ? '${coupon.coupon.value}%'
                    : '\$${coupon.coupon.value}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            ),
          );
        },
      ),
    );
  }
}
