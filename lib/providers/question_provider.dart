import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/question_model.dart';

class QuestionProvider with ChangeNotifier {
  final Map<int, List<Question>> _questionsByTheme = {};
  bool _isLoading = false;
  String? _error;

  Map<int, List<Question>> get questionsByTheme => _questionsByTheme;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<List<Question>> loadQuestions(int themeId, String token) async {
    if (_questionsByTheme.containsKey(themeId)) {
      return _questionsByTheme[themeId]!;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 Chargement des questions pour le thème $themeId');
      final questions = await ApiService.getQuestions(themeId, token);
      
      _questionsByTheme[themeId] = questions;
      _isLoading = false;
      
      print('✅ ${questions.length} questions chargées pour le thème $themeId');
      notifyListeners();
      return questions;
    } catch (error) {
      _error = 'Erreur lors du chargement des questions: $error';
      _isLoading = false;
      print('❌ Erreur QuestionProvider: $error');
      notifyListeners();
      return [];
    }
  }

  List<Question>? getQuestionsForTheme(int themeId) {
    return _questionsByTheme[themeId];
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}