import 'package:flutter_test/flutter_test.dart';
import 'package:verifact/models/card_model.dart';
import 'package:verifact/models/player_model.dart';
import 'package:verifact/models/session_model.dart';
import 'package:verifact/services/score_calculator.dart';

void main() {
  group('ScoreCalculator - Claim + optional Repost/Report bonus bet', () {
    final players = [
      Player(id: 'p1', name: 'Alice', followers: 200),
      Player(id: 'p2', name: 'Bob', followers: 200),
      Player(id: 'p3', name: 'Charlie', followers: 200),
    ];

    final session = GameSession(
      players: players,
      currentUploaderIndex: 0, // Alice is uploader
      isStarted: true,
    );

    const hoaxCard = GameCard(
      id: 'S01',
      platform: 'test',
      originalStatement: 'test',
      status: CardStatus.hoax,
      headline: 'test',
      articleBody: 'test',
      sources: [],
    );

    const factCard = GameCard(
      id: 'S02',
      platform: 'test',
      originalStatement: 'test',
      status: CardStatus.fact,
      headline: 'test',
      articleBody: 'test',
      sources: [],
    );

    // Every turn scans exactly kCardsPerTurn (2) cards now.
    final hoaxBlend = [hoaxCard, hoaxCard];
    final factBlend = [factCard, factCard];

    test('Klaim jujur (Hoaks, racikan Hoaks), tanpa taruhan -> +10/kartu, tidak ada delta untuk pemain lain', () {
      final turn = TurnState(
        uploaderClaim: UploaderClaim.hoax,
        scannedCards: hoaxBlend,
      );
      final result = ScoreCalculator.calculate(session, turn);
      final alice = result.results.firstWhere((r) => r.playerId == 'p1');
      final bob = result.results.firstWhere((r) => r.playerId == 'p2');

      expect(alice.followerDelta, ScoreCalculator.claimHonestBonus * kCardsPerTurn);
      expect(bob.followerDelta, 0);
    });

    test('Klaim bohong (Hoaks, racikan ternyata Fakta), tanpa taruhan -> -20/kartu', () {
      final turn = TurnState(
        uploaderClaim: UploaderClaim.hoax,
        scannedCards: factBlend,
      );
      final result = ScoreCalculator.calculate(session, turn);
      final alice = result.results.firstWhere((r) => r.playerId == 'p1');

      expect(alice.followerDelta, ScoreCalculator.claimDishonestPenalty * kCardsPerTurn);
    });

    test('Taruhan Repost BENAR (racikan Fakta) -> bonus ditambahkan ke skor klaim', () {
      final turn = TurnState(
        uploaderClaim: UploaderClaim.fact,
        uploaderReaction: EchoChoice.repost,
        scannedCards: factBlend,
      );
      final result = ScoreCalculator.calculate(session, turn);
      final alice = result.results.firstWhere((r) => r.playerId == 'p1');

      const expected = ScoreCalculator.claimHonestBonus * kCardsPerTurn +
          ScoreCalculator.repostFactBonus;
      expect(alice.followerDelta, expected);
    });

    test('Taruhan Repost SALAH (racikan Hoaks) -> penalti dikurangkan dari skor klaim', () {
      final turn = TurnState(
        uploaderClaim: UploaderClaim.fact,
        uploaderReaction: EchoChoice.repost,
        scannedCards: hoaxBlend,
      );
      final result = ScoreCalculator.calculate(session, turn);
      final alice = result.results.firstWhere((r) => r.playerId == 'p1');

      const expected = ScoreCalculator.claimDishonestPenalty * kCardsPerTurn +
          ScoreCalculator.repostHoaxPenalty;
      expect(alice.followerDelta, expected);
    });

    test('Taruhan Report BENAR (racikan Hoaks) -> bonus besar', () {
      final turn = TurnState(
        uploaderClaim: UploaderClaim.hoax,
        uploaderReaction: EchoChoice.report,
        scannedCards: hoaxBlend,
      );
      final result = ScoreCalculator.calculate(session, turn);
      final alice = result.results.firstWhere((r) => r.playerId == 'p1');

      const expected = ScoreCalculator.claimHonestBonus * kCardsPerTurn +
          ScoreCalculator.reportHoaxBonus;
      expect(alice.followerDelta, expected);
    });

    test('Taruhan Report SALAH (racikan Fakta) -> penalti besar', () {
      final turn = TurnState(
        uploaderClaim: UploaderClaim.hoax,
        uploaderReaction: EchoChoice.report,
        scannedCards: factBlend,
      );
      final result = ScoreCalculator.calculate(session, turn);
      final alice = result.results.firstWhere((r) => r.playerId == 'p1');

      const expected = ScoreCalculator.claimDishonestPenalty * kCardsPerTurn +
          ScoreCalculator.reportFactPenalty;
      expect(alice.followerDelta, expected);
    });
  });

  group('Shadowban logic', () {
    test('No halving when followers > 0', () {
      final (newF, sb, halved) = ScoreCalculator.applyDelta(100, false, 50);
      expect(newF, 150);
      expect(sb, false);
      expect(halved, false);
    });

    test('Shadowbanned: gain halved', () {
      final (newF, sb, halved) = ScoreCalculator.applyDelta(0, true, 20);
      expect(newF, 10); // halved
      expect(halved, true);
    });

    test('Shadowban clears at >= 50', () {
      final (newF, sb, halved) =
          ScoreCalculator.applyDelta(30, true, 40); // 30 + 20 (halved) = 50
      expect(newF, 50);
      expect(sb, false); // cleared!
    });
  });
}
