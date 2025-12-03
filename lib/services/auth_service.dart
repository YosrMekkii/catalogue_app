import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

class AuthService {
  final Box _usersBox = Hive.box('usersBox');

  // Inscription
  Future<bool> signup(User user) async {
    try {
      final userKey = 'user_${user.email}';
      
      // Vérifier si l'utilisateur existe déjà
      if (_usersBox.containsKey(userKey)) {
        return false;
      }

      // Sauvegarder l'utilisateur
      await _usersBox.put(userKey, user.toMap());
      return true;
    } catch (e) {
      print('Erreur signup: $e');
      return false;
    }
  }

  // Connexion
  Future<User?> login(String email, String password) async {
    try {
      final userKey = 'user_$email';
      final userData = _usersBox.get(userKey);

      if (userData == null) {
        return null; // Utilisateur n'existe pas
      }

      final Map<String, dynamic> userMap = Map<String, dynamic>.from(userData);
      final user = User.fromMap(userMap);

      if (user.password == password) {
        // Sauvegarder l'utilisateur connecté
        await _usersBox.put('currentUser', email);
        return user;
      }
      return null; // Mot de passe incorrect
    } catch (e) {
      print('Erreur login: $e');
      return null;
    }
  }

  // Obtenir l'utilisateur actuel
  User? getCurrentUser() {
    try {
      final currentEmail = _usersBox.get('currentUser');
      if (currentEmail == null) return null;

      final userKey = 'user_$currentEmail';
      final userData = _usersBox.get(userKey);
      if (userData == null) return null;

      final Map<String, dynamic> userMap = Map<String, dynamic>.from(userData);
      return User.fromMap(userMap);
    } catch (e) {
      print('Erreur getCurrentUser: $e');
      return null;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _usersBox.delete('currentUser');
  }

  // Mettre à jour le profil
  Future<bool> updateProfile(User user) async {
    try {
      final userKey = 'user_${user.email}';
      await _usersBox.put(userKey, user.toMap());
      return true;
    } catch (e) {
      print('Erreur updateProfile: $e');
      return false;
    }
  }
}