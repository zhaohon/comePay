import re

# Update arb files
for arb_path, name_zh, exp_zh, name_en, exp_en in [
    ('lib/l10n/app_zh.arb', '持卡人', '有效期', 'Name', 'Expiry Date'),
    ('lib/l10n/app_en.arb', '持卡人', '有效期', 'Name', 'Expiry Date')
]:
    with open(arb_path, 'r') as f:
        content = f.read()
    
    # insert before the last brace
    if 'cardHolderLabelText' not in content:
        insert_zh = f',"cardHolderLabelText": "{name_zh}",\n  "expiryDateLabelText": "{exp_zh}"\n}}'
        insert_en = f',"cardHolderLabelText": "{name_en}",\n  "expiryDateLabelText": "{exp_en}"\n}}'
        
        insert_str = insert_zh if 'zh' in arb_path else insert_en
        content = re.sub(r'\n\}\s*$', insert_str, content)
        with open(arb_path, 'w') as f:
            f.write(content)

# Update CardScreen.dart
with open('lib/views/homes/CardScreen.dart', 'r') as f:
    text = f.read()

old_name_section = """                        Expanded(
                          flex: 1,
                          child: (isCurrentCard && _currentCardDetails == null)
                              ? Shimmer.fromColors(
                                  baseColor: Colors.white.withOpacity(0.25),
                                  highlightColor:
                                      Colors.white.withOpacity(0.45),
                                  child: Container(
                                    height: 18,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                )
                              : Text(
                                  _currentCardDetails?.memberName ?? 'NAME',
                                  style: TextStyle(
                                    color: Colors.white, // 金属银色
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold, // 加粗一点让浮雕效果更好
                                    letterSpacing: 1.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),"""

new_name_section = """                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.cardHolderLabelText,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              (isCurrentCard && _currentCardDetails == null)
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.white.withOpacity(0.25),
                                      highlightColor: Colors.white.withOpacity(0.45),
                                      child: Container(
                                        height: 18,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      _currentCardDetails?.memberName ?? 'NAME',
                                      style: TextStyle(
                                        color: Colors.white, // 金属银色
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold, // 加粗一点让浮雕效果更好
                                        letterSpacing: 1.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ],
                          ),
                        ),"""

old_expiry_section = """                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: isCurrentCard
                                  ? () => _showCardSecurityInfo()
                                  : null,
                              child: Text(
                                '**/**',
                                style: TextStyle(
                                  color: Colors.white, // 金属银色
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),"""

new_expiry_section = """                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.expiryDateLabelText,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: isCurrentCard
                                      ? () => _showCardSecurityInfo()
                                      : null,
                                  child: Text(
                                    '**/**',
                                    style: TextStyle(
                                      color: Colors.white, // 金属银色
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),"""

def replace_with_whitespace(old, new, text_input):
    pattern = re.escape(old).replace(r'\ ', r'\s+')
    return re.sub(pattern, new, text_input)

text = replace_with_whitespace(old_name_section, new_name_section, text)
text = replace_with_whitespace(old_expiry_section, new_expiry_section, text)

# Update row alignment
text = replace_with_whitespace("crossAxisAlignment: CrossAxisAlignment.end,\n                      children: [\n                        // 姓名部分", "crossAxisAlignment: CrossAxisAlignment.start,\n                      children: [\n                        // 姓名部分", text)

with open('lib/views/homes/CardScreen.dart', 'w') as f:
    f.write(text)

