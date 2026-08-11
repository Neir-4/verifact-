import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/card_model.dart';

class CardRepository {
  final Map<String, GameCard> _cards;

  CardRepository(this._cards);

  static Future<CardRepository> load() async {
    final jsonStr = await rootBundle.loadString('assets/cards.json');
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    final cards = <String, GameCard>{};
    for (final item in list) {
      final card = GameCard.fromJson(item as Map<String, dynamic>);
      cards[card.id] = card;
    }
    return CardRepository(cards);
  }

  GameCard? findById(String id) => _cards[id];

  List<GameCard> get allCards => _cards.values.toList();

  int get count => _cards.length;
}
