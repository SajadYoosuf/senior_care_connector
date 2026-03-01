import 'package:flutter/material.dart';
import 'core/app_constants.dart';
import 'presentation/pages/role_selection_screen.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/pages/main_screen.dart';
import 'presentation/pages/volunteer/volunteer_main_screen.dart';

import 'package:provider/provider.dart';
import 'package:app/data/repositories/firebase_auth_repository.dart';
import 'package:app/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String? role = prefs.getString('userRole');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(FirebaseAuthRepository()),
        ),
      ],
      child: MyApp(isLoggedIn: isLoggedIn, role: role),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? role;

  const MyApp({super.key, required this.isLoggedIn, this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: isLoggedIn
          ? (role == 'volunteer' || role == 'caregiver'
                ? const VolunteerMainScreen()
                : const MainScreen())
          : const RoleSelectionScreen(),
    );
  }
}
