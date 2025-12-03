import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../../models/user.dart';
import '../../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  
  String _sexe = 'Homme';
  String? _photoProfilBase64;
  bool _isEditing = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    final user = _authService.getCurrentUser()!;
    
    _nomController = TextEditingController(text: user.nom);
    _prenomController = TextEditingController(text: user.prenom);
    _emailController = TextEditingController(text: user.email);
    _telephoneController = TextEditingController(text: user.telephone);
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _sexe = user.sexe;
    _photoProfilBase64 = user.photoProfil;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
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

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = _authService.getCurrentUser()!;
      
      String password = currentUser.password;
      
      // Si changement de mot de passe
      if (_isChangingPassword) {
        if (_oldPasswordController.text != currentUser.password) {
          _showError('Ancien mot de passe incorrect');
          return;
        }
        password = _newPasswordController.text;
      }
      
      final updatedUser = User(
        email: _emailController.text,
        password: password,
        nom: _nomController.text,
        prenom: _prenomController.text,
        sexe: _sexe,
        telephone: _telephoneController.text,
        photoProfil: _photoProfilBase64,
      );
      
      final success = await _authService.updateProfile(updatedUser);
      
      if (success) {
        setState(() {
          _isEditing = false;
          _isChangingPassword = false;
          _oldPasswordController.clear();
          _newPasswordController.clear();
        });
        _showSuccess('Profil mis à jour avec succès !');
      } else {
        _showError('Erreur lors de la mise à jour');
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
    final user = _authService.getCurrentUser()!;

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text('Mon Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7986CB),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Modifier',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête violet avec photo
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF7986CB), Color(0xFF9FA8DA)],
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: _photoProfilBase64 != null
                              ? MemoryImage(base64Decode(_photoProfilBase64!))
                              : null,
                          child: _photoProfilBase64 == null
                              ? Icon(Icons.person, size: 60, color: Color(0xFF7986CB))
                              : null,
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickProfilePhoto,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFF5C6BC0),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${user.prenom} ${user.nom}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            
            // Formulaire
            Padding(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informations personnelles
                    _buildSectionTitle('Informations personnelles', Icons.person),
                    SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _nomController,
                            label: 'Nom',
                            icon: Icons.person_outline,
                            enabled: _isEditing,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _prenomController,
                            label: 'Prénom',
                            icon: Icons.person,
                            enabled: _isEditing,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    _buildDropdown(),
                    SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _telephoneController,
                      label: 'Téléphone',
                      icon: Icons.phone,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 32),
                    
                    // Compte et sécurité
                    _buildSectionTitle('Compte et sécurité', Icons.security),
                    SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      enabled: false,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    
                    if (_isEditing) ...[
                      SwitchListTile(
                        title: Text('Changer le mot de passe'),
                        value: _isChangingPassword,
                        onChanged: (value) {
                          setState(() {
                            _isChangingPassword = value;
                            if (!value) {
                              _oldPasswordController.clear();
                              _newPasswordController.clear();
                            }
                          });
                        },
                        activeColor: Color(0xFF7986CB),
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      if (_isChangingPassword) ...[
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _oldPasswordController,
                          label: 'Ancien mot de passe',
                          icon: Icons.lock_outline,
                          enabled: true,
                          obscureText: true,
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _newPasswordController,
                          label: 'Nouveau mot de passe',
                          icon: Icons.lock,
                          enabled: true,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Requis';
                            }
                            if (value.length < 6) {
                              return 'Minimum 6 caractères';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                    
                    SizedBox(height: 32),
                    
                    // Boutons d'action
                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _isChangingPassword = false;
                                  // Réinitialiser les valeurs
                                  final currentUser = _authService.getCurrentUser()!;
                                  _nomController.text = currentUser.nom;
                                  _prenomController.text = currentUser.prenom;
                                  _telephoneController.text = currentUser.telephone;
                                  _sexe = currentUser.sexe;
                                  _photoProfilBase64 = currentUser.photoProfil;
                                  _oldPasswordController.clear();
                                  _newPasswordController.clear();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: Color(0xFF9E9E9E)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text('Annuler', style: TextStyle(color: Color(0xFF757575))),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF7986CB),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Enregistrer',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF7986CB), size: 24),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: enabled ? Color(0xFF7986CB) : Color(0xFF9E9E9E)),
        prefixIcon: Icon(icon, color: enabled ? Color(0xFF7986CB) : Color(0xFFBDBDBD)),
        filled: true,
        fillColor: enabled ? Color(0xFFF5F5F5) : Color(0xFFEEEEEE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF7986CB), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      validator: validator ?? (value) {
        if (enabled && (value == null || value.isEmpty)) {
          return 'Requis';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _sexe,
      decoration: InputDecoration(
        labelText: 'Sexe',
        labelStyle: TextStyle(color: _isEditing ? Color(0xFF7986CB) : Color(0xFF9E9E9E)),
        prefixIcon: Icon(Icons.wc, color: _isEditing ? Color(0xFF7986CB) : Color(0xFFBDBDBD)),
        filled: true,
        fillColor: _isEditing ? Color(0xFFF5F5F5) : Color(0xFFEEEEEE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF7986CB), width: 2),
        ),
      ),
      items: ['Homme', 'Femme', 'Autre'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: _isEditing ? (value) {
        setState(() {
          _sexe = value!;
        });
      } : null,
    );
  }
}