import 'package:flutter/material.dart';
import 'core/app_constants.dart';
import 'presentation/pages/role_selection_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const RoleSelectionScreen(),
    );
  }
}
