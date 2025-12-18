import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/models/wallet_model.dart';
import 'package:comecomepay/viewmodels/transaction_history_viewmodel.dart';
import 'package:provider/provider.dart';

class TransactionHistoryHistory extends StatefulWidget {
  final List<AvailableCurrency> availableCurrencies;

  const TransactionHistoryHistory({
    super.key,
    required this.availableCurrencies,
  });

  @override
  State<TransactionHistoryHistory> createState() =>
      _TransactionHistoryHistoryState();
}

class _TransactionHistoryHistoryState extends State<TransactionHistoryHistory> {
  final ScrollController _scrollController = ScrollController();
  late TransactionHistoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TransactionHistoryViewModel();
    _viewModel.fetchTransactionHistory();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_viewModel.isLoadingMore &&
        _viewModel.transactions.isNotEmpty) {
      _viewModel.fetchTransactionHistory(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.transactionHistory,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: widget.availableCurrencies.isEmpty
          ? const Center(child: Text('No available currencies'))
          : ListView.builder(
              itemCount: widget.availableCurrencies.length,
              itemBuilder: (context, index) {
                final currency = widget.availableCurrencies[index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        //TODO
                        // color: Colors.grey.withValues(alpha: 0.1 * 255),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        //TODO
                        // backgroundColor:
                        //     Colors.blue.withValues(alpha: 0.1 * 255),
                        child: const Icon(Icons.currency_exchange,
                            color: Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${currency.chain} - ${currency.native}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Address: ${currency.address}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currency.chain,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currency.createdAt.split('T')[0], // Date part
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
