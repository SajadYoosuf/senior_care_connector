import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:senior_care/core/app_constants.dart';
import 'package:senior_care/core/app_localizations.dart';
import 'package:senior_care/viewmodels/auth_viewmodel.dart';
import 'package:senior_care/viewmodels/locale_viewmodel.dart';
import 'package:senior_care/views/volunteers/volunteers_screen.dart';
import 'package:senior_care/views/dashboard/request_help_screen.dart';
import 'package:senior_care/views/tasks/task_list_screen.dart';
import 'package:senior_care/views/notifications/notification_screen.dart';
import 'package:senior_care/views/medicine/medicine_reminder_screen.dart';
import 'package:senior_care/views/requests/current_requests_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:senior_care/repositories/sos_repository.dart';
import 'package:senior_care/views/volunteer/volunteer_main_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static final SOSRepository _sosRepository = SOSRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForPendingFeedback();
    });
  }

  Future<void> _checkForPendingFeedback() async {
    final user = context.read<AuthViewModel>().user;
    if (user == null || user.role == 'volunteer') return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('help_requests')
          .where('userId', isEqualTo: user.id)
          .where('status', isEqualTo: 'Completed')
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['feedbackGiven'] != true) {
          if (!mounted) return;
          await _showFeedbackDialog(doc.id, data['title'] ?? 'Task', data['volunteerId']);
          break; // Show one at a time
        }
      }
    } catch (e) {
      debugPrint('Error checking for feedback: $e');
    }
  }

  Future<void> _showFeedbackDialog(String taskId, String taskTitle, String? volunteerId) async {
    int rating = 5;
    final TextEditingController feedbackController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'How was your help?',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Please rate your experience for "$taskTitle".',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() => rating = index + 1);
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: feedbackController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Leave a brief review for the volunteer...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Skip for now', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  try {
                    await FirebaseFirestore.instance.collection('help_requests').doc(taskId).update({
                      'feedbackGiven': true,
                      'rating': rating,
                      'feedbackText': feedbackController.text.trim(),
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feedback submitted. Thank you!')),
                      );
                    }
                  } catch (e) {
                    debugPrint('Submit feedback error: $e');
                  }
                },
                child: const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          // ignore: deprecated_member_use
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            context
                                        .watch<AuthViewModel>()
                                        .user
                                        ?.name
                                        .isNotEmpty ==
                                    true
                                ? context
                                      .watch<AuthViewModel>()
                                      .user!
                                      .name[0]
                                      .toUpperCase()
                                : '👴',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).welcomeBack,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                context
                                            .watch<AuthViewModel>()
                                            .user
                                            ?.name
                                            .isNotEmpty ==
                                        true
                                    ? context.watch<AuthViewModel>().user!.name
                                    : 'User',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: IconButton(
                          onPressed: () => _showLanguageBottomSheet(context),
                          icon: const Icon(
                            Icons.language,
                            color: AppColors.black,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // Added for spacing
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Role Switcher
              if (context.watch<AuthViewModel>().user?.role == 'both')
                GestureDetector(
                  onTap: () {
                    context.read<AuthViewModel>().toggleRoleMode();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VolunteerMainScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.swap_horiz, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Switch to Volunteer View',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Emergency Call Widget
              const SizedBox(height: 32),

              // Action Grid Title
              Text(
                AppLocalizations.of(context).howCanWeHelp,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Action Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildActionCard(
                    context,
                    title: AppLocalizations.of(context).currentRequests,
                    subtitle: AppLocalizations.of(context).activePastRequests,
                    icon: Icons.volunteer_activism,
                    color: Colors.blue.shade50,
                    iconColor: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CurrentRequestsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: AppLocalizations.of(context).myTasks,
                    subtitle: AppLocalizations.of(context).myTasksSub,
                    icon: Icons.assignment_outlined,
                    color: Colors.green.shade50,
                    iconColor: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TaskListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: AppLocalizations.of(context).findVolunteers,
                    subtitle: AppLocalizations.of(context).findVolunteersSub,
                    icon: Icons.people_outline,
                    color: Colors.orange.shade50,
                    iconColor: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VolunteersScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: AppLocalizations.of(context).medicineReminder,
                    subtitle: AppLocalizations.of(context).dontMissPills,
                    icon: Icons.medical_services_outlined,
                    color: Colors.pink.shade50,
                    iconColor: Colors.pink,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MedicineReminderScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final user = context.read<AuthViewModel>().user;
                      if (user == null) return;

                      // Show loading snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context).sendingSOS,
                          ),
                        ),
                      );

                      // Check permissions
                      LocationPermission permission =
                          await Geolocator.checkPermission();
                      if (permission == LocationPermission.denied) {
                        permission = await Geolocator.requestPermission();
                        if (permission == LocationPermission.denied) {
                          return;
                        }
                      }

                      Position? position;
                      try {
                        position = await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high,
                        );
                      } catch (e) {
                        // Ignored
                      }

                      await _sosRepository.sendSOSAlert(
                        userId: user.id,
                        userName: user.name,
                        latitude: position?.latitude,
                        longitude: position?.longitude,
                        locationUrl: position != null
                            ? 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}'
                            : null,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context).sosSentMessage,
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${AppLocalizations.of(context).errorSendingSOS}: $e',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_in_talk, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context).emergencyAssistance,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 150.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RequestHelpScreen(),
              ),
            );
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            AppLocalizations.of(context).requestHelp,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final List<Map<String, String>> languages = [
          {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
          {'name': 'Malayalam', 'code': 'ml', 'flag': '🇮🇳'},
          {'name': 'Tamil', 'code': 'ta', 'flag': '🇮🇳'},
          {'name': 'Hindi', 'code': 'hi', 'flag': '🇮🇳'},
        ];

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).selectLanguage,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: languages.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  return Consumer<LocaleViewModel>(
                    builder: (context, localeViewModel, _) {
                      final isSelected =
                          localeViewModel.locale.languageCode == lang['code'];
                      return ListTile(
                        leading: Text(
                          lang['flag']!,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          lang['name']!,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.black,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () {
                          localeViewModel.setLocale(Locale(lang['code']!));
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
