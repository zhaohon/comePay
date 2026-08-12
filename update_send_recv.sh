#!/bin/bash

# ZH
sed -i '' 's/"send": "发送",/"send": "提币",/g' lib/l10n/app_zh.arb
sed -i '' 's/"receive": "接收",/"receive": "充币",/g' lib/l10n/app_zh.arb

# EN
sed -i '' 's/"send": "Send",/"send": "Withdraw",/g' lib/l10n/app_en.arb
sed -i '' 's/"receive": "Receive",/"receive": "Deposit",/g' lib/l10n/app_en.arb

# AR
sed -i '' 's/"send": "إرسال",/"send": "سحب",/g' lib/l10n/app_ar.arb
sed -i '' 's/"receive": "استلام",/"receive": "إيداع",/g' lib/l10n/app_ar.arb

# ID
sed -i '' 's/"send": "Kirim",/"send": "Tarik",/g' lib/l10n/app_id.arb
sed -i '' 's/"receive": "Terima",/"receive": "Setor",/g' lib/l10n/app_id.arb

