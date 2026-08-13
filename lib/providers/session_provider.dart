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

  void startNewSession(List<String> playerNames, GameMode mode) {
    final players = playerNames
        .map((name) => Player(id: _uuid.v4(), name: name, followers: 200))
        .toList();
    state = GameSession(
      players: players,
      isStarted: true,
      currentTurn: const TurnState(),
      gameMode: mode,
    );
    _save();
  }

  // ─── Upload Phase ────────────────────────────────────────────────────────

  void setUploaderClaim(UploaderClaim claim) {
    state = state.copyWith(
      currentTurn: state.currentTurn.copyWith(uploaderClaim: claim),
    );
  }

  // ─── Optional Repost/Report bonus bet - belongs to the uploader alone,
  // staked on top of their own claim, shown on the same page ──────────────

  /// Tapping the same reaction again clears it (the bet is optional).
  void toggleUploaderReaction(EchoChoice choice) {
    if (state.currentTurn.uploaderReaction == choice) {
      state = state.copyWith(
        currentTurn:
            state.currentTurn.copyWith(clearUploaderReaction: true),
      );
    } else {
      state = state.copyWith(
        currentTurn: state.currentTurn.copyWith(uploaderReaction: choice),
      );
    }
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

  /// Bail out of this turn entirely - no scan, no reveal, no score change.
  /// Just rotates to the next player's turn.
  void skipTurn() {
    final nextUploaderIndex =
        (state.currentUploaderIndex + 1) % state.players.length;
    state = state.copyWith(
      currentUploaderIndex: nextUploaderIndex,
      currentTurn: const TurnState(),
      turnCount: state.turnCount + 1,
    );
    _save();
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

    // Classic mode ends the instant anyone reaches the Jejak Digital Jujur
    // threshold - Handless has no early exit, it plays until the deck runs
    // out and is ended manually.
    final classicWon = state.gameMode == GameMode.classic &&
        updatedPlayers.any((p) => p.credibleCount >= kClassicWinThreshold);

    state = state.copyWith(
      players: updatedPlayers,
      currentUploaderIndex: nextUploaderIndex,
      currentTurn: const TurnState(),
      turnCount: state.turnCount + 1,
      isFinished: classicWon ? true : state.isFinished,
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

/// The mode picked on the landing screen, carried over to Setup when
/// starting a new session.
final pendingGameModeProvider = StateProvider<GameMode>((ref) => GameMode.classic);
