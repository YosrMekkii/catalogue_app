import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/auth_service.dart';
import 'pages/auth/signin_page.dart';
import 'pages/catalogue/catalogue_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('usersBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Catalogue Personnel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF7986CB),
        scaffoldBackgroundColor: Color(0xFFFAFAFA),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.light(
          primary: Color(0xFF7986CB),
          secondary: Color(0xFF9FA8DA),
        ),
      ),
      home: AuthChecker(),
    );
  }
}

// Vérification de l'authentification au démarrage
class AuthChecker extends StatelessWidget {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.getCurrentUser();
    
    if (currentUser != null) {
      return CataloguePage();
    }
    return SignInPage();
  }
}