import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/theme_model.dart';

class ThemeProvider with ChangeNotifier {
  final Map<int, List<Theme>> _themesByPhase = {};
  bool _isLoading = false;
  String? _error;

  Map<int, List<Theme>> get themesByPhase => _themesByPhase;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<List<Theme>> loadThemes(int phaseId, String token) async {
    // Vérifier si les thèmes sont déjà en cache
    if (_themesByPhase.containsKey(phaseId)) {
      return _themesByPhase[phaseId]!;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 Chargement des thèmes pour la phase $phaseId');
      final themes = await ApiService.getThemes(phaseId, token);
      
      _themesByPhase[phaseId] = themes;
      _isLoading = false;
      
      print('✅ ${themes.length} thèmes chargés pour la phase $phaseId');
      notifyListeners();
      return themes;
    } catch (error) {
      _error = 'Erreur lors du chargement des thèmes: $error';
      _isLoading = false;
      print('❌ Erreur ThemeProvider: $error');
      notifyListeners();
      return [];
    }
  }

  List<Theme>? getThemesForPhase(int phaseId) {
    return _themesByPhase[phaseId];
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCache() {
    _themesByPhase.clear();
    notifyListeners();
  }
}
