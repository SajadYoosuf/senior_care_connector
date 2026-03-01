import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/app_constants.dart';
import 'core/app_localizations.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/presentation/pages/main_screen.dart';
import 'package:app/presentation/pages/volunteer/volunteer_main_screen.dart';
import 'package:app/presentation/pages/login_screen.dart';
import 'package:app/presentation/pages/role_selection_screen.dart';
import 'package:app/presentation/pages/admin/admin_main_screen.dart';

import 'package:provider/provider.dart';
import 'package:app/data/repositories/firebase_auth_repository.dart';
import 'package:app/data/repositories/firebase_task_repository.dart';
import 'package:app/presentation/providers/auth_provider.dart';
import 'package:app/presentation/providers/locale_provider.dart';
import 'package:app/presentation/providers/task_provider.dart';
import 'package:app/presentation/providers/admin_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  await Hive.openBox('medicines');
  await Hive.openBox('tasks');

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String? role = prefs.getString('userRole');

  final authProvider = AuthProvider(FirebaseAuthRepository());
  if (isLoggedIn) {
    await authProvider.loadCurrentUser();
  }

  final taskRepository = FirebaseTaskRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider(taskRepository)),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn, initialRole: role),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? initialRole;

  const MyApp({super.key, required this.isLoggedIn, this.initialRole});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocaleProvider, AuthProvider>(
      builder: (context, localeProvider, authProvider, child) {
        Widget home;

        if (!authProvider.isAuthenticated && !isLoggedIn) {
          home = const LoginScreen();
        } else {
          // Determine role from provider first, fallback to initialRole
          final role = authProvider.user?.role ?? initialRole;

          if (role == null || role.isEmpty) {
            home = const RoleSelectionScreen(isPostAuth: true);
          } else if (role == 'admin') {
            home = const AdminMainScreen();
          } else if (role == 'volunteer' || role == 'both') {
            home = const VolunteerMainScreen();
          } else {
            home = const MainScreen();
          }
        }

        return MaterialApp(
          title: AppStrings.appName,
          theme: AppTheme.lightTheme,
          locale: localeProvider.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('ml'),
            Locale('ta'),
            Locale('hi'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          home: home,
        );
      },
    );
  }
}
