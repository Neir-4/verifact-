class Player {
  final String id;
  String name;
  int followers; // clamped 0–600, starts at 200
  bool shadowbanned; // true when followers hit 0, auto-clears at >=50
  int credibleCount; // Jejak Digital: honest cards
  int violationCount; // Jejak Digital: dishonest cards

  Player({
    required this.id,
    required this.name,
    this.followers = 200,
    this.shadowbanned = false,
    this.credibleCount = 0,
    this.violationCount = 0,
  });

  Player copyWith({
    String? name,
    int? followers,
    bool? shadowbanned,
    int? credibleCount,
    int? violationCount,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      followers: followers ?? this.followers,
      shadowbanned: shadowbanned ?? this.shadowbanned,
      credibleCount: credibleCount ?? this.credibleCount,
      violationCount: violationCount ?? this.violationCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'followers': followers,
        'shadowbanned': shadowbanned,
        'credibleCount': credibleCount,
        'violationCount': violationCount,
      };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      followers: json['followers'] as int,
      shadowbanned: json['shadowbanned'] as bool,
      credibleCount: json['credibleCount'] as int,
      violationCount: json['violationCount'] as int,
    );
  }

  /// Jejak Digital: which side dominates
  bool get isCredible => credibleCount >= violationCount;

  /// Total cards in Jejak Digital
  int get totalCards => credibleCount + violationCount;
}
