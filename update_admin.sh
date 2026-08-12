#!/bin/bash

# ZH
sed -i '' 's/^}$/  ,"adminAdjustment": "管理员调账"\n}/g' lib/l10n/app_zh.arb

# EN
sed -i '' 's/^}$/  ,"adminAdjustment": "Admin Adjustment"\n}/g' lib/l10n/app_en.arb

# AR
sed -i '' 's/^}$/  ,"adminAdjustment": "تعديل الإدارة"\n}/g' lib/l10n/app_ar.arb

# ID
sed -i '' 's/^}$/  ,"adminAdjustment": "Penyesuaian Admin"\n}/g' lib/l10n/app_id.arb

