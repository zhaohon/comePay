class CreateWalletResponseModel {
  final String apiName;
  final int code;
  final CreateWalletData data;
  final String date;
  final String message;
  final String version;

  CreateWalletResponseModel({
    required this.apiName,
    required this.code,
    required this.data,
    required this.date,
    required this.message,
    required this.version,
  });

  factory CreateWalletResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateWalletResponseModel(
      apiName: json['api-name'] ?? '',
      code: json['code'] ?? 0,
      data: CreateWalletData.fromJson(json['data'] ?? {}),
      date: json['date'] ?? '',
      message: json['message'] ?? '',
      version: json['version'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'api-name': apiName,
      'code': code,
      'data': data.toJson(),
      'date': date,
      'message': message,
      'version': version,
    };
  }
}

class CreateWalletData {
  final bool ok;
  final String tenantId;
  final List<Wallet> wallets;

  CreateWalletData({
    required this.ok,
    required this.tenantId,
    required this.wallets,
  });

  factory CreateWalletData.fromJson(Map<String, dynamic> json) {
    return CreateWalletData(
      ok: json['ok'] ?? false,
      tenantId: json['tenant_id'] ?? '',
      wallets: (json['wallets'] as List<dynamic>?)
              ?.map((wallet) => Wallet.fromJson(wallet))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ok': ok,
      'tenant_id': tenantId,
      'wallets': wallets.map((wallet) => wallet.toJson()).toList(),
    };
  }
}

class Wallet {
  final String id;
  final String chain;
  final String label;
  final String custody;
  final String firstAddress;
  final Map<String, dynamic>? tokenAddresses;
  final Map<String, dynamic>? firstAddressBalances;
  final String? mnemonicOnce;

  Wallet({
    required this.id,
    required this.chain,
    required this.label,
    required this.custody,
    required this.firstAddress,
    this.tokenAddresses,
    this.firstAddressBalances,
    this.mnemonicOnce,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] ?? '',
      chain: json['chain'] ?? '',
      label: json['label'] ?? '',
      custody: json['custody'] ?? '',
      firstAddress: json['first_address'] ?? '',
      tokenAddresses: json['token_addresses'],
      firstAddressBalances: json['first_address_balances'],
      mnemonicOnce: json['mnemonic_once'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chain': chain,
      'label': label,
      'custody': custody,
      'first_address': firstAddress,
      'token_addresses': tokenAddresses,
      'first_address_balances': firstAddressBalances,
      'mnemonic_once': mnemonicOnce,
    };
  }
}
