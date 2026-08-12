#!/bin/bash

# ZH
sed -i '' 's/^}$/  ,"confirmReceivePhysicalCardTitle": "确认收到实体卡？",\n  "confirmReceivePhysicalCardDesc": "请确认快递已送达并由您本人签收，确认后将进入卡片激活流程。",\n  "cardDeliveryConfirmed": "已确认收货！",\n  "cardDeliveryConfirmFailed": "确认收货失败: {error}",\n  "@cardDeliveryConfirmFailed": { "placeholders": { "error": { "type": "String" } } }\n}/g' lib/l10n/app_zh.arb

# EN
sed -i '' 's/^}$/  ,"confirmReceivePhysicalCardTitle": "Confirm Receiving Physical Card?",\n  "confirmReceivePhysicalCardDesc": "Please confirm that the package has been delivered and signed by yourself. Upon confirmation, you will enter the card activation process.",\n  "cardDeliveryConfirmed": "Delivery Confirmed!",\n  "cardDeliveryConfirmFailed": "Confirm delivery failed: {error}",\n  "@cardDeliveryConfirmFailed": { "placeholders": { "error": { "type": "String" } } }\n}/g' lib/l10n/app_en.arb

# AR
sed -i '' 's/^}$/  ,"confirmReceivePhysicalCardTitle": "هل تؤكد استلام البطاقة الفعلية؟",\n  "confirmReceivePhysicalCardDesc": "يرجى التأكد من تسليم الطرد وتوقيعه بنفسك. عند التأكيد، ستدخل عملية تنشيط البطاقة.",\n  "cardDeliveryConfirmed": "تم تأكيد التسليم!",\n  "cardDeliveryConfirmFailed": "فشل تأكيد التسليم: {error}",\n  "@cardDeliveryConfirmFailed": { "placeholders": { "error": { "type": "String" } } }\n}/g' lib/l10n/app_ar.arb

# ID
sed -i '' 's/^}$/  ,"confirmReceivePhysicalCardTitle": "Konfirmasi Penerimaan Kartu Fisik?",\n  "confirmReceivePhysicalCardDesc": "Harap konfirmasi bahwa paket telah dikirim dan ditandatangani oleh Anda sendiri. Setelah konfirmasi, Anda akan masuk ke proses aktivasi kartu.",\n  "cardDeliveryConfirmed": "Pengiriman Dikonfirmasi!",\n  "cardDeliveryConfirmFailed": "Gagal mengonfirmasi pengiriman: {error}",\n  "@cardDeliveryConfirmFailed": { "placeholders": { "error": { "type": "String" } } }\n}/g' lib/l10n/app_id.arb

