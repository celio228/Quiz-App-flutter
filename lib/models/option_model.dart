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
    print('🔄 Parsing Option: $json');
    
    // 🔥 CORRECTION: Gérer le fait que is_correct peut être 0/1 ou true/false
    dynamic isCorrectValue = json['is_correct'] ?? json['isCorrect'] ?? false;
    bool isCorrectBool;
    
    if (isCorrectValue is bool) {
      isCorrectBool = isCorrectValue;
    } else if (isCorrectValue is int) {
      isCorrectBool = isCorrectValue == 1; // Convertir 1→true, 0→false
    } else if (isCorrectValue is String) {
      isCorrectBool = isCorrectValue == '1' || isCorrectValue.toLowerCase() == 'true';
    } else {
      isCorrectBool = false;
    }
    
    print('✅ isCorrect converti: $isCorrectValue → $isCorrectBool');

    return Option(
      id: json['id'] ?? 0,
      questionId: json['question_id'] ?? json['questionId'] ?? 0,
      optionText: json['option_text'] ?? json['optionText'] ?? 'Option sans texte',
      isCorrect: isCorrectBool, // 🔥 Utiliser la valeur convertie
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