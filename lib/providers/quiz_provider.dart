import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../services/api_service.dart';
import '../models/phase_model.dart';
import '../models/theme_model.dart';
import '../models/quiz_response_model.dart';

class QuizProvider with ChangeNotifier {
  List<Phase> _phases = [];
  Map<int, List<Theme>> _themes = {};
  Map<int, List<Question>> _questions = {};
  bool _isLoading = false;
  String? _error;

  List<Phase> get phases => _phases;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Dans quiz_provider.dart - ajoutez cette méthode
void clearPhases() {
  _phases.clear();
  _themes.clear();
  _questions.clear();
  notifyListeners();
}

// Et modifiez loadPhases pour éviter les doublons
Future<void> loadPhases(String token) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final newPhases = await ApiService.getPhases(token);
    
    // Éviter les doublons basés sur l'ID
    final existingIds = _phases.map((p) => p.id).toSet();
    final uniquePhases = newPhases.where((phase) => !existingIds.contains(phase.id)).toList();
    
    _phases.addAll(uniquePhases);
    
    // Trier par ordre
    _phases.sort((a, b) => a.order.compareTo(b.order));
    
    _isLoading = false;
    notifyListeners();
  } catch (error) {
    _error = 'Erreur lors du chargement des phases: $error';
    _isLoading = false;
    notifyListeners();
  }
}

  Future<List<Theme>> loadThemes(int phaseId, String token) async {
    if (_themes.containsKey(phaseId)) {
      return _themes[phaseId]!;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final themes = await ApiService.getThemes(phaseId, token);
      _themes[phaseId] = themes;
      _isLoading = false;
      notifyListeners();
      return themes;
    } catch (error) {
      _error = 'Erreur lors du chargement des thèmes: $error';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<List<Question>> loadQuestions(int themeId, String token) async {
    if (_questions.containsKey(themeId)) {
      return _questions[themeId]!;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final questions = await ApiService.getQuestions(themeId, token);
      _questions[themeId] = questions;
      _isLoading = false;
      notifyListeners();
      return questions;
    } catch (error) {
      _error = 'Erreur lors du chargement des questions: $error';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<QuizResult> submitAnswers(QuizSubmission submission, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.submitAnswers(submission, token);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      throw error;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}