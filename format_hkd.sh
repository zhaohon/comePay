#!/bin/bash
# 1. Update WalletViewModel spoof object
sed -i '' 's/coinName: "HKD 法币"/coinName: ""/g' lib/viewmodels/wallet_viewmodel.dart
sed -i '' 's/symbol: "HKD"/symbol: ""/g' lib/viewmodels/wallet_viewmodel.dart
sed -i '' 's/mainSymbol: "HKD"/mainSymbol: ""/g' lib/viewmodels/wallet_viewmodel.dart

# 2. Update TokenNetworkListSend Image.network to support assets/
awk '
/child: Image.network\(/ {
    print "                              child: balance.logo.startsWith(\"assets/\")"
    print "                                  ? Image.asset("
    print "                                      balance.logo,"
    print "                                      width: 44,"
    print "                                      height: 44,"
    print "                                      fit: BoxFit.cover,"
    print "                                      errorBuilder: (context, error, stackTrace) {"
    print "                                        return Icon(Icons.attach_money, color: AppColors.primary, size: 24);"
    print "                                      },"
    print "                                    )"
    print "                                  : Image.network("
    next
}
{print}
' lib/views/homes/widgets/token_network_list_send.dart > tmp1.dart && mv tmp1.dart lib/views/homes/widgets/token_network_list_send.dart

# 3. Update TokenNetworkListSend Text underneath to hide if empty
awk '
/Text\(/ {
    if (match(nextLine, /balance\.coinName\.isNotEmpty/)) {
        print "                          if (balance.coinName.isNotEmpty || balance.symbol.isNotEmpty)"
    }
}
{
    nextLine = $0
    print $0
}
' lib/views/homes/widgets/token_network_list_send.dart > tmp2.dart && mv tmp2.dart lib/views/homes/widgets/token_network_list_send.dart

