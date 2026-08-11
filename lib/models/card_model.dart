enum CardStatus {
  fact,
  hoax,
  opinion;

  static CardStatus fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'fact':
        return CardStatus.fact;
      case 'hoax':
        return CardStatus.hoax;
      case 'opinion':
        return CardStatus.opinion;
      default:
        return CardStatus.fact;
    }
  }

  String get displayName {
    switch (this) {
      case CardStatus.fact:
        return 'FAKTA';
      case CardStatus.hoax:
        return 'HOAKS';
      case CardStatus.opinion:
        return 'OPINI';
    }
  }

  String get label {
    switch (this) {
      case CardStatus.fact:
        return 'fact';
      case CardStatus.hoax:
        return 'hoax';
      case CardStatus.opinion:
        return 'opinion';
    }
  }
}

class CardSource {
  final String label;
  final String url;

  const CardSource({required this.label, required this.url});

  factory CardSource.fromJson(Map<String, dynamic> json) {
    return CardSource(
      label: json['label'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'url': url};
}

class GameCard {
  final String id;
  final String platform;
  final String originalStatement;
  final CardStatus status;
  final String headline;
  final String articleBody;
  final List<CardSource> sources;

  const GameCard({
    required this.id,
    required this.platform,
    required this.originalStatement,
    required this.status,
    required this.headline,
    required this.articleBody,
    required this.sources,
  });

  factory GameCard.fromJson(Map<String, dynamic> json) {
    return GameCard(
      id: json['id'] as String,
      platform: json['platform'] as String,
      originalStatement: json['originalStatement'] as String,
      status: CardStatus.fromJson(json['status'] as String),
      headline: json['headline'] as String,
      articleBody: json['articleBody'] as String,
      sources: (json['sources'] as List<dynamic>)
          .map((s) => CardSource.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'platform': platform,
        'originalStatement': originalStatement,
        'status': status.label,
        'headline': headline,
        'articleBody': articleBody,
        'sources': sources.map((s) => s.toJson()).toList(),
      };
}
