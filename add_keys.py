import json
import collections

keys = [
    {
        "key": "threeDsSettingTitle",
        "en": "3DS Verification Settings",
        "zh": "3DS 验证设置",
        "ar": "إعدادات التحقق 3DS",
    },
    {
        "key": "threeDsPlanOtp",
        "en": "OTP (Email Verification)",
        "zh": "OTP (邮箱验证码)",
        "ar": "إنشاء كلمة مرور (OTP)",
    },
    {
        "key": "threeDsPlanBio",
        "en": "BIO (App Push Authorization)",
        "zh": "BIO (App 推送授权)",
        "ar": "تطبيق الدفع (BIO)",
    },
    {
        "key": "threeDsPlanAll",
        "en": "Both Modes",
        "zh": "两种模式 (ALL)",
        "ar": "كلا الوضعين (ALL)",
    },
    {
        "key": "threeDsUpdateSuccess",
        "en": "Successfully updated 3DS settings",
        "zh": "修改 3DS 授权方式成功",
        "ar": "تم تحديث إعدادات 3DS بنجاح",
    },
    {
        "key": "threeDsUpdateFailed",
        "en": "Failed to update 3DS settings",
        "zh": "修改 3DS 授权方式失败",
        "ar": "فشل تحديث إعدادات 3DS",
    }
]

files = {
    "en": "lib/l10n/app_en.arb",
    "zh": "lib/l10n/app_zh.arb",
    "ar": "lib/l10n/app_ar.arb"
}

for lang, path in files.items():
    with open(path, "r") as f:
        data = json.load(f, object_pairs_hook=collections.OrderedDict)
    for k in keys:
        data[k["key"]] = k[lang]
    with open(path, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

print("Keys added to ARB files")
