import re

with open('lib/views/homes/CardScreen.dart', 'r') as f:
    text = f.read()

# Fix spacing differences using regex to match any whitespace
def replace_with_whitespace(old, new):
    global text
    # Escaping brackets/parentheses for literal match, but replacing spaces with \s+
    pattern = re.escape(old).replace(r'\ ', r'\s+')
    text = re.sub(pattern, new, text)

# Chunk 0
replace_with_whitespace("const Center(\n                            child:\n                                Text('Failed to load card details'),\n                          )", "Center(\n                            child:\n                                Text(AppLocalizations.of(context)!.failedToLoadCardDetails),\n                          )")
# Chunk 1
replace_with_whitespace("const Text(\n                                 'Failed to load card details. Please pull down to refresh.',\n                                 textAlign: TextAlign.center,", "Text(\n                                 AppLocalizations.of(context)!.failedToLoadCardDetailsRefresh,\n                                 textAlign: TextAlign.center,")
# Chunk 2
replace_with_whitespace("const Text('Failed to load card details')", "Text(AppLocalizations.of(context)!.failedToLoadCardDetails)")
# Chunk 3
replace_with_whitespace("child:\n                                const Text('Failed to load card details'),", "child:\n                                Text(AppLocalizations.of(context)!.failedToLoadCardDetails),")
# Chunk 4
replace_with_whitespace("SnackBar(content: Text('获取卡片信息失败: $e'))", "SnackBar(content: Text('${AppLocalizations.of(context)!.failedToGetCardInfo}$e'))")
# Chunk 5
replace_with_whitespace("const Text(\n                  'Security verification',", "Text(\n                  AppLocalizations.of(context)!.securityVerification,")
# Chunk 6
replace_with_whitespace("const Text(\n                  'Choose verification method',", "Text(\n                  AppLocalizations.of(context)!.chooseVerificationMethod,")
# Chunk 7
replace_with_whitespace("child: Text(value),", "child: Text(value == 'email verification' ? AppLocalizations.of(context)!.emailVerification : value),")
# Chunk 8
replace_with_whitespace("const Text(\n                  'Verification',", "Text(\n                  AppLocalizations.of(context)!.verification,")
# Chunk 9
replace_with_whitespace("hintText: 'Enter verification code',", "hintText: AppLocalizations.of(context)!.enterVerificationCode,")
# Chunk 13
replace_with_whitespace("const Text(\n                  'Please confirm that you have received the physical card before activating it!',", "Text(\n                  AppLocalizations.of(context)!.activationConfirmTip,")
# Chunk 15
replace_with_whitespace("const Text(\n                  'Card Received, active immediately',", "Text(\n                  AppLocalizations.of(context)!.receivedActivateNow,")
# Chunk 16
replace_with_whitespace("const Text(\n                        'Card Replace/Renew',", "Text(\n                        AppLocalizations.of(context)!.cardReplaceRenew,")
# Chunk 17
replace_with_whitespace("const Text(\n                        'Report Loss',", "Text(\n                        AppLocalizations.of(context)!.reportLoss,")
# Chunk 18
replace_with_whitespace("const Text(\n                        'Reward news',", "Text(\n                        AppLocalizations.of(context)!.rewardNews,")

with open('lib/views/homes/CardScreen.dart', 'w') as f:
    f.write(text)

