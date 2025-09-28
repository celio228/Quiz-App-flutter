import 'theme_model.dart';

class Phase {
  final int id;
  final String name;
  final String description;
  final String level;
  final int pointsPerQuestion;
  final int order;
  final List<Theme> themes;

  Phase({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.pointsPerQuestion,
    required this.order,
    required this.themes,
  });

  factory Phase.fromJson(Map<String, dynamic> json) {
    var themesList = json['themes'] as List? ?? [];
    List<Theme> themes = themesList.map((i) => Theme.fromJson(i)).toList();

    return Phase(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      level: json['level'],
      pointsPerQuestion: json['points_per_question'],
      order: json['order'],
      themes: themes,
    );
  }
}