import re

with open('lib/services/withdraw_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(
    "'network': network,",
    "'network': network,\n      if (transactionPassword != null) 'transaction_password': transactionPassword,"
)

with open('lib/services/withdraw_service.dart', 'w', encoding='utf-8') as f:
    f.write(content)
