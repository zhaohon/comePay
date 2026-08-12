import re

with open('lib/views/homes/widgets/token_network_list_send.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace block 1
block1 = """                      const SizedBox(height: 4),
                      // 币种全名
                      Text(
                        balance.coinName.isNotEmpty
                            ? balance.coinName
                            : balance.symbol,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),"""
replacement1 = """                      if (balance.coinName.isNotEmpty || balance.symbol.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        // 币种全名
                        Text(
                          balance.coinName.isNotEmpty
                              ? balance.coinName
                              : balance.symbol,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],"""

content = content.replace(block1, replacement1)

# Replace block 2
block2 = """                    const SizedBox(height: 4),
                    // 币种符号
                    Text(
                      balance.symbol,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),"""
replacement2 = """                    if (balance.symbol.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      // 币种符号
                      Text(
                        balance.symbol,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],"""

content = content.replace(block2, replacement2)

with open('lib/views/homes/widgets/token_network_list_send.dart', 'w', encoding='utf-8') as f:
    f.write(content)
