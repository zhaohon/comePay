import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/models/card_account_details_model.dart';

class CardBenefitsScreen extends StatelessWidget {
  final CardAccountDetailsModel cardDetails;

  const CardBenefitsScreen({
    super.key,
    required this.cardDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.cardBenefits,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部卡片图
            Center(
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/card.png'),
                    fit: BoxFit.fill,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 费率网格
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              children: [
                _buildBenefitItem(
                  context,
                  l10n.monthlyFee,
                  '${cardDetails.monthlyFee.toStringAsFixed(0)} ${cardDetails.currencyCode}',
                ),
                _buildBenefitItem(
                  context,
                  l10n.monthlyLimit,
                  '${cardDetails.monthQuota.toStringAsFixed(0)} ${cardDetails.currencyCode}',
                ),
                _buildBenefitItem(
                  context,
                  l10n.fxFee,
                  '${cardDetails.fxFee.toStringAsFixed(2)} %',
                ),
                _buildBenefitItem(
                  context,
                  l10n.transactionFee,
                  '${cardDetails.transactionFee.toStringAsFixed(2)} %',
                ),
                _buildBenefitItem(
                  context,
                  l10n.crossBorderFee,
                  '${cardDetails.crossBorderFee.toStringAsFixed(0)} %',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 说明文字
            // Text(
            //   l10n.instructions,
            //   style: const TextStyle(
            //     fontSize: 14,
            //     color: Color(0xFF9CA3AF),
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
            // const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.attach_money,
            color: Color(0xFF9CA3AF),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9CA3AF),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1A1D1E),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
