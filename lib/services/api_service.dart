import 'dart:convert';
import 'package:dio/dio.dart';

import '../models/phase_model.dart';
import '../models/theme_model.dart';
import '../models/question_model.dart';
import '../models/quiz_response_model.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: 'http://127.0.0.1:8000/api'),
  );

  static void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Authentication
  static Future<Response> login(String email) async {
    return await _dio.post('/auth/login', data: {'email': email});
  }

  static Future<Response> register(String email, String name) async {
    return await _dio.post('/auth/register', data: {'email': email, 'name': name});
  }

  static Future<Response> updateProfile(
    String name,
    String email,
    String token,
  ) async {
    setToken(token);
    return await _dio.put('/auth/profile', data: {'name': name, 'email': email});
  }

  static Future<Response> logout(String token) async {
    setToken(token);
    return await _dio.post('/auth/logout');
  }

  // Phases
  // Phases
static Future<List<Phase>> getPhases(String token) async {
  setToken(token);
  final response = await _dio.get('/phases');
  List<dynamic> data = response.data;
  
  // Debug utile
  print('Réponse API Phases: ${data.length} éléments');
  
  return data.map((json) => Phase.fromJson(json)).toList();
}
  // Themes
  // Dans lib/services/api_service.dart
static Future<List<Theme>> getThemes(int phaseId, String token) async {
  setToken(token);
  
  print('🎯 === DEBUT GETTHEMES ===');
  print('📡 URL: /phases/$phaseId/themes');

  try {
    final response = await _dio.get('/phases/$phaseId/themes');
    
    print('✅ Statut HTTP: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      print('📊 Nombre de thèmes reçus: ${data.length}');
      
      // Parsing simplifié sans les questions
      List<Theme> themes = [];
      for (var item in data) {
        try {
          // Créer un thème sans les questions pour éviter les erreurs
          Map<String, dynamic> cleanItem = {
            'id': item['id'],
            'phase_id': item['phase_id'],
            'name': item['name'],
            'description': item['description'],
            'order': item['order'],
            'questions': [] // 🔥 Forcer une liste vide
          };
          
          Theme theme = Theme.fromJson(cleanItem);
          themes.add(theme);
        } catch (e) {
          print('❌ Erreur parsing thème: $e');
        }
      }
      
      print('✅ Thèmes parsés avec succès: ${themes.length}');
      return themes;
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Erreur getThemes: $e');
    rethrow;
  }
}

  // Questions
  static Future<List<Question>> getQuestions(int themeId, String token) async {
    setToken(token);
    final response = await _dio.get('/themes/$themeId/questions'); // Retiré le /api en double
    List<dynamic> data = response.data;
    return data.map((json) => Question.fromJson(json)).toList();
  }

  // Submit answers
  static Future<QuizResult> submitAnswers(
    QuizSubmission submission,
    String token,
  ) async {
    setToken(token);
    final response = await _dio.post(
      '/submit-answers', // Retiré le /api en double
      data: submission.toJson(),
    );
    return QuizResult.fromJson(response.data);
  }

  // User stats
  static Future<Map<String, dynamic>> getUserStats(String token) async {
    setToken(token);
    final response = await _dio.get('/user/stats'); // Retiré le /api en double
    return response.data;
  }

  // User progress
  static Future<Response> getUserProgress(String token) async {
    setToken(token);
    return await _dio.get('/user/progress'); // Retiré le /api en double
  }

  // Reset progress
  static Future<Response> resetProgress(String token) async {
    setToken(token);
    return await _dio.post('/reset-progress'); // Retiré le /api en double
  }
}