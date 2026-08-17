import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comecomepay/services/card_service.dart';
import '../../l10n/app_localizations.dart';

class CardTransactionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final String publicToken;

  const CardTransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.publicToken,
  });

  @override
  State<CardTransactionDetailScreen> createState() =>
      _CardTransactionDetailScreenState();
}

class _CardTransactionDetailScreenState
    extends State<CardTransactionDetailScreen> {
  final CardService _cardService = CardService();
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _detailData;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    final tradeIdStr =
        (widget.transaction['trade_id'] ?? widget.transaction['id'] ?? '')
            .toString();
    final tradeId = int.tryParse(tradeIdStr) ?? 0;

    if (tradeId == 0 || widget.publicToken.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalizations.of(context)!.cardTxInvalidId;
        });
      }
      return;
    }

    try {
      final data = await _cardService.getCardTradeDetail(
        tradeId: tradeId,
        publicToken: widget.publicToken,
      );
      if (mounted) {
        setState(() {
          _detailData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              '${AppLocalizations.of(context)!.cardTxFetchFailed} $e';
        });
      }
    }
  }

  // 根据 trade_type 返回 上半部粗略说明
  String _getTradeTypeTitle(int? type, BuildContext context) {
    if (type == 17) return AppLocalizations.of(context)!.cardTxDeduction;
    if (type == 18) return AppLocalizations.of(context)!.cardTxReversal;
    if (type == 19) return AppLocalizations.of(context)!.cardTxRefund;
    return '-';
  }

  // 根据 trade_type 返回 下半部类型详情
  String _getTradeTypeDetail(int? type, BuildContext context) {
    if (type == 17) return AppLocalizations.of(context)!.cardTxAuth;
    if (type == 18) return AppLocalizations.of(context)!.cardTxRevoke;
    if (type == 19) return AppLocalizations.of(context)!.cardTxRefundShort;
    return '-';
  }

  String _formatTopAmount(Map<String, dynamic> data) {
    final amount = (data['amount'] ?? 0).toString();
    final currency = data['currency_code'] ?? '';
    final type = data['trade_type'] as int?;

    if (type == 18 || type == 19) {
      return '+$amount $currency';
    } else {
      return '-$amount $currency';
    }
  }

  String _formatOriginalAmount(Map<String, dynamic> data) {
    final amount = (data['merchant_amount'] ?? 0).toString();
    final currency = data['merchant_currency'] ?? '';
    return '$amount $currency';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.cardTxDetailsTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.purpleAccent),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    if (_detailData == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.cardTxNoData,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final data = _detailData!;
    final tradeType = data['trade_type'] as int?;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // 第一张卡片：交易详情
          _buildCardContainer(
            children: [
              _buildSectionTitle(
                  AppLocalizations.of(context)!.detailTransaction),
              const SizedBox(height: 16),
              _buildInfoRow(AppLocalizations.of(context)!.threeDsAmount,
                  _formatTopAmount(data),
                  isBoldValue: true),
              _buildDivider(),
              _buildInfoRow(AppLocalizations.of(context)!.transactionType,
                  _getTradeTypeTitle(tradeType, context)),
              _buildDivider(),
              _buildInfoRow(AppLocalizations.of(context)!.transactionTime,
                  data['trade_time']?.toString() ?? '-'),
            ],
          ),
          const SizedBox(height: 20),
          // 第二张卡片：账单详情
          _buildCardContainer(
            children: [
              _buildSectionTitle(AppLocalizations.of(context)!.billDetail),
              const SizedBox(height: 16),
              _buildInfoRow(AppLocalizations.of(context)!.cardNumber,
                  data['card_number']?.toString() ?? '-'),
              _buildDivider(),
              _buildInfoRow(AppLocalizations.of(context)!.transactionType,
                  _getTradeTypeDetail(tradeType, context)),
              _buildDivider(),
              _buildInfoRow(AppLocalizations.of(context)!.cardTxAmount,
                  _formatOriginalAmount(data)),
              _buildDivider(),
              _buildInfoRow(AppLocalizations.of(context)!.cardTxMerchant,
                  data['merchant_name']?.toString() ?? '-'),
              _buildDivider(),
              _buildInfoRow(AppLocalizations.of(context)!.cardTxCountry,
                  data['merchant_country']?.toString() ?? '-'),
              _buildDivider(),
              _buildInfoRow(AppLocalizations.of(context)!.cardTxCity,
                  data['merchant_city']?.toString() ?? '-'),
              _buildDivider(),
              _buildInfoRow(AppLocalizations.of(context)!.cardTxTraceId,
                  data['trace_id']?.toString() ?? '-'),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCardContainer({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBoldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280), // 灰黑色文字
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Color(0xFFF3F4F6),
      ),
    );
  }
}
