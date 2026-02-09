// 新的钱包API响应模型
class WalletResponse {
  final String status;
  final WalletData wallet;

  WalletResponse({
    required this.status,
    required this.wallet,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      status: json['status'] ?? '',
      wallet: WalletData.fromJson(json['wallet']),
    );
  }
}

class WalletData {
  final int id;
  final int userId;
  final String currency;
  final String status;
  final double dailyLimit;
  final double monthlyLimit;
  final Map<String, double> balancesByCurrency; // 修改为Map类型
  final List<WalletBalance> balances;
  final double totalAssetHkd; // 新增：HKD 总资产
  final double totalAssetUsdt; // 新增：USDT 总资产
  final String createdAt;
  final String updatedAt;

  WalletData({
    required this.id,
    required this.userId,
    required this.currency,
    required this.status,
    required this.dailyLimit,
    required this.monthlyLimit,
    required this.balancesByCurrency,
    required this.balances,
    required this.totalAssetHkd,
    required this.totalAssetUsdt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    // 解析 balances_by_currency Map
    Map<String, double> balancesByCurrencyMap = {};
    if (json['balances_by_currency'] != null &&
        json['balances_by_currency'] is Map) {
      final rawMap = json['balances_by_currency'] as Map<String, dynamic>;
      rawMap.forEach((key, value) {
        balancesByCurrencyMap[key] = (value is num) ? value.toDouble() : 0.0;
      });
    }

    return WalletData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? '',
      dailyLimit: (json['daily_limit'] ?? 0).toDouble(),
      monthlyLimit: (json['monthly_limit'] ?? 0).toDouble(),
      balancesByCurrency: balancesByCurrencyMap,
      balances: (json['balances'] as List?)
              ?.map((balance) => WalletBalance.fromJson(balance))
              .toList() ??
          [],
      totalAssetHkd: (json['total_asset_hkd'] is num)
          ? (json['total_asset_hkd'] as num).toDouble()
          : 0.0,
      totalAssetUsdt: (json['total_asset_usdt'] is num)
          ? (json['total_asset_usdt'] as num).toDouble()
          : 0.0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class WalletBalance {
  final int id;
  final String currency;
  final double balance;
  final int mainCoinType;
  final String coinType;
  final String symbol;
  final int decimals;
  final int tokenStatus;
  final String mainSymbol;
  final String logo;
  final String coinName;
  final String address;
  final String createdAt;
  final String updatedAt;

  WalletBalance({
    required this.id,
    required this.currency,
    required this.balance,
    required this.mainCoinType,
    required this.coinType,
    required this.symbol,
    required this.decimals,
    required this.tokenStatus,
    required this.mainSymbol,
    required this.logo,
    required this.coinName,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      id: json['id'] ?? 0,
      currency: json['currency'] ?? '',
      balance: (json['balance'] is num)
          ? (json['balance'] as num).toDouble()
          : double.tryParse(json['balance'].toString()) ?? 0.0,
      mainCoinType: json['main_coin_type'] ?? 0,
      coinType: json['coin_type']?.toString() ?? '',
      symbol: json['symbol'] ?? '',
      decimals: json['decimals'] ?? 0,
      tokenStatus: json['token_status'] ?? 0,
      mainSymbol: json['main_symbol'] ?? '',
      logo: json['logo'] ?? '',
      coinName: json['coin_name'] ?? '',
      address: json['address'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

// 保留旧的模型以兼容其他地方可能的使用
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
