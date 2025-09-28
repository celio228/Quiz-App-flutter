import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Méthode d'initialisation pour charger les données sauvegardées
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token');
      final savedUser = prefs.getString('user');
      
      if (savedToken != null && savedUser != null) {
        _token = savedToken;
        _user = User.fromJson(json.decode(savedUser));
        
        // Définir le token dans ApiService
        ApiService.setToken(_token!);
        print('Token restauré: $_token'); // Debug
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation: $e');
    }
  }

  // Sauvegarder les données dans SharedPreferences
  Future<void> _saveAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString('token', _token!);
      }
      if (_user != null) {
        await prefs.setString('user', json.encode(_user!.toJson()));
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
    }
  }

  // Supprimer les données sauvegardées
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
    } catch (e) {
      print('Erreur lors de la suppression: $e');
    }
  }

  Future<bool> login(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.login(email);
      
      if (response.statusCode == 200) {
        if (response.data['needs_registration'] == true) {
          _isLoading = false;
          notifyListeners();
          return false; // Needs registration
        } else {
          _user = User.fromJson(response.data['user']);
          _token = response.data['token'];
          
          // Définir le token dans ApiService
          ApiService.setToken(_token!);
          
          // Sauvegarder les données
          await _saveAuthData();
          
          print('Login réussi - Token: $_token'); // Debug
          _isLoading = false;
          notifyListeners();
          return true; // Login successful
        }
      } else {
        _error = 'Erreur de connexion';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _error = 'Erreur de connexion: $error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.register(email, name);
      
      if (response.statusCode == 201) {
        _user = User.fromJson(response.data['user']);
        _token = response.data['token'];
        
        // Définir le token dans ApiService
        ApiService.setToken(_token!);
        
        // Sauvegarder les données
        await _saveAuthData();
        
        print('Inscription réussie - Token: $_token'); // Debug
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Erreur d\'inscription';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _error = 'Erreur d\'inscription: $error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(String name, String email) async {
    if (_token == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.updateProfile(name, email, _token!);
      
      if (response.statusCode == 200) {
        _user = User.fromJson(response.data['user']);
        
        // Mettre à jour les données sauvegardées
        await _saveAuthData();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Erreur de mise à jour';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _error = 'Erreur de mise à jour: $error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await ApiService.logout(_token!);
      } catch (e) {
        print('Erreur lors de la déconnexion API: $e');
      }
    }
    
    // Supprimer le token de ApiService
    ApiService.clearToken();
    
    // Supprimer les données sauvegardées
    await _clearAuthData();
    
    _user = null;
    _token = null;
    _error = null;
    
    print('Déconnexion réussie'); // Debug
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Vérifier si l'utilisateur est connecté
  bool get isAuthenticated {
    return _token != null && _user != null;
  }
}