class CardFeeStatsResponseModel {
  final bool needsPaymentForNextCard;
  final bool canApplyNewCard;
  final int maxCards;
  final int successCards;
  final int pendingCards;
  final int remainingSlots;
  final int nextCardIndex;

  CardFeeStatsResponseModel({
    required this.needsPaymentForNextCard,
    required this.canApplyNewCard,
    required this.maxCards,
    required this.successCards,
    required this.pendingCards,
    required this.remainingSlots,
    required this.nextCardIndex,
  });

  factory CardFeeStatsResponseModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    return CardFeeStatsResponseModel(
      needsPaymentForNextCard: stats['needs_payment_for_next_card'] ?? true,
      canApplyNewCard: stats['can_apply_new_card'] ?? false,
      maxCards: stats['max_cards'] ?? 0,
      successCards: stats['success_cards'] ?? 0,
      pendingCards: stats['pending_cards'] ?? 0,
      remainingSlots: stats['remaining_slots'] ?? 0,
      nextCardIndex: stats['next_card_index'] ?? 0,
    );
  }
}
