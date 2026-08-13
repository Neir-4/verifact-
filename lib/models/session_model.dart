import 'card_model.dart';
import 'player_model.dart';

/// Uploader's declared claim for this turn
enum UploaderClaim { fact, hoax }

/// An optional bonus action the CURRENT turn's player may stake on top of
/// their own claim - like playing an extra Kartu Intervensi. Scored against
/// the blend's actual truth, independent of the claim itself.
enum EchoChoice { repost, report }

/// Every turn always scans exactly this many cards - card count is no
/// longer a per-turn choice.
const int kCardsPerTurn = 2;

/// Picked once before a session starts, on the mode-select step.
enum GameMode { classic, handless }

/// Classic mode ends the instant any player's Jejak Digital Jujur
/// (credibleCount) reaches this many - a race to consistent honesty.
/// Handless mode has no early exit: play until the deck runs out, then
/// whoever has the most Followers wins.
const int kClassicWinThreshold = 20;

/// The phase of the current turn
enum TurnPhase {
  upload,     // Uploader claims Fakta/Hoax + optional Repost/Report bonus,
              // all on the same page
  scanning,   // Scanning QR codes (or skipping straight to the next turn)
  reveal,     // Showing card status & article
  scoring,    // Displaying score changes
}

/// State for one turn
class TurnState {
  final UploaderClaim? uploaderClaim;
  final EchoChoice? uploaderReaction; // the uploader's own optional bonus bet
  final List<GameCard> scannedCards; // results from QR scanning
  final TurnPhase phase;

  const TurnState({
    this.uploaderClaim,
    this.uploaderReaction,
    this.scannedCards = const [],
    this.phase = TurnPhase.upload,
  });

  TurnState copyWith({
    UploaderClaim? uploaderClaim,
    EchoChoice? uploaderReaction,
    bool clearUploaderReaction = false,
    List<GameCard>? scannedCards,
    TurnPhase? phase,
  }) {
    return TurnState(
      uploaderClaim: uploaderClaim ?? this.uploaderClaim,
      uploaderReaction: clearUploaderReaction
          ? null
          : (uploaderReaction ?? this.uploaderReaction),
      scannedCards: scannedCards ?? this.scannedCards,
      phase: phase ?? this.phase,
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

  /// The blend's own objective truth, independent of what the uploader
  /// claimed: true only if every scanned card is genuinely Fakta. One
  /// Hoax (or Opini) card taints the whole blend to Hoax.
  bool get blendIsFact {
    if (scannedCards.isEmpty) return false;
    return scannedCards.every((card) => card.status == CardStatus.fact);
  }
}

class GameSession {
  final List<Player> players;
  final int currentUploaderIndex;
  final TurnState currentTurn;
  final bool isStarted;
  final bool isFinished;
  final int turnCount;
  final GameMode gameMode;

  const GameSession({
    required this.players,
    this.currentUploaderIndex = 0,
    this.currentTurn = const TurnState(),
    this.isStarted = false,
    this.isFinished = false,
    this.turnCount = 0,
    this.gameMode = GameMode.classic,
  });

  Player get currentUploader => players[currentUploaderIndex];

  /// True if a game was started but not yet finished - safe to resume.
  bool get isResumable => isStarted && !isFinished;

  GameSession copyWith({
    List<Player>? players,
    int? currentUploaderIndex,
    TurnState? currentTurn,
    bool? isStarted,
    bool? isFinished,
    int? turnCount,
    GameMode? gameMode,
  }) {
    return GameSession(
      players: players ?? this.players,
      currentUploaderIndex: currentUploaderIndex ?? this.currentUploaderIndex,
      currentTurn: currentTurn ?? this.currentTurn,
      isStarted: isStarted ?? this.isStarted,
      isFinished: isFinished ?? this.isFinished,
      turnCount: turnCount ?? this.turnCount,
      gameMode: gameMode ?? this.gameMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'players': players.map((p) => p.toJson()).toList(),
        'currentUploaderIndex': currentUploaderIndex,
        'isStarted': isStarted,
        'isFinished': isFinished,
        'turnCount': turnCount,
        'gameMode': gameMode.name,
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
      gameMode: GameMode.values.firstWhere(
        (m) => m.name == json['gameMode'],
        orElse: () => GameMode.classic,
      ),
    );
  }
}
