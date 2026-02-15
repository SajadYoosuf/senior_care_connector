import 'package:flutter/material.dart';
import '../../core/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/role_card.dart';
import 'login_screen.dart'; // Will be created next

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
        MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                title: 'I am a Caregiver',
                description: 'Find jobs and care for seniors',
                icon: Icons.medical_services_outlined,
                isSelected: selectedRole == 'caregiver',
                onTap: () => _handleRoleSelection('caregiver'),
              ),
              const SizedBox(height: 16),
              RoleCard(
                title: 'I am a Senior',
                description: 'Find caregivers and get assistance',
                icon: Icons.elderly,
                isSelected: selectedRole == 'senior',
                onTap: () => _handleRoleSelection('senior'),
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
            ],
          ),
        ),
      ),
    );
  }
}
