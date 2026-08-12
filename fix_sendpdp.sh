#!/bin/bash
awk '
/setState\(\(\) \{/ {
    if (processing_external == 1) {
        print "    // 通过接口检查交易密码是否已设置"
        print "    final isPasswordSet = await TransactionPasswordGuard.check(context);"
        print "    if (!isPasswordSet) return; // 未设置，已弹窗提示"
        print ""
        print "    // Show Password Bottom Sheet"
        print "    final password = await _showTransactionPasswordBottomSheet();"
        print "    if (password == null || password.isEmpty) return; // User cancelled"
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
/network: network/ {
    if (request_block == 1) {
        print $0
        print "        transactionPassword: password,"
        request_block = 0
        next
    }
}
{ print }
' lib/views/homes/SendPdp.dart > tmp.dart && mv tmp.dart lib/views/homes/SendPdp.dart
