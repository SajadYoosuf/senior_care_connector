import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior_care/core/app_constants.dart';
import 'package:senior_care/core/app_localizations.dart';
import 'package:senior_care/views/login_screen.dart';
import 'package:senior_care/viewmodels/auth_viewmodel.dart';
import 'package:senior_care/views/profile/edit_profile_screen.dart';
import 'package:senior_care/views/volunteer/profile/admin_chat_screen.dart';
import 'package:senior_care/views/volunteer/profile/volunteer_reviews_screen.dart';
import 'package:senior_care/core/services/ringtone_service.dart';

class VolunteerProfileScreen extends StatelessWidget {
  const VolunteerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).profile,
          style: const TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: AppColors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Profile Image with Edit Icon
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue.shade50,
                    child: Text(
                      context.watch<AuthViewModel>().user?.name.isNotEmpty ==
                              true
                          ? context
                                .watch<AuthViewModel>()
                                .user!
                                .name[0]
                                .toUpperCase()
                          : 'V',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.watch<AuthViewModel>().user?.name ?? 'Volunteer User',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.watch<AuthViewModel>().user?.email ?? '',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            // Menu Options
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.account_circle_outlined,
                    text: AppLocalizations.of(context).editProfile,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.star_border_outlined,
                    text: 'My Reviews & Feedback',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VolunteerReviewsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.notifications_none,
                    text: 'Notification Settings',
                    onTap: () {
                      _showNotificationSettings(context);
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    text: AppLocalizations.of(context).helpSupport,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminChatScreen(),
                        ),
                      );
                    },
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                ),
                onPressed: () {
                  final parentContext = context;
                  showDialog(
                    context: parentContext,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(AppLocalizations.of(parentContext).logOut),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(dialogContext); // Close the dialog
                            final authViewModel = parentContext.read<AuthViewModel>();
                            Navigator.pushAndRemoveUntil(
                              parentContext,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                            authViewModel.logout();
                          },
                          child: Text(AppLocalizations.of(parentContext).logOut),
                        ),
                      ],
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).logOut,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isLast = false,
    Color textColor = AppColors.black,
    Color iconColor = Colors.blue,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1), // Light bg for icons per design
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      // Wait, looking at the image "edit profile", "notifications" etc.
      // The icons are Blue.
      // Let's just use Icon(color: Colors.blue).
      // But in usual designs they are wrapped. I'll wrap them loosely or just icon.
      // Re-examining the image: It looks like blue icons with no background container.
      title: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            final user = authViewModel.user;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Settings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.music_note, color: Colors.blue),
                    title: const Text('Alarm Tone'),
                    subtitle: Text(
                      user?.alarmTone != null
                          ? 'Custom tone selected'
                          : 'Default system tone',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final uri = await RingtoneService.pickRingtone();
                      if (uri != null) {
                        await authViewModel.setAlarmTone(uri);
                      }
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.vibration, color: Colors.blue),
                    title: const Text('Vibration'),
                    value: user?.vibrationEnabled ?? true,
                    onChanged: (val) {
                      authViewModel.toggleVibration();
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
