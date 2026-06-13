import re

with open("lib/views/homes/CardAuthorizationScreen.dart", "r") as f:
    content = f.read()

replacements = {
    "'3DS Verification Settings', // Will be localized": "AppLocalizations.of(context)!.threeDsSettingTitle,",
    "title: 'OTP (Email Verification)'": "title: AppLocalizations.of(context)!.threeDsPlanOtp",
    "title: 'BIO (App Push Authorization)'": "title: AppLocalizations.of(context)!.threeDsPlanBio",
    "title: 'Both Modes'": "title: AppLocalizations.of(context)!.threeDsPlanAll",
}

for k, v in replacements.items():
    content = content.replace(k, v)

with open("lib/views/homes/CardAuthorizationScreen.dart", "w") as f:
    f.write(content)

with open("/Users/admin/.gemini/antigravity/brain/b5d67282-ed58-40ef-b007-f7e00c3be737/task.md", "r") as f:
    task = f.read()

task = task.replace("- [ ] Add `updateThreeDSPlan` method to `CardService`", "- [x] Add `updateThreeDSPlan` method to `CardService`")
task = task.replace("- [ ] Add new localization keys for 3DS settings to `app_en.arb`, `app_zh.arb`, `app_ar.arb`", "- [x] Add new localization keys for 3DS settings to `app_en.arb`, `app_zh.arb`, `app_ar.arb`")
task = task.replace("- [ ] Update `CardAuthorizationScreen` to take `publicToken` via constructor and use it in `CardScreen.dart`", "- [x] Update `CardAuthorizationScreen` to take `publicToken` via constructor and use it in `CardScreen.dart`")
task = task.replace("- [ ] Add settings icon to `CardAuthorizationScreen` AppBar", "- [x] Add settings icon to `CardAuthorizationScreen` AppBar")
task = task.replace("- [ ] Implement `_showSettingsBottomSheet` in `CardAuthorizationScreen`", "- [x] Implement `_showSettingsBottomSheet` in `CardAuthorizationScreen`")
task = task.replace("- [ ] Implement `PUT /card/3ds` API action on selection", "- [x] Implement `PUT /card/3ds` API action on selection")

with open("/Users/admin/.gemini/antigravity/brain/b5d67282-ed58-40ef-b007-f7e00c3be737/task.md", "w") as f:
    f.write(task)
