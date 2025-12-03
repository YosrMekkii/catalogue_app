import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../catalogue/catalogue_page.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  bool _isLogin = true;
  bool _obscurePassword = false;
  
  // Contrôleurs
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  
  String _sexe = 'Homme';
  String? _photoProfilBase64;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto() async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();

    input.onChange.listen((e) async {
      final files = input.files;
      if (files!.isEmpty) return;

      final reader = html.FileReader();
      reader.readAsDataUrl(files[0]);
      reader.onLoadEnd.listen((e) {
        setState(() {
          _photoProfilBase64 = reader.result.toString().split(',')[1];
        });
      });
    });
  }

  void _authenticate() async {
    if (_formKey.currentState!.validate()) {
      if (_isLogin) {
        // CONNEXION
        final user = await _authService.login(
          _emailController.text.toLowerCase().trim(),
          _passwordController.text,
        );
        
        if (user == null) {
          _showError('Email ou mot de passe incorrect');
          return;
        }
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CataloguePage()),
        );
      } else {
        // INSCRIPTION
        final user = User(
          email: _emailController.text.toLowerCase().trim(),
          password: _passwordController.text,
          nom: _nomController.text,
          prenom: _prenomController.text,
          sexe: _sexe,
          telephone: _telephoneController.text,
          photoProfil: _photoProfilBase64,
        );
        
        final success = await _authService.signup(user);
        
        if (!success) {
          _showError('Un compte existe déjà avec cet email');
          return;
        }
        
        // Connexion automatique après inscription
        await _authService.login(user.email, user.password);
        
        _showSuccess('Compte créé avec succès !');
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CataloguePage()),
          );
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF51CF66),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD), // Bleu pastel clair
              Color(0xFFFCE4EC), // Rose pastel clair
              Color(0xFFF3E5F5), // Violet pastel clair
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: 500),
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Photo de profil (uniquement pour inscription)
                      if (!_isLogin) ...[
                        GestureDetector(
                          onTap: _pickProfilePhoto,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE8EAF6),
                              border: Border.all(color: Color(0xFF9FA8DA), width: 3),
                            ),
                            child: _photoProfilBase64 != null
                                ? ClipOval(
                                    child: Image.memory(
                                      base64Decode(_photoProfilBase64!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Color(0xFF7986CB),
                                  ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Photo de profil (optionnelle)',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 24),
                      ] else ...[
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8EAF6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopping_bag_rounded,
                            size: 60,
                            color: Color(0xFF7986CB),
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                      
                      Text(
                        _isLogin ? 'Bienvenue !' : 'Créer un compte',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF424242),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _isLogin
                            ? 'Connectez-vous pour accéder à votre catalogue'
                            : 'Remplissez vos informations',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),
                      
                      // Champs inscription
                      if (!_isLogin) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nomController,
                                decoration: InputDecoration(
                                  labelText: 'Nom',
                                  labelStyle: TextStyle(color: Color(0xFF7986CB)),
                                  prefixIcon: Icon(Icons.person, color: Color(0xFF7986CB)),
                                  filled: true,
                                  fillColor: Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Color(0xFF7986CB), width: 2),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Requis';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _prenomController,
                                decoration: InputDecoration(
                                  labelText: 'Prénom',
                                  labelStyle: TextStyle(color: Color(0xFF7986CB)),
                                  prefixIcon: Icon(Icons.person_outline, color: Color(0xFF7986CB)),
                                  filled: true,
                                  fillColor: Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Color(0xFF7986CB), width: 2),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Requis';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _sexe,
                          decoration: InputDecoration(
                            labelText: 'Sexe',
                            labelStyle: TextStyle(color: Color(0xFF7986CB)),
                            prefixIcon: Icon(Icons.wc, color: Color(0xFF7986CB)),
                            filled: true,
                            fillColor: Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: ['Homme', 'Femme', 'Autre'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _sexe = value!;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _telephoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Téléphone',
                            labelStyle: TextStyle(color: Color(0xFF7986CB)),
                            prefixIcon: Icon(Icons.phone, color: Color(0xFF7986CB)),
                            filled: true,
                            fillColor: Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF7986CB), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre téléphone';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                      ],
                      
                      // Email et mot de passe
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Color(0xFF7986CB)),
                          prefixIcon: Icon(Icons.email_rounded, color: Color(0xFF7986CB)),
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF7986CB), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!value.contains('@')) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          labelStyle: TextStyle(color: Color(0xFF7986CB)),
                          prefixIcon: Icon(Icons.lock_rounded, color: Color(0xFF7986CB)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Color(0xFF7986CB),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF7986CB), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Minimum 6 caractères';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      
                      // Bouton
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _authenticate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF7986CB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _isLogin ? 'Se connecter' : 'S\'inscrire',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Toggle connexion/inscription
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin
                              ? 'Pas de compte ? Inscrivez-vous'
                              : 'Déjà un compte ? Connectez-vous',
                          style: TextStyle(color: Color(0xFF7986CB), fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}