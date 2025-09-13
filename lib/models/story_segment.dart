class Choice {
  final String text;
  final Map<String, dynamic>? effects;

  Choice({required this.text, this.effects});

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'effects': effects,
    };
  }

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      text: json['text'],
      effects: json['effects'] as Map<String, dynamic>?,
    );
  }
}

class StorySegment {
  final String text;
  final List<Choice> choices;
  final int index;

  StorySegment({
    required this.text,
    required this.choices,
    required this.index,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'choices': choices.map((c) => c.toJson()).toList(),
      'index': index,
    };
  }

  factory StorySegment.fromJson(Map<String, dynamic> json) {
    return StorySegment(
      text: json['text'],
      choices: (json['choices'] as List)
          .map((c) => Choice.fromJson(c))
          .toList(),
      index: json['index'],
    );
  }
}
