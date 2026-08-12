#!/bin/bash
# 1. Update WithdrawRequestModel in WithdrawService 
awk '
/final String network;/ {
    print $0
    print "    final String? transactionPassword;"
    next
}
/required this\.network,/ {
    print $0
    print "      this.transactionPassword,"
    next
}
/44network44: network,/ {
    print $0
    print "        if (transactionPassword != null) 44transaction_password44: transactionPassword,"
    next
}
{print}
' lib/services/withdraw_service.dart | sed "s/44/'/g" > tmp.dart && mv tmp.dart lib/services/withdraw_service.dart

# 2. Inject TransactionPasswordGuard check in SendPdp.dart
awk '
/setState\(\(\) \{/ {
    if (processing_external == 1) {
        print "    // 等待异步完成："
        print "    final isPasswordSet = await TransactionPasswordGuard.check(context);"
        print "    if (!isPasswordSet) return;"
        print ""
        print "    final password = await _showTransactionPasswordBottomSheet();"
        print "    if (password == null || password.isEmpty) return;"
        print ""
        processing_external = 0
    }
}
/Future<void> _submitExternalWithdraw\(\) async \{/ {
    processing_external = 1
}
/final request = WithdrawRequestModel\(/ {
    request_block = 1
}
/network: network,/ {
    if (request_block == 1) {
        print $0
        print "              transactionPassword: password,"
        request_block = 0
        next
    }
}
{ print }
' lib/views/homes/SendPdp.dart > tmp.dart && mv tmp.dart lib/views/homes/SendPdp.dart

