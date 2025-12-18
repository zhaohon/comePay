class WalletResponse {
  final String apiName;
  final int code;
  final WalletData data;
  final String date;
  final String message;
  final String version;

  WalletResponse({
    required this.apiName,
    required this.code,
    required this.data,
    required this.date,
    required this.message,
    required this.version,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      apiName: json['api-name'],
      code: json['code'],
      data: WalletData.fromJson(json['data']),
      date: json['date'],
      message: json['message'],
      version: json['version'],
    );
  }
}

class WalletData {
  final List<Wallet> wallets;
  final Map<String, dynamic> listAssets;
  final double totalAssets;
  final List<AvailableCurrency> availableCurrencies;
  final String defaultCurrency;

  WalletData({
    required this.wallets,
    required this.listAssets,
    required this.totalAssets,
    required this.availableCurrencies,
    required this.defaultCurrency,
  });

  factory WalletData.fromJson(dynamic json) {
    if (json is List) {
      // Handle case where data is a list of wallets
      return WalletData(
        wallets: json.map((wallet) => Wallet.fromJson(wallet)).toList(),
        listAssets: {},
        totalAssets: 0.0,
        availableCurrencies: [],
        defaultCurrency: 'USD',
      );
    } else if (json is Map<String, dynamic>) {
      // Handle case where data is a map
      return WalletData(
        wallets: (json['wallets'] as List?)
                ?.map((wallet) => Wallet.fromJson(wallet))
                .toList() ??
            [],
        listAssets: Map<String, dynamic>.from(json['list_assets'] ?? {}),
        totalAssets: (json['total_assets'] ?? 0).toDouble(),
        availableCurrencies: (json['available_currencies'] as List?)
                ?.map((currency) => AvailableCurrency.fromJson(currency))
                .toList() ??
            [],
        defaultCurrency: json['default_currency'] ?? 'USD',
      );
    } else {
      throw Exception('Invalid data format for WalletData');
    }
  }
}

class Wallet {
  final int id;
  final String idWallet;
  final int idUser;
  final String tenantId;
  final String tenantExternalId;
  final String chain;
  final String firstAddress;
  final Map<String, String?> tokenAddresses;
  final Balance? balance;
  final String createdAt;
  final String updatedAt;

  Wallet({
    required this.id,
    required this.idWallet,
    required this.idUser,
    required this.tenantId,
    required this.tenantExternalId,
    required this.chain,
    required this.firstAddress,
    required this.tokenAddresses,
    this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      idWallet: json['id_wallet'],
      idUser: json['id_user'],
      tenantId: json['tenant_id'],
      tenantExternalId: json['tenant_external_id'],
      chain: json['chain'],
      firstAddress: json['first_address'],
      tokenAddresses: Map<String, String?>.from(json['token_addresses'] ?? {}),
      balance:
          json['balance'] != null ? Balance.fromJson(json['balance']) : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Balance {
  final int id;
  final String chain;
  final String address;
  final String native;
  final Map<String, dynamic> token;
  final String tenantId;
  final String createdAt;
  final String updatedAt;

  Balance({
    required this.id,
    required this.chain,
    required this.address,
    required this.native,
    required this.token,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      id: json['id'],
      chain: json['chain'],
      address: json['address'],
      native: json['native'],
      token: json['token'] ?? {},
      tenantId: json['tenant_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class AvailableCurrency {
  final int id;
  final String chain;
  final String address;
  final String native;
  final Map<String, dynamic> token;
  final String tenantId;
  final String createdAt;
  final String updatedAt;

  AvailableCurrency({
    required this.id,
    required this.chain,
    required this.address,
    required this.native,
    required this.token,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AvailableCurrency.fromJson(Map<String, dynamic> json) {
    return AvailableCurrency(
      id: json['id'],
      chain: json['chain'],
      address: json['address'],
      native: json['native'],
      token: json['token'] ?? {},
      tenantId: json['tenant_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
