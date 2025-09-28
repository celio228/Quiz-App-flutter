class QuizResponse {
  final int questionId;
  final int selectedOptionId;

  QuizResponse({
    required this.questionId,
    required this.selectedOptionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'option_id': selectedOptionId,
    };
  }
}

class QuizSubmission {
  final int themeId;
  final List<QuizResponse> answers;

  QuizSubmission({
    required this.themeId,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'theme_id': themeId,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}

class QuizResult {
  final int totalPointsEarned;
  final int correctAnswers;
  final int totalQuestions;
  final String message;

  QuizResult({
    required this.totalPointsEarned,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.message,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      totalPointsEarned: json['total_points_earned'],
      correctAnswers: json['correct_answers'],
      totalQuestions: json['total_questions'],
      message: json['message'],
    );
  }
}