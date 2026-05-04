import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior_care/core/app_constants.dart';
import 'package:senior_care/widgets/custom_button.dart';
import 'package:senior_care/widgets/custom_text_field.dart';
import 'package:senior_care/viewmodels/auth_viewmodel.dart';
import 'package:senior_care/views/main_screen.dart';
import 'package:senior_care/views/admin_login_screen.dart';
import 'package:senior_care/views/volunteer/volunteer_main_screen.dart';

class SignUpScreen extends StatelessWidget {
  final String role;
  const SignUpScreen({super.key, required this.role});

  void _handleSignUp(BuildContext context, AuthViewModel authViewModel) async {
    final success = await authViewModel.signUp(role);
    if (success) {
      if (!context.mounted) return;
      final user = authViewModel.user;
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
      if (authViewModel.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authViewModel.errorMessage!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: authViewModel.signUpFormKey,
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
                  controller: authViewModel.signUpNameController,
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
                  controller: authViewModel.signUpEmailController,
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
                if (role == 'volunteer' || role == 'both') ...[
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: 'Profession (e.g. Doctor, Plumber)',
                    controller: authViewModel.signUpProfessionController,
                    prefixIcon: const Icon(
                      Icons.work_outline,
                      color: AppColors.grey,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your profession';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: 'Password',
                  controller: authViewModel.signUpPasswordController,
                  isPassword: true,
                  obscureText: !authViewModel.isSignUpPasswordVisible,
                  onPasswordToggle: authViewModel.toggleSignUpPasswordVisibility,
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
                  controller: authViewModel.signUpConfirmPasswordController,
                  isPassword: true,
                  obscureText: !authViewModel.isSignUpConfirmPasswordVisible,
                  onPasswordToggle:
                      authViewModel.toggleSignUpConfirmPasswordVisibility,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.grey,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != authViewModel.signUpPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Gender',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _genderOption(
                        context,
                        'Male',
                        Icons.male,
                        authViewModel.signUpGender == 'Male',
                        () => authViewModel.setSignUpGender('Male'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _genderOption(
                        context,
                        'Female',
                        Icons.female,
                        authViewModel.signUpGender == 'Female',
                        () => authViewModel.setSignUpGender('Female'),
                      ),
                    ),
                  ],
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
                        final success = await authViewModel.signInWithGoogle(
                          role,
                        );
                        if (success) {
                          if (!context.mounted) return;
                          final user = authViewModel.user;
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
                  text: authViewModel.isLoading ? 'Signing Up...' : 'Sign Up',
                  onPressed: authViewModel.isLoading
                      ? () {}
                      : () => _handleSignUp(context, authViewModel),
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

  Widget _genderOption(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
