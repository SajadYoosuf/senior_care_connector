import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior_care/core/app_constants.dart';
import 'package:senior_care/widgets/custom_button.dart';
import 'package:senior_care/widgets/custom_text_field.dart';
import 'package:senior_care/viewmodels/auth_viewmodel.dart';
import 'package:senior_care/views/admin/admin_main_screen.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, using the same auth provider or a separate admin logic if needed.
    // Usually admin has a specific flow.
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: authViewModel.adminLoginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Administrative Access',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                CustomTextField(
                  hintText: 'Admin Email',
                  controller: authViewModel.adminEmailController,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: 'Admin Password',
                  controller: authViewModel.adminPasswordController,
                  isPassword: true,
                  obscureText: !authViewModel.isAdminPasswordVisible,
                  onPasswordToggle: authViewModel.toggleAdminPasswordVisibility,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Login as Admin',
                  isLoading: authViewModel.isLoading,
                  onPressed: () async {
                    final success = await authViewModel.login('admin');
                    if (success) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Admin Login Successful')),
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminMainScreen(),
                        ),
                        (route) => false,
                      );
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            authViewModel.errorMessage ?? 'Access Denied',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
