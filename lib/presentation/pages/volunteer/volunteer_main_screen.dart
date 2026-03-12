import 'package:flutter/material.dart';
import 'package:app/core/app_constants.dart';
import 'package:app/core/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dashboard/volunteer_dashboard_screen.dart';
import 'leaderboard/volunteer_leaderboard_screen.dart';
import 'chat/volunteer_chat_list_screen.dart';
import 'profile/volunteer_profile_screen.dart';

class VolunteerMainScreen extends StatefulWidget {
  const VolunteerMainScreen({super.key});

  @override
  State<VolunteerMainScreen> createState() => _VolunteerMainScreenState();
}

class _VolunteerMainScreenState extends State<VolunteerMainScreen> {
  int _currentIndex = 0;

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
      body: Stack(children: [_screens[_currentIndex], _buildSOSAlertStream()]),
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

        final alert = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final alertId = snapshot.data!.docs.first.id;
        final name = alert['userName'] ?? 'Someone';

        // Basic proximity check (if volunteer has location)
        final user = context.read<AuthProvider>().user;
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

  void _handleSOSResponse(String id, Map<String, dynamic> data) async {
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
                    'responderId': context.read<AuthProvider>().user?.id,
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
