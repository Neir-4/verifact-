import 'card_model.dart';
import 'player_model.dart';

/// Uploader's declared claim for this turn
enum UploaderClaim { fact, hoax }

/// Echo chamber choice per player
enum EchoChoice { repost, report }

/// The phase of the current turn
enum TurnPhase {
  upload,       // Uploader setting claim & card count
  factCheck,    // 5-second timer / waiting for Fact-Check
  echoChamber,  // Other players choosing Repost/Report
  scanning,     // Scanning QR codes
  reveal,       // Showing card status & article
  scoring,      // Displaying score changes
}

/// State for one turn
class TurnState {
  final UploaderClaim? uploaderClaim;
  final int cardCount; // 1 or 2
  final String? accuserId; // null if no Fact-Check was called
  final Map<String, EchoChoice> echoChoices; // playerId → choice
  final List<GameCard> scannedCards; // results from QR scanning
  final TurnPhase phase;
  final bool factCheckCalled;

  const TurnState({
    this.uploaderClaim,
    this.cardCount = 1,
    this.accuserId,
    this.echoChoices = const {},
    this.scannedCards = const [],
    this.phase = TurnPhase.upload,
    this.factCheckCalled = false,
  });

  TurnState copyWith({
    UploaderClaim? uploaderClaim,
    int? cardCount,
    String? accuserId,
    Map<String, EchoChoice>? echoChoices,
    List<GameCard>? scannedCards,
    TurnPhase? phase,
    bool? factCheckCalled,
    bool clearAccuser = false,
  }) {
    return TurnState(
      uploaderClaim: uploaderClaim ?? this.uploaderClaim,
      cardCount: cardCount ?? this.cardCount,
      accuserId: clearAccuser ? null : (accuserId ?? this.accuserId),
      echoChoices: echoChoices ?? this.echoChoices,
      scannedCards: scannedCards ?? this.scannedCards,
      phase: phase ?? this.phase,
      factCheckCalled: factCheckCalled ?? this.factCheckCalled,
    );
  }

  /// True if all scanned cards match the uploader's claim
  bool get uploaderIsHonest {
    if (uploaderClaim == null || scannedCards.isEmpty) return false;
    return scannedCards.every((card) {
      if (uploaderClaim == UploaderClaim.fact) {
        return card.status == CardStatus.fact;
      } else {
        return card.status == CardStatus.hoax;
      }
    });
  }
}

class GameSession {
  final List<Player> players;
  final int currentUploaderIndex;
  final TurnState currentTurn;
  final bool isStarted;
  final bool isFinished;
  final int turnCount;

  const GameSession({
    required this.players,
    this.currentUploaderIndex = 0,
    this.currentTurn = const TurnState(),
    this.isStarted = false,
    this.isFinished = false,
    this.turnCount = 0,
  });

  Player get currentUploader => players[currentUploaderIndex];

  GameSession copyWith({
    List<Player>? players,
    int? currentUploaderIndex,
    TurnState? currentTurn,
    bool? isStarted,
    bool? isFinished,
    int? turnCount,
  }) {
    return GameSession(
      players: players ?? this.players,
      currentUploaderIndex: currentUploaderIndex ?? this.currentUploaderIndex,
      currentTurn: currentTurn ?? this.currentTurn,
      isStarted: isStarted ?? this.isStarted,
      isFinished: isFinished ?? this.isFinished,
      turnCount: turnCount ?? this.turnCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'players': players.map((p) => p.toJson()).toList(),
        'currentUploaderIndex': currentUploaderIndex,
        'isStarted': isStarted,
        'isFinished': isFinished,
        'turnCount': turnCount,
      };

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      players: (json['players'] as List<dynamic>)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
      currentUploaderIndex: json['currentUploaderIndex'] as int,
      isStarted: json['isStarted'] as bool,
      isFinished: json['isFinished'] as bool,
      turnCount: json['turnCount'] as int? ?? 0,
    );
  }
}
