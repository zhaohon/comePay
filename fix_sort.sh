#!/bin/bash
# Remove local sort
sed -i '' '/final sortedBalances = List<WalletBalance>.from(viewModel.balances);/,/});/d' lib/views/homes/widgets/token_network_list_send.dart
sed -i '' 's/sortedBalances\.isEmpty/viewModel.balances.isEmpty/g' lib/views/homes/widgets/token_network_list_send.dart
sed -i '' 's/sortedBalances\.length/viewModel.balances.length/g' lib/views/homes/widgets/token_network_list_send.dart
sed -i '' 's/sortedBalances\[index\]/viewModel.balances\[index\]/g' lib/views/homes/widgets/token_network_list_send.dart

# Add global sort in viewmodel after _walletResponse is set
# In WalletViewModel, line around 48 is `_walletResponse = await _walletService.getWalletById(user.id);`
sed -i '' '/_walletResponse = await _walletService.getWalletById(user.id);/a\
            // Global sort putting USDT prefix at bottom... wait, USDT at top!\
            _walletResponse!.wallet.balances.sort((a, b) {\
              final isAUsdt = a.currency.toUpperCase().startsWith("USDT");\
              final isBUsdt = b.currency.toUpperCase().startsWith("USDT");\
              if (isAUsdt \!\= isBUsdt) return isAUsdt ? -1 : 1;\
              return a.currency.compareTo(b.currency);\
            });\
' lib/viewmodels/wallet_viewmodel.dart

