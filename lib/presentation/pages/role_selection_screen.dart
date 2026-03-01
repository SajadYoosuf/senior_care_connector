import 'package:flutter/material.dart';
import 'package:app/core/app_constants.dart';
import 'package:app/presentation/widgets/custom_button.dart';
import 'package:app/presentation/widgets/role_card.dart';
import 'package:app/presentation/pages/login_screen.dart';
import 'package:app/presentation/pages/admin_login_screen.dart';

/// Screen that allow users to select their role (Volunteer, Senior, or Both).
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  void _handleRoleSelection(String role) {
    setState(() {
      selectedRole = role;
    });
  }

  void _continue() {
    if (selectedRole != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(role: selectedRole),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                AppStrings.roleSelectionTitle,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please select your role to continue',
                style: TextStyle(fontSize: 16, color: AppColors.grey),
              ),
              const SizedBox(height: 40),
              RoleCard(
                title: 'I am a Volunteer',
                description: 'Offer support and help seniors in need',
                imagePath: 'assets/images/caregiver.png',
                isSelected: selectedRole == 'volunteer',
                onTap: () => _handleRoleSelection('volunteer'),
              ),
              const SizedBox(height: 16),
              RoleCard(
                title: 'I am a Senior',
                description: 'Request assistance and find support',
                imagePath: 'assets/images/senior.png',
                isSelected: selectedRole == 'senior',
                onTap: () => _handleRoleSelection('senior'),
              ),
              const SizedBox(height: 16),
              RoleCard(
                title: 'I am Both',
                description: 'I want to both help and receive support',
                imagePath: 'assets/images/group.png',
                isSelected: selectedRole == 'both',
                onTap: () => _handleRoleSelection('both'),
              ),
              const Spacer(),
              CustomButton(
                text: 'Continue',
                onPressed: _continue,
                backgroundColor: selectedRole != null
                    ? AppColors.primary
                    : Colors.grey.shade300,
                textColor: selectedRole != null
                    ? Colors.white
                    : Colors.grey.shade600,
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
