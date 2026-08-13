import 'package:flutter_test/flutter_test.dart';
import 'package:verifact/models/card_model.dart';
import 'package:verifact/models/player_model.dart';
import 'package:verifact/models/session_model.dart';
import 'package:verifact/services/score_calculator.dart';

void main() {
  group('ScoreCalculator - Repost/Report Rules', () {
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

    test('Uploader jujur (klaim Hoaks, kartu Hoaks), 0 report, 0 repost -> Uploader +10', () {
      const turn = TurnState(
        uploaderClaim: UploaderClaim.hoax,
        cardCount: 1,
        scannedCards: [hoaxCard],
        echoChoices: {},
      );
      final result = ScoreCalculator.calculate(session, turn);
      final uploaderResult = result.results.firstWhere((r) => r.playerId == 'p1');
      expect(uploaderResult.followerDelta, 10);
    });

    test('Uploader bluff (klaim Hoaks, kartu Fakta), 0 report, 0 repost -> Uploader +20', () {
      const turn = TurnState(
        uploaderClaim: UploaderClaim.hoax,
        cardCount: 1,
        scannedCards: [factCard],
        echoChoices: {},
      );
      final result = ScoreCalculator.calculate(session, turn);
      final uploaderResult = result.results.firstWhere((r) => r.playerId == 'p1');
      expect(uploaderResult.followerDelta, 20);
    });

    test('Uploader jujur, 1 report (Bob), 1 repost (Charlie) -> Uploader +20, Bob -10, Charlie +10', () {
      const turn = TurnState(
        uploaderClaim: UploaderClaim.hoax,
        cardCount: 1,
        scannedCards: [hoaxCard],
        echoChoices: {
          'p2': EchoChoice.report,
          'p3': EchoChoice.repost,
        },
      );
      final result = ScoreCalculator.calculate(session, turn);
      final uploaderResult = result.results.firstWhere((r) => r.playerId == 'p1');
      final bobResult = result.results.firstWhere((r) => r.playerId == 'p2');
      final charlieResult = result.results.firstWhere((r) => r.playerId == 'p3');

      expect(uploaderResult.followerDelta, 20);
      expect(bobResult.followerDelta, -10);
      expect(charlieResult.followerDelta, 10);
    });

    test('Uploader bohong, 1 report (Bob), 1 repost (Charlie) -> Uploader -30, Bob +10, Charlie -10', () {
      const turn = TurnState(
        uploaderClaim: UploaderClaim.hoax,
        cardCount: 1,
        scannedCards: [factCard],
        echoChoices: {
          'p2': EchoChoice.report,
          'p3': EchoChoice.repost,
        },
      );
      final result = ScoreCalculator.calculate(session, turn);
      final uploaderResult = result.results.firstWhere((r) => r.playerId == 'p1');
      final bobResult = result.results.firstWhere((r) => r.playerId == 'p2');
      final charlieResult = result.results.firstWhere((r) => r.playerId == 'p3');

      expect(uploaderResult.followerDelta, -30);
      expect(bobResult.followerDelta, 10);
      expect(charlieResult.followerDelta, -10);
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
