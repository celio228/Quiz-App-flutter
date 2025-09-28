class Question {
  final int id;
  final int themeId;
  final String questionText;
  final String questionType;
  final int points;
  final List<Option> options;

  Question({
    required this.id,
    required this.themeId,
    required this.questionText,
    required this.questionType,
    required this.points,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      themeId: json['theme_id'] ?? json['themeId'] ?? 0,
      questionText: json['question_text'] ?? json['questionText'] ?? 'Question sans texte',
      questionType: json['question_type'] ?? json['questionType'] ?? 'multiple_choice',
      points: json['points'] ?? 0,
      options: (json['options'] as List? ?? []).map((o) => Option.fromJson(o)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'theme_id': themeId,
      'question_text': questionText,
      'question_type': questionType,
      'points': points,
      'options': options.map((o) => o.toJson()).toList(),
    };
  }
}

class Option {
  final int id;
  final int questionId;
  final String optionText;
  final bool isCorrect;

  Option({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.isCorrect,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] ?? 0,
      questionId: json['question_id'] ?? json['questionId'] ?? 0,
      optionText: json['option_text'] ?? json['optionText'] ?? 'Option sans texte',
      isCorrect: json['is_correct'] ?? json['isCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'option_text': optionText,
      'is_correct': isCorrect,
    };
  }
}