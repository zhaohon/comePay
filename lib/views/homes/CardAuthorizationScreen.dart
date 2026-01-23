import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/card_authorization_viewmodel.dart';
import 'package:comecomepay/models/three_ds_record_model.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

class CardAuthorizationScreen extends StatelessWidget {
  const CardAuthorizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CardAuthorizationViewModel()..loadRecords(),
      child: const _CardAuthorizationView(),
    );
  }
}

class _CardAuthorizationView extends StatefulWidget {
  const _CardAuthorizationView();

  @override
  State<_CardAuthorizationView> createState() => _CardAuthorizationViewState();
}

class _CardAuthorizationViewState extends State<_CardAuthorizationView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CardAuthorizationViewModel>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.authorizationList,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CardAuthorizationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.records.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.records.isEmpty && viewModel.errorMessage == null) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noData,
                style: TextStyle(color: Colors.grey[400]),
              ),
            );
          }

          if (viewModel.errorMessage != null && viewModel.records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadRecords(refresh: true),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.loadRecords(refresh: true);
            },
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  viewModel.records.length + (viewModel.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == viewModel.records.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final record = viewModel.records[index];
                return _AuthorizationItem(record: record);
              },
            ),
          );
        },
      ),
    );
  }
}

class _AuthorizationItem extends StatelessWidget {
  final ThreeDSRecordModel record;

  const _AuthorizationItem({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Row - formatted date
          Text(
            _formatDate(record.receivedAt), // You might need a utility for this
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 12),

          // Merchant and Amount Row
          Row(
            children: [
              // Merchant Icon placeholder
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0F5), // Light pink/red bg
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 2,
                    color: const Color(0xFFD81B60), // Minus sign color
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Merchant Name
              Expanded(
                child: Text(
                  record.merchantName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Amount
              Text(
                "-${record.amount} ${record.currency}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFD81B60), // Red color for expense
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Code/Status Row
          Row(
            children: [
              const SizedBox(width: 36), // Align with text above (24 + 12)
              Text(
                "${AppLocalizations.of(context)!.code}: ${record.passcode}",
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(
                      0xFF4CAF50), // Green for successfully generated code
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Simple date formatter helper
  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      // Format: YYYY-MM-DD HH:mm:ss
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
    } catch (e) {
      return isoString;
    }
  }
}
