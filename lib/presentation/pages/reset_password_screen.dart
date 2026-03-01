import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../../core/app_constants.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _isSuccess = false;

  void _handleResetPassword(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final success = await authProvider.resetPassword(widget.email);
    if (success) {
      setState(() {
        _isSuccess = true;
      });
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Password reset failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSuccess ? 'Success' : 'New Password'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.black,
        automaticallyImplyLeading: _isSuccess == true ? false : true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _isSuccess
              ? _buildSuccessUI(context)
              : _buildResetForm(context, authProvider),
        ),
      ),
    );
  }

  Widget _buildSuccessUI(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring (Subtle glow/shadow effect)
                  Container(
                    width: 130 * value,
                    height: 130 * value,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Solid Blue Circle (GPay style)
                  Container(
                    width: 105 * value,
                    height: 105 * value,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  // White Tick (Appears slightly later in the animation)
                  if (value > 0.6)
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 400),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOutBack,
                      builder: (context, tickValue, child) {
                        return Transform.scale(
                          scale: tickValue,
                          child: const Icon(
                            Icons.check_rounded,
                            size: 65,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Password Changed!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Your password has been reset successfully. You can now use your new password to log in.',
          style: TextStyle(color: AppColors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        CustomButton(
          text: 'Go to Login',
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ],
    );
  }

  Widget _buildResetForm(BuildContext context, AuthProvider authProvider) {
    return Form(
      key: authProvider.resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Set New Password',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Added Current Password field
          CustomTextField(
            hintText: 'Current Password',
            controller: authProvider.resetCurrentPasswordController,
            isPassword: true,
            obscureText: !authProvider.isResetCurrentPasswordVisible,
            onPasswordToggle: authProvider.toggleResetCurrentPasswordVisibility,
            prefixIcon: const Icon(Icons.lock_outline),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your current password';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            hintText: 'New Password',
            controller: authProvider.resetPasswordController,
            isPassword: true,
            obscureText: !authProvider.isResetPasswordVisible,
            onPasswordToggle: authProvider.toggleResetPasswordVisibility,
            prefixIcon: const Icon(Icons.lock_outline),
            validator: (value) {
              if (value == null || value.length < 6) return 'Min 6 characters';
              if (value == authProvider.resetCurrentPasswordController.text) {
                return 'New password must be different from current';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            hintText: 'Confirm Password',
            controller: authProvider.resetConfirmPasswordController,
            isPassword: true,
            obscureText: !authProvider.isResetConfirmPasswordVisible,
            onPasswordToggle: authProvider.toggleResetConfirmPasswordVisibility,
            prefixIcon: const Icon(Icons.lock_outline),
            validator: (value) {
              if (value != authProvider.resetPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: authProvider.isLoading ? 'Updating...' : 'Update Password',
            onPressed: authProvider.isLoading
                ? () {}
                : () => _handleResetPassword(context, authProvider),
          ),
        ],
      ),
    );
  }
}
