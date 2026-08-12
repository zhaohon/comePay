#!/bin/bash
sed -i '' '/_walletResponse = await _walletService.getWalletById(user.id);/a\
\
            // Inject HKD as an unclickable balance item\
            _walletResponse!.wallet.balances.add(WalletBalance(\
              id: -1,\
              currency: "HKD",\
              balance: _walletResponse!.wallet.totalAssetHkd,\
              mainCoinType: 0,\
              coinType: "",\
              symbol: "HKD",\
              decimals: 2,\
              tokenStatus: 1,\
              mainSymbol: "HKD",\
              logo: "assets/hkd.png",\
              coinName: "HKD 法币",\
              address: "",\
              createdAt: "",\
              updatedAt: "",\
            ));\
\
' lib/viewmodels/wallet_viewmodel.dart

