import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/card_repository.dart';
import '../models/card_model.dart';

/// Loads the card database once on startup
final cardRepositoryProvider = FutureProvider<CardRepository>((ref) async {
  return CardRepository.load();
});

/// Convenient lookup: find a card by ID
final cardByIdProvider = Provider.family<GameCard?, String>((ref, id) {
  final repo = ref.watch(cardRepositoryProvider).valueOrNull;
  return repo?.findById(id);
});
