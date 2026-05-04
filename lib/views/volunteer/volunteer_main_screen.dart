import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:senior_care/core/app_constants.dart' show AppColors;
import 'package:senior_care/core/app_localizations.dart';
import 'package:senior_care/models/task_entity.dart';
import 'package:senior_care/views/volunteer/tasks/volunteer_task_list_screen.dart';
import 'package:senior_care/viewmodels/task_viewmodel.dart';
import 'package:senior_care/viewmodels/auth_viewmodel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:senior_care/views/volunteer/dashboard/volunteer_dashboard_screen.dart';
import 'package:vibration/vibration.dart';
import 'package:alarm/alarm.dart';
import 'package:senior_care/views/volunteer/leaderboard/volunteer_leaderboard_screen.dart';
import 'package:senior_care/views/volunteer/chat/volunteer_chat_list_screen.dart';
import 'package:senior_care/views/volunteer/profile/volunteer_profile_screen.dart';

import 'package:senior_care/widgets/incoming_call_overlay.dart';

class VolunteerMainScreen extends StatefulWidget {
  const VolunteerMainScreen({super.key});

  @override
  State<VolunteerMainScreen> createState() => _VolunteerMainScreenState();
}

class _VolunteerMainScreenState extends State<VolunteerMainScreen> {
  int _currentIndex = 0;
  bool _isAlarmPlaying = false;

  final List<Widget> _screens = [
    const VolunteerDashboardScreen(),
    const VolunteerLeaderboardScreen(),
    const VolunteerChatListScreen(),
    const VolunteerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _screens[_currentIndex],
          _buildSOSAlertStream(),
          _buildHelpRequestAlertStream(),
          const IncomingCallOverlay(),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                0,
                Icons.home_rounded,
                Icons.home_outlined,
                AppLocalizations.of(context).home,
              ),
              _buildNavItem(
                1,
                Icons.emoji_events,
                Icons.emoji_events_outlined,
                AppLocalizations.of(context).leaderboard,
              ),
              _buildNavItem(
                2,
                Icons.chat_bubble_rounded,
                Icons.chat_bubble_outline_rounded,
                AppLocalizations.of(context).chat,
              ),
              _buildNavItem(
                3,
                Icons.person_rounded,
                Icons.person_outline_rounded,
                AppLocalizations.of(context).profile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData inactiveIcon,
    String label,
  ) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isSelected ? 1.1 : 1.0,
              child: Icon(
                isSelected ? icon : inactiveIcon,
                color: isSelected ? AppColors.primary : AppColors.grey,
                size: 26,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 72),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHelpRequestAlertStream() {
    final user = context.watch<AuthViewModel>().user;
    if (user == null || user.latitude == null || user.longitude == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<TaskEntity>>(
      stream: context.read<TaskViewModel>().watchNearbyTasks(
        user.latitude!,
        user.longitude!,
        5.0,
        excludeUserId: user.id,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        // Only show the most recent one if there are any
        final latestTask = snapshot.data!.first;

        return Positioned(
          bottom: 200,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Request: ${latestTask.title}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Within 5km • ${latestTask.requesterName}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VolunteerTaskListScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('VIEW'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSOSAlertStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sos_alerts')
          .where('status', isEqualTo: 'Active')
          .where(
            'createdAt',
            isGreaterThan: DateTime.now().subtract(const Duration(minutes: 30)),
          )
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final currentUserId = context.read<AuthViewModel>().user?.id;
        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['userId'] != currentUserId;
        }).toList();

        if (docs.isEmpty) return const SizedBox.shrink();

        final alert = docs.first.data() as Map<String, dynamic>;
        final alertId = docs.first.id;
        final name = alert['userName'] ?? 'Someone';

        // Basic proximity check (if volunteer has location)
        final user = context.read<AuthViewModel>().user;
        bool isNearby = true;
        if (user != null &&
            user.latitude != null &&
            alert['latitude'] != null) {
          double distance =
              Geolocator.distanceBetween(
                user.latitude!,
                user.longitude!,
                alert['latitude'],
                alert['longitude'],
              ) /
              1000;
          if (distance > 10) isNearby = false; // Only show if within 10km
        }

        if (!isNearby) return const SizedBox.shrink();

        // Trigger Alarm Sound and Vibration
        final tonePath = user?.alarmTone;
        final vibrateEnabled = user?.vibrationEnabled ?? true;
        _triggerSOSEffects(tonePath, vibrateEnabled);

        return Positioned(
          bottom: 100,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade900,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMERGENCY: $name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Requires Unpaid Assistance NOW!',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _handleSOSResponse(alertId, alert),
                  child: const Text('HELP'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _triggerSOSEffects(String? tonePath, bool vibrateEnabled) async {
    if (_isAlarmPlaying) return;
    _isAlarmPlaying = true;

    // Vibrate
    if (vibrateEnabled && await Vibration.hasVibrator()) {
      Vibration.vibrate(
        pattern: [500, 1000, 500, 1000, 500, 1000],
        intensities: [128, 255, 128, 255, 128, 255],
      );
    }

    // Play alarm sound using the alarm package (same as background FCM handler)
    try {
      final alarmSettings = AlarmSettings(
        id: 9991,
        dateTime: DateTime.now().add(const Duration(seconds: 1)),
        assetAudioPath: tonePath,
        loopAudio: true,
        vibrate: false, // vibration handled above
        volumeSettings: const VolumeSettings.fixed(volume: 1.0),
        notificationSettings: const NotificationSettings(
          title: '🚨 SOS EMERGENCY',
          body: 'A senior needs immediate help!',
          stopButton: 'Stop',
          icon: 'ic_launcher',
        ),
      );
      await Alarm.set(alarmSettings: alarmSettings);
    } catch (e) {
      debugPrint('Error starting SOS alarm sound: $e');
    }
  }

  void _handleSOSResponse(String id, Map<String, dynamic> data) async {
    _isAlarmPlaying = false;
    Vibration.cancel();
    // Stop alarm sound
    try {
      await Alarm.stop(9991);
    } catch (e) {
      debugPrint('Error stopping SOS alarm: $e');
    }
    // Show details or navigate
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('SOS from ${data['userName']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Action needed immediately!'),
            const SizedBox(height: 10),
            if (data['latitude'] != null)
              Text('Location: ${data['latitude']}, ${data['longitude']}'),
            const SizedBox(height: 10),
            if (data['locationUrl'] != null)
              ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(data['locationUrl']);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.map),
                label: const Text('View on Google Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Mark as responding or something?
              await FirebaseFirestore.instance
                  .collection('sos_alerts')
                  .doc(id)
                  .update({
                    'status': 'Responding',
                    'responderId': context.read<AuthViewModel>().user?.id,
                  });
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('I am responding'),
          ),
        ],
      ),
    );
  }
}
