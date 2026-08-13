import '../models/player_model.dart';
import '../models/session_model.dart';

/// Result of a scoring calculation for a single player in a turn
class PlayerScoreResult {
  final String playerId;
  final int followerDelta; // can be negative
  final int credibleDelta;
  final int violationDelta;
  final bool shadowbannedAfter;
  final bool wasHalved; // true if gain was halved due to shadowban

  const PlayerScoreResult({
    required this.playerId,
    required this.followerDelta,
    this.credibleDelta = 0,
    this.violationDelta = 0,
    required this.shadowbannedAfter,
    this.wasHalved = false,
  });
}

class TurnScoreResult {
  final List<PlayerScoreResult> results;
  final bool uploaderWasHonest;
  final EchoChoice? reactionPlayed; // the uploader's own optional bonus bet
  final bool blendIsFact;

  const TurnScoreResult({
    required this.results,
    required this.uploaderWasHonest,
    required this.reactionPlayed,
    required this.blendIsFact,
  });
}

class ScoreCalculator {
  /// Apply a follower delta to a player, respecting shadowban rules.
  /// Returns the new (followers, shadowbanned) tuple.
  static (int followers, bool shadowbanned, bool wasHalved) applyDelta(
    int currentFollowers,
    bool currentlyShadowbanned,
    int delta,
  ) {
    int actualDelta = delta;
    bool wasHalved = false;

    if (delta > 0 && currentlyShadowbanned) {
      actualDelta = delta ~/ 2;
      wasHalved = true;
    }

    int newFollowers = (currentFollowers + actualDelta).clamp(0, 600);
    bool newShadowbanned = currentlyShadowbanned;

    if (newFollowers <= 0) {
      newShadowbanned = true;
    } else if (currentlyShadowbanned && newFollowers >= 50) {
      newShadowbanned = false;
    }

    return (newFollowers, newShadowbanned, wasHalved);
  }

  /// Base score for the uploader's own claim vs the blend's actual truth.
  static const int claimHonestBonus = 10;   // Claim matched the blend
  static const int claimDishonestPenalty = -20; // Claim didn't match

  /// The uploader may ALSO stake an optional Repost/Report bonus bet on top
  /// of their claim - scored against the blend's own objective truth
  /// (turn.blendIsFact), independent of whether their claim was honest.
  /// Not betting scores 0, no risk.
  static const int repostFactBonus = 15;   // Repost a real blend: correct amplification
  static const int repostHoaxPenalty = -20; // Repost a fake blend: spread misinformation
  static const int reportHoaxBonus = 30;    // Report a fake blend: correct catch
  static const int reportFactPenalty = -30; // Report a real blend: wrongly censored truth

  /// Calculate all score changes for a completed turn.
  ///
  /// Only the current uploader scores each turn - everyone else stays at 0
  /// until it's their turn. Two independent components, both theirs:
  /// 1. Base claim: +10/kartu if it matched the blend, -20/kartu if not.
  /// 2. Optional Repost/Report bonus bet (see constants above).
  static TurnScoreResult calculate(
    GameSession session,
    TurnState turn,
  ) {
    final uploader = session.currentUploader;
    const cardCount = kCardsPerTurn;
    final isHonest = turn.uploaderIsHonest;
    final blendIsFact = turn.blendIsFact;
    final reaction = turn.uploaderReaction;

    final Map<String, int> deltas = {};
    final Map<String, int> credibleDeltas = {};
    final Map<String, int> violationDeltas = {};

    // Initialize all players to 0
    for (final p in session.players) {
      deltas[p.id] = 0;
    }

    // --- Uploader's base score: claim vs blend truth ---
    int uploaderDelta =
        (isHonest ? claimHonestBonus : claimDishonestPenalty) * cardCount;

    // --- Uploader's optional Repost/Report bonus bet vs blend truth ---
    if (reaction == EchoChoice.repost) {
      uploaderDelta += blendIsFact ? repostFactBonus : repostHoaxPenalty;
    } else if (reaction == EchoChoice.report) {
      uploaderDelta += blendIsFact ? reportFactPenalty : reportHoaxBonus;
    }

    deltas[uploader.id] = uploaderDelta;

    // Update Jejak Digital for Uploader
    if (isHonest) {
      credibleDeltas[uploader.id] = cardCount;
    } else {
      violationDeltas[uploader.id] = cardCount;
    }

    // Apply all deltas with shadowban logic
    final List<PlayerScoreResult> results = [];
    for (final player in session.players) {
      final delta = deltas[player.id] ?? 0;
      final (newFollowers, newShadowbanned, wasHalved) = applyDelta(
        player.followers,
        player.shadowbanned,
        delta,
      );
      final actualDelta = newFollowers - player.followers;

      results.add(PlayerScoreResult(
        playerId: player.id,
        followerDelta: actualDelta,
        credibleDelta: credibleDeltas[player.id] ?? 0,
        violationDelta: violationDeltas[player.id] ?? 0,
        shadowbannedAfter: newShadowbanned,
        wasHalved: wasHalved,
      ));
    }

    return TurnScoreResult(
      results: results,
      uploaderWasHonest: isHonest,
      reactionPlayed: reaction,
      blendIsFact: blendIsFact,
    );
  }

  /// Determine the winner(s), by whichever metric the mode defines:
  /// - Classic: highest Jejak Digital Jujur (credibleCount) - the race to
  ///   kClassicWinThreshold.
  /// - Handless: highest Followers - the deck ran out, most poin wins.
  static List<Player> getWinners(List<Player> players, [GameMode mode = GameMode.classic]) {
    if (mode == GameMode.handless) {
      final maxFollowers =
          players.map((p) => p.followers).reduce((a, b) => a > b ? a : b);
      return players.where((p) => p.followers == maxFollowers).toList();
    }
    final maxCredible = players
        .map((p) => p.credibleCount)
        .reduce((a, b) => a > b ? a : b);
    return players.where((p) => p.credibleCount == maxCredible).toList();
  }

  /// Sort players by followers descending
  static List<Player> sortByFollowers(List<Player> players) {
    final sorted = List<Player>.from(players);
    sorted.sort((a, b) => b.followers.compareTo(a.followers));
    return sorted;
  }
}
