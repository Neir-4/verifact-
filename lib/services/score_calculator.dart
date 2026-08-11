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
  final bool factCheckWasCalled;

  const TurnScoreResult({
    required this.results,
    required this.uploaderWasHonest,
    required this.factCheckWasCalled,
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

  /// Calculate all score changes for a completed turn.
  ///
  /// Rules (from rulebook):
  ///
  /// UPLOADER KLAIM FAKTA:
  /// - Lolos, jujur (cocok Fakta): Uploader +10/kartu
  /// - Lolos, bohong (kartu aslinya Hoaks): Uploader +20/kartu
  /// - Ditantang, jujur: Uploader +20/kartu; Penuduh -10/kartu; Repost +10; Report -10
  /// - Ditantang, bohong: Uploader -30/kartu (dibayar ke Penuduh); Penuduh +30/kartu +5 bonus; Repost -10; Report +10
  ///
  /// UPLOADER KLAIM HOAKS: (same table, symmetric)
  /// - Lolos, jujur (cocok Hoaks): Uploader +10/kartu
  /// - Lolos, bohong: Uploader +20/kartu
  /// - Ditantang, jujur: Uploader +20/kartu; Penuduh -10/kartu; Repost +10; Report -10
  /// - Ditantang, bohong: Uploader -30/kartu → Penuduh; Penuduh +30/kartu +5 bonus; Repost -10; Report +10
  static TurnScoreResult calculate(
    GameSession session,
    TurnState turn,
  ) {
    final uploader = session.currentUploader;
    final cardCount = turn.cardCount;
    final isHonest = turn.uploaderIsHonest;
    final factCheckCalled = turn.factCheckCalled && turn.accuserId != null;

    final Map<String, int> deltas = {};
    final Map<String, int> credibleDeltas = {};
    final Map<String, int> violationDeltas = {};

    // Initialize all players to 0
    for (final p in session.players) {
      deltas[p.id] = 0;
    }

    if (!factCheckCalled) {
      // --- LOLOS (no Fact-Check) ---
      if (isHonest) {
        // +10 per card for uploader
        deltas[uploader.id] = 10 * cardCount;
      } else {
        // +20 per card for uploader (bluff succeeded)
        deltas[uploader.id] = 20 * cardCount;
      }
    } else {
      // --- DITANTANG (Fact-Check was called) ---
      final accuserId = turn.accuserId!;

      if (isHonest) {
        // Uploader was right, Penuduh was wrong
        deltas[uploader.id] = 20 * cardCount; // +20/kartu
        deltas[accuserId] = (deltas[accuserId] ?? 0) + (-10 * cardCount); // -10/kartu
        // Echo chamber
        for (final entry in turn.echoChoices.entries) {
          if (entry.key == uploader.id || entry.key == accuserId) continue;
          if (entry.value == EchoChoice.repost) {
            deltas[entry.key] = (deltas[entry.key] ?? 0) + 10; // Repost: +10
          } else {
            deltas[entry.key] = (deltas[entry.key] ?? 0) + (-10); // Report: -10
          }
        }
      } else {
        // Uploader was lying, Penuduh was right
        final uplPenalty = -30 * cardCount;
        deltas[uploader.id] = uplPenalty; // -30/kartu
        deltas[accuserId] = (deltas[accuserId] ?? 0) + (30 * cardCount + 5); // +30/kartu +5 bonus
        // Echo chamber
        for (final entry in turn.echoChoices.entries) {
          if (entry.key == uploader.id || entry.key == accuserId) continue;
          if (entry.value == EchoChoice.repost) {
            deltas[entry.key] = (deltas[entry.key] ?? 0) + (-10); // Repost: -10 (backed the liar)
          } else {
            deltas[entry.key] = (deltas[entry.key] ?? 0) + 10; // Report: +10 (backed the accuser)
          }
        }
      }
    }

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
      factCheckWasCalled: factCheckCalled,
    );
  }

  /// Determine the winner(s) by Jejak Digital (credibleCount vs violationCount)
  static List<Player> getWinners(List<Player> players) {
    int maxCredible = players
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
