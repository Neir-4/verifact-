import 'package:flutter_test/flutter_test.dart';
import 'package:caught/models/card_model.dart';
import 'package:caught/models/player_model.dart';
import 'package:caught/models/session_model.dart';
import 'package:caught/services/score_calculator.dart';

void main() {
  group('ScoreCalculator', () {
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

    const fakeCard = GameCard(
      id: 'S01',
      platform: 'test',
      originalStatement: 'test',
      status: CardStatus.hoax,
      headline: 'test',
      articleBody: 'test',
      sources: [],
    );

    test('Uploader lolos jujur (klaim Hoaks, kartu Hoaks) +10/kartu', () {
      const turn = TurnState(
        uploaderClaim: UploaderClaim.hoax,
        cardCount: 1,
        scannedCards: [fakeCard],
        factCheckCalled: false,
      );
      final result = ScoreCalculator.calculate(session, turn);
      final uploaderResult =
          result.results.firstWhere((r) => r.playerId == 'p1');
      expect(uploaderResult.followerDelta, 10);
    });

    test('Uploader lolos bluff (klaim Fakta, kartu Hoaks) +20/kartu', () {
      const factCard = GameCard(
        id: 'S02',
        platform: 'test',
        originalStatement: 'test',
        status: CardStatus.fact,
        headline: 'test',
        articleBody: 'test',
        sources: [],
      );
      const turn = TurnState(
        uploaderClaim: UploaderClaim.hoax,
        cardCount: 1,
        scannedCards: [factCard], // fact card, but claimed hoax → mismatch
        factCheckCalled: false,
      );
      final result = ScoreCalculator.calculate(session, turn);
      final uploaderResult =
          result.results.firstWhere((r) => r.playerId == 'p1');
      expect(uploaderResult.followerDelta, 20);
    });

    test('Ditantang, uploader jujur: Uploader +20, Penuduh -10', () {
      const turn = TurnState(
        uploaderClaim: UploaderClaim.hoax,
        cardCount: 1,
        scannedCards: [fakeCard], // matches
        factCheckCalled: true,
        accuserId: 'p2',
      );
      final result = ScoreCalculator.calculate(session, turn);
      final uploaderResult =
          result.results.firstWhere((r) => r.playerId == 'p1');
      final accuserResult =
          result.results.firstWhere((r) => r.playerId == 'p2');
      expect(uploaderResult.followerDelta, 20);
      expect(accuserResult.followerDelta, -10);
    });

    test('Ditantang, uploader tertangkap: Uploader -30, Penuduh +35', () {
      const factCard = GameCard(
        id: 'S03',
        platform: 'test',
        originalStatement: 'test',
        status: CardStatus.fact,
        headline: 'test',
        articleBody: 'test',
        sources: [],
      );
      const turn = TurnState(
        uploaderClaim: UploaderClaim.hoax,
        cardCount: 1,
        scannedCards: [factCard], // mismatch → caught
        factCheckCalled: true,
        accuserId: 'p2',
      );
      final result = ScoreCalculator.calculate(session, turn);
      final uploaderResult =
          result.results.firstWhere((r) => r.playerId == 'p1');
      final accuserResult =
          result.results.firstWhere((r) => r.playerId == 'p2');
      expect(uploaderResult.followerDelta, -30);
      expect(accuserResult.followerDelta, 35); // 30 + 5 bonus
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
