class User {
  final String email;
  final String password;
  final String nom;
  final String prenom;
  final String sexe;
  final String telephone;
  final String? photoProfil; // Base64 image - OPTIONNEL

  User({
    required this.email,
    required this.password,
    required this.nom,
    required this.prenom,
    required this.sexe,
    required this.telephone,
    this.photoProfil,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'nom': nom,
      'prenom': prenom,
      'sexe': sexe,
      'telephone': telephone,
      'photoProfil': photoProfil,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      sexe: map['sexe'] ?? '',
      telephone: map['telephone'] ?? '',
      photoProfil: map['photoProfil'],
    );
  }
}