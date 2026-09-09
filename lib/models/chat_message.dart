enum GibbsPhase {
  description,
  feelings,
  evaluation,
  analysis,
  conclusion,
  actionPlan,
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final GibbsPhase? estimatedPhase;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.estimatedPhase,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'estimatedPhase': estimatedPhase?.name,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] ?? '',
    text: json['text'] ?? '',
    isUser: json['isUser'] ?? false,
    timestamp: json['timestamp'] != null
        ? DateTime.parse(json['timestamp'])
        : DateTime.now(),
    estimatedPhase: json['estimatedPhase'] != null
        ? GibbsPhase.values.firstWhere(
            (e) => e.name == json['estimatedPhase'],
            orElse: () => GibbsPhase.description,
          )
        : null,
  );
}
