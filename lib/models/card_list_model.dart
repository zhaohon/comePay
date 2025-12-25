/// 卡片列表中的单张卡片模型
class CardListItemModel {
  final int id;
  final String publicToken;
  final String cardNo; // 脱敏卡号
  final String cardScheme; // "visa" or "mastercard"
  final String currency; // 卡片币种，如 "HKD"
  final String status; // 卡片状态，如 "active"
  final bool isPhysical; // 是否为实体卡
  final int kycId;
  final String createdAt;

  CardListItemModel({
    required this.id,
    required this.publicToken,
    required this.cardNo,
    required this.cardScheme,
    required this.currency,
    required this.status,
    required this.isPhysical,
    required this.kycId,
    required this.createdAt,
  });

  factory CardListItemModel.fromJson(Map<String, dynamic> json) {
    return CardListItemModel(
      id: json['id'] as int? ?? 0,
      publicToken: json['public_token'] as String? ?? '',
      cardNo: json['card_no'] as String? ?? '',
      cardScheme: json['card_scheme'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
      status: json['status'] as String? ?? '',
      isPhysical: json['is_physical'] as bool? ?? false,
      kycId: json['kyc_id'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

/// 卡片列表响应模型
class CardListResponseModel {
  final int total;
  final List<CardListItemModel> cards;

  CardListResponseModel({
    required this.total,
    required this.cards,
  });

  factory CardListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    final cardsData = data['cards'] as List<dynamic>? ?? [];
    final cards = cardsData
        .map((card) => CardListItemModel.fromJson(card as Map<String, dynamic>))
        .toList();

    return CardListResponseModel(
      total: data['total'] as int? ?? 0,
      cards: cards,
    );
  }

  /// 判断是否有卡片
  bool get hasCards => total > 0 && cards.isNotEmpty;
}

