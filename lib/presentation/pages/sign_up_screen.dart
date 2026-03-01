import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';
import 'admin_login_screen.dart';
import 'volunteer/volunteer_main_screen.dart';

class SignUpScreen extends StatelessWidget {
  final String role;
  const SignUpScreen({super.key, required this.role});

  void _handleSignUp(BuildContext context, AuthProvider authProvider) async {
    final success = await authProvider.signUp(role);
    if (success) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
      final user = authProvider.user;
      if (user?.role == 'volunteer' || user?.role == 'both') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const VolunteerMainScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } else {
      if (!context.mounted) return;
      if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authProvider.errorMessage!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: authProvider.signUpFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join us to find care or provide care',
                  style: TextStyle(fontSize: 16, color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                CustomTextField(
                  hintText: 'Full Name',
                  controller: authProvider.signUpNameController,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.grey,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: 'Email Address',
                  controller: authProvider.signUpEmailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.grey,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: 'Password',
                  controller: authProvider.signUpPasswordController,
                  isPassword: true,
                  obscureText: !authProvider.isSignUpPasswordVisible,
                  onPasswordToggle: authProvider.toggleSignUpPasswordVisibility,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.grey,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your password';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: 'Confirm Password',
                  controller: authProvider.signUpConfirmPasswordController,
                  isPassword: true,
                  obscureText: !authProvider.isSignUpConfirmPasswordVisible,
                  onPasswordToggle:
                      authProvider.toggleSignUpConfirmPasswordVisibility,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.grey,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != authProvider.signUpPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: AppColors.grey, fontSize: 14),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialLoginButton(
                      imagePath: 'assets/images/google_logo.png',
                      onTap: () async {
                        final success = await authProvider.signInWithGoogle(
                          role,
                        );
                        if (success) {
                          if (!context.mounted) return;
                          final user = authProvider.user;
                          if (user?.role == 'volunteer' ||
                              user?.role == 'both') {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const VolunteerMainScreen(),
                              ),
                              (route) => false,
                            );
                          } else {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: authProvider.isLoading ? 'Signing Up...' : 'Sign Up',
                  onPressed: authProvider.isLoading
                      ? () {}
                      : () => _handleSignUp(context, authProvider),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: AppColors.grey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminLoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Login as Admin',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton({
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(imagePath, height: 24, width: 24),
      ),
    );
  }
}
