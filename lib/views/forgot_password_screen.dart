import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior_care/core/app_constants.dart';
import 'package:senior_care/widgets/custom_button.dart';
import 'package:senior_care/widgets/custom_text_field.dart';
import 'package:senior_care/viewmodels/auth_viewmodel.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  void _handleResetEmail(BuildContext context, AuthViewModel authViewModel) async {
    final success = await authViewModel.sendPasswordResetEmail();
    if (success) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent to your email!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to login
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Failed to send reset link'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: authViewModel.forgotFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Enter your email address to receive a secure password reset link',
                  style: TextStyle(color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  hintText: 'Email Address',
                  controller: authViewModel.forgotEmailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter email';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: authViewModel.isLoading ? 'Sending...' : 'Send Reset Link',
                  onPressed: authViewModel.isLoading
                      ? () {}
                      : () => _handleResetEmail(context, authViewModel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
