import 'package:quiz_app/models/question_model.dart';

class Theme {
  final int id;
  final int phaseId;
  final String name;
  final String description;
  final int order;
  final List<Question> questions;

  Theme({
    required this.id,
    required this.phaseId,
    required this.name,
    required this.description,
    required this.order,
    required this.questions,
  });

  factory Theme.fromJson(Map<String, dynamic> json) {
    print('🔄 Parsing Theme: ${json['name']}');
    
    try {
      // 🔥 CORRECTION: Ne pas charger les questions immédiatement
      // Elles seront chargées séparément via l'API
      List<Question> questions = [];

      return Theme(
        id: json['id'] ?? 0,
        phaseId: json['phase_id'] ?? json['phaseId'] ?? 0,
        name: json['name'] ?? 'Sans nom',
        description: json['description'] ?? '',
        order: json['order'] ?? 0,
        questions: questions, // Liste vide pour l'instant
      );
    } catch (e) {
      print('❌ Erreur Theme.fromJson: $e');
      return Theme(
        id: 0,
        phaseId: 0,
        name: 'Thème invalide',
        description: 'Erreur de parsing',
        order: 0,
        questions: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phase_id': phaseId,
      'name': name,
      'description': description,
      'order': order,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

