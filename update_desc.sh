#!/bin/bash

# ZH
sed -i '' 's/请确认快递已送达并由您本人签收，确认后将进入卡片激活流程。/请确认快递已送达并由您本人签收，确认后将不再展示邮寄进度。/g' lib/l10n/app_zh.arb

# EN
sed -i '' 's/Please confirm that the package has been delivered and signed by yourself. Upon confirmation, you will enter the card activation process./Please confirm that the package has been delivered and signed by yourself. Upon confirmation, the mailing progress will no longer be displayed./g' lib/l10n/app_en.arb

# AR
sed -i '' 's/يرجى التأكد من تسليم الطرد وتوقيعه بنفسك. عند التأكيد، ستدخل عملية تنشيط البطاقة./يرجى التأكد من تسليم الطرد وتوقيعه بنفسك. عند التأكيد، لن يتم عرض تقدم البريد بعد الآن./g' lib/l10n/app_ar.arb

# ID
sed -i '' 's/Harap konfirmasi bahwa paket telah dikirim dan ditandatangani oleh Anda sendiri. Setelah konfirmasi, Anda akan masuk ke proses aktivasi kartu./Harap konfirmasi bahwa paket telah dikirim dan ditandatangani oleh Anda sendiri. Setelah konfirmasi, kemajuan pengiriman tidak akan ditampilkan lagi./g' lib/l10n/app_id.arb

