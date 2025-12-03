# catalogue_app
# 📦 Catalogue App - Application de Gestion de Catalogue Personnel

Une application Flutter moderne et élégante pour gérer votre catalogue de produits personnel avec authentification utilisateur, upload d'images, recherche et tri avancés.

![Flutter](https://img.shields.io/badge/Flutter-3.38.3-blue)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Fonctionnalités

### 🔐 Authentification
- **Inscription** avec informations complètes (nom, prénom, email, téléphone, sexe, photo de profil)
- **Connexion sécurisée** avec validation
- **Gestion de profil** (modification des informations personnelles et mot de passe)
- **Déconnexion** sécurisée
- Chaque utilisateur a son **catalogue privé**

### 📦 Gestion de Catalogue
- **Ajouter** des produits avec :
  - Titre
  - Description
  - Prix
  - Image (upload depuis votre ordinateur)
- **Modifier** des produits existants
- **Supprimer** des produits avec confirmation
- **Recherche en temps réel** par titre ou description
- **Tri multiple** :
  - Par date d'ajout
  - Par prix croissant
  - Par prix décroissant
  - Par ordre alphabétique

### 📊 Statistiques
- Nombre total de produits
- Valeur totale du catalogue
- Interface statistiques en temps réel

### 🎨 Design
- **Couleurs pastel modernes** (bleu, violet, rose)
- **Interface fluide** avec animations
- **Responsive design** adapté au web
- **Boutons interactifs** avec effets d'agrandissement
- **Cards élégantes** avec ombres douces

## 🛠️ Technologies Utilisées

- **Flutter 3.38.3** - Framework de développement
- **Dart** - Langage de programmation
- **Hive** - Base de données locale NoSQL
- **HTML dart:html** - Gestion des uploads d'images web

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- [Flutter SDK 3.38.3+](https://flutter.dev/docs/get-started/install)
- [Git](https://git-scm.com/downloads)
- [Visual Studio Code](https://code.visualstudio.com/) ou un autre IDE
- Extension Flutter pour VS Code
- Un navigateur web (Chrome recommandé)

### Vérifier l'installation de Flutter

```bash
flutter doctor
```

Vous devriez voir au minimum :
- ✅ Flutter (Channel stable)
- ✅ Chrome - develop for the web

## 🚀 Installation

### 1. Cloner le projet

```bash
git clone https://github.com/VOTRE_USERNAME/catalogue_app.git
cd catalogue_app
```

### 2. Installer les dépendances

```bash
flutter pub get
```

Cette commande installe automatiquement toutes les dépendances nécessaires :
- `hive`
- `hive_flutter`
- `path_provider`

### 3. Vérifier la structure du projet

Assurez-vous que votre structure de fichiers ressemble à ceci :

```
catalogue_app/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── user.dart
│   │   └── product.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   └── catalogue_service.dart
│   └── pages/
│       ├── auth/
│       │   └── signin_page.dart
│       ├── catalogue/
│       │   └── catalogue_page.dart
│       └── profile/
│           └── profile_page.dart
├── pubspec.yaml
└── README.md
```

### 4. Lancer l'application

**Sur navigateur web (Chrome) :**

```bash
flutter run -d chrome
```

**Sur Windows (application de bureau) :**

```bash
flutter run -d windows
```

**Pour lister les appareils disponibles :**

```bash
flutter devices
```

## 📱 Utilisation

### Première connexion

1. **S'inscrire** :
   - Cliquez sur "Pas de compte ? Inscrivez-vous"
   - Remplissez le formulaire :
     - Nom et prénom
     - Sexe
     - Téléphone
     - Email
     - Mot de passe (minimum 6 caractères)
     - Photo de profil (optionnelle)
   - Cliquez sur "S'inscrire"

2. **Se connecter** :
   - Entrez votre email et mot de passe
   - Cliquez sur "Se connecter"

### Gérer votre catalogue

#### Ajouter un produit
1. Cliquez sur le bouton **"+ Ajouter"** en bas à droite
2. Cliquez sur la zone grise pour ajouter une image
3. Remplissez les informations :
   - Titre du produit
   - Description
   - Prix (en euros)
4. Cliquez sur **"Enregistrer"**

#### Modifier un produit
1. Cliquez sur la **carte du produit**
2. Modifiez les informations
3. Cliquez sur **"Enregistrer"**

#### Supprimer un produit
1. Cliquez sur l'**icône poubelle** rouge
2. Confirmez la suppression

#### Rechercher et trier
1. Utilisez la **barre de recherche** en haut
2. Cliquez sur les **boutons de tri** :
   - Date d'ajout
   - Prix croissant
   - Prix décroissant
   - Alphabétique

### Gérer votre profil

1. Cliquez sur votre **photo de profil** en haut à gauche
2. Cliquez sur l'**icône modifier** (crayon) en haut à droite
3. Modifiez vos informations
4. Pour changer le mot de passe :
   - Activez "Changer le mot de passe"
   - Entrez l'ancien mot de passe
   - Entrez le nouveau mot de passe
5. Cliquez sur **"Enregistrer"**

### Se déconnecter

Cliquez sur l'**icône déconnexion** en haut à droite du catalogue

## 🏗️ Architecture du Projet

Le projet suit une architecture **MVC-like** propre et organisée :

### Models (`lib/models/`)
Définition des structures de données :
- **`user.dart`** : Modèle utilisateur (email, nom, prénom, sexe, téléphone, photo)
- **`product.dart`** : Modèle produit (titre, description, prix, image)

### Services (`lib/services/`)
Logique métier et gestion des données :
- **`auth_service.dart`** : Gestion de l'authentification (inscription, connexion, déconnexion)
- **`catalogue_service.dart`** : Gestion du catalogue (CRUD produits, recherche, tri)

### Pages (`lib/pages/`)
Interface utilisateur :
- **`auth/signin_page.dart`** : Page de connexion/inscription
- **`catalogue/catalogue_page.dart`** : Page principale du catalogue
- **`profile/profile_page.dart`** : Page de gestion de profil

### Main (`lib/main.dart`)
Point d'entrée de l'application avec vérification d'authentification

## 🗄️ Stockage des Données

L'application utilise **Hive** comme base de données locale NoSQL :

- **Données stockées localement** sur votre navigateur/machine
- **Persistance des données** entre les sessions
- **Pas de serveur requis** - fonctionne entièrement hors ligne
- **Données utilisateur isolées** - chaque utilisateur a son propre espace

### Structure de stockage Hive

```dart
usersBox
├── user_email@example.com          // Informations utilisateur
├── catalogue_email@example.com     // Catalogue de l'utilisateur
└── currentUser                     // Email de l'utilisateur connecté
```

## 🎨 Palette de Couleurs

L'application utilise des couleurs pastel douces et modernes :

| Élément | Couleur | Code |
|---------|---------|------|
| Principal | Bleu Indigo | `#7986CB` |
| Secondaire | Bleu Indigo Clair | `#9FA8DA` |
| Accent | Violet Pastel | `#E8EAF6` |
| Fond | Gris Très Clair | `#FAFAFA` |
| Erreur | Rouge Pastel | `#FF6B6B` |
| Succès | Vert Pastel | `#51CF66` |

## 📦 Dépendances

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.1
```

## 🔧 Configuration

### Pour le web uniquement

L'application est configurée pour fonctionner sur le web. Si vous voulez l'utiliser sur mobile (Android/iOS), vous devrez :

1. Remplacer `dart:html` par des packages compatibles multiplateforme
2. Utiliser `image_picker` au lieu de `FileUploadInputElement`
3. Adapter le stockage Hive pour mobile

## 🐛 Problèmes Connus

- **Upload d'images** : Fonctionne uniquement sur le web avec `dart:html`
- **iOS depuis Windows** : Impossible de compiler pour iOS depuis Windows (nécessite un Mac)

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Fork le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Poussez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📝 Améliorations Futures

- [ ] Export du catalogue en PDF/Excel
- [ ] Catégories de produits
- [ ] Mode sombre
- [ ] Graphiques et statistiques avancées
- [ ] Partage de catalogue entre utilisateurs
- [ ] Support mobile complet (Android/iOS)
- [ ] Notifications
- [ ] Gestion de stock (quantités)
- [ ] Backend avec API REST
- [ ] Authentification OAuth (Google, Facebook)

## 👨‍💻 Auteur

**Yosr Mekki**
- Email: yosr.mekki@esprit.tn
- GitHub: [@VOTRE_USERNAME](https://github.com/VOTRE_USERNAME)

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🙏 Remerciements

- Flutter Team pour le framework incroyable
- Hive pour la base de données locale simple et rapide
- La communauté Flutter pour les ressources et le support

---

**Note** : Ce projet a été développé dans le cadre d'un apprentissage de Flutter et du développement mobile/web.

Pour toute question ou suggestion, n'hésitez pas à ouvrir une issue sur GitHub !

## 📸 Captures d'écran

### Page de connexion
![Connexion](screenshots/signin.png)

### Catalogue
![Catalogue](screenshots/catalogue.png)

### Profil utilisateur
![Profil](screenshots/profile.png)

---

**Fait avec ❤️ et Flutter**