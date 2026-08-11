import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/session_model.dart';
import '../models/player_model.dart';
import '../models/card_model.dart';
import '../services/persistence_service.dart';
import '../services/score_calculator.dart';

const _uuid = Uuid();

class SessionNotifier extends StateNotifier<GameSession> {
  PersistenceService? _persistence;

  SessionNotifier() : super(const GameSession(players: []));

  void init(PersistenceService persistence) {
    _persistence = persistence;
    final saved = persistence.loadSession();
    if (saved != null) {
      state = saved;
    }
  }

  // ─── Setup ───────────────────────────────────────────────────────────────

  void startNewSession(List<String> playerNames) {
    final players = playerNames
        .map((name) => Player(id: _uuid.v4(), name: name, followers: 200))
        .toList();
    state = GameSession(
      players: players,
      isStarted: true,
      currentTurn: const TurnState(),
    );
    _save();
  }

  // ─── Upload Phase ────────────────────────────────────────────────────────

  void setUploaderClaim(UploaderClaim claim) {
    state = state.copyWith(
      currentTurn: state.currentTurn.copyWith(uploaderClaim: claim),
    );
  }

  void setCardCount(int count) {
    state = state.copyWith(
      currentTurn: state.currentTurn.copyWith(cardCount: count.clamp(1, 2)),
    );
  }

  void advanceToFactCheck() {
    state = state.copyWith(
      currentTurn: state.currentTurn.copyWith(phase: TurnPhase.factCheck),
    );
  }

  // ─── Fact-Check Phase ────────────────────────────────────────────────────

  void callFactCheck(String accuserId) {
    state = state.copyWith(
      currentTurn: state.currentTurn.copyWith(
        accuserId: accuserId,
        factCheckCalled: true,
        phase: TurnPhase.echoChamber,
      ),
    );
  }

  void skipFactCheck() {
    state = state.copyWith(
      currentTurn: state.currentTurn.copyWith(
        factCheckCalled: false,
        phase: TurnPhase.scanning,
      ),
    );
  }

  // ─── Echo Chamber Phase ──────────────────────────────────────────────────

  void setEchoChoice(String playerId, EchoChoice choice) {
    final updated =
        Map<String, EchoChoice>.from(state.currentTurn.echoChoices);
    updated[playerId] = choice;
    state = state.copyWith(
      currentTurn: state.currentTurn.copyWith(echoChoices: updated),
    );
  }

  void removeEchoChoice(String playerId) {
    final updated =
        Map<String, EchoChoice>.from(state.currentTurn.echoChoices);
    updated.remove(playerId);
    state = state.copyWith(
      currentTurn: state.currentTurn.copyWith(echoChoices: updated),
    );
  }

  void advanceToScanning() {
    state = state.copyWith(
      currentTurn: state.currentTurn.copyWith(phase: TurnPhase.scanning),
    );
  }

  // ─── Scan Phase ──────────────────────────────────────────────────────────

  void addScannedCard(GameCard card) {
    if (state.currentTurn.scannedCards.any((c) => c.id == card.id)) return;
    final updated = [...state.currentTurn.scannedCards, card];
    state = state.copyWith(
      currentTurn: state.currentTurn.copyWith(scannedCards: updated),
    );
  }

  void advanceToReveal() {
    state = state.copyWith(
      currentTurn: state.currentTurn.copyWith(phase: TurnPhase.reveal),
    );
  }

  // ─── Scoring Phase ───────────────────────────────────────────────────────

  void advanceToScoring() {
    state = state.copyWith(
      currentTurn: state.currentTurn.copyWith(phase: TurnPhase.scoring),
    );
  }

  TurnScoreResult computeScores() {
    return ScoreCalculator.calculate(state, state.currentTurn);
  }

  void applyScoresAndNextTurn(TurnScoreResult result) {
    final updatedPlayers = List<Player>.from(state.players);

    for (final scoreResult in result.results) {
      final idx =
          updatedPlayers.indexWhere((p) => p.id == scoreResult.playerId);
      if (idx == -1) continue;
      final player = updatedPlayers[idx];
      final newFollowers =
          (player.followers + scoreResult.followerDelta).clamp(0, 600);
      updatedPlayers[idx] = player.copyWith(
        followers: newFollowers,
        shadowbanned: scoreResult.shadowbannedAfter,
        credibleCount: player.credibleCount + scoreResult.credibleDelta,
        violationCount: player.violationCount + scoreResult.violationDelta,
      );
    }

    final nextUploaderIndex =
        (state.currentUploaderIndex + 1) % state.players.length;

    state = state.copyWith(
      players: updatedPlayers,
      currentUploaderIndex: nextUploaderIndex,
      currentTurn: const TurnState(),
      turnCount: state.turnCount + 1,
    );
    _save();
  }

  // ─── End Game ────────────────────────────────────────────────────────────

  void endGame() {
    state = state.copyWith(isFinished: true);
    _save();
  }

  void newGame() {
    state = const GameSession(players: []);
    _persistence?.clearSession();
  }

  void _save() {
    _persistence?.saveSession(state);
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, GameSession>((ref) {
  return SessionNotifier();
});
