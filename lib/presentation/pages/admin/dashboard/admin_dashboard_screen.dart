import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/core/app_constants.dart';
import 'package:app/presentation/providers/admin_provider.dart';
import 'package:app/presentation/providers/auth_provider.dart';
import 'package:app/presentation/pages/login_screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.security, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Notification logic if needed
            },
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
          IconButton(
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics & Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),

            // Grid of Stats using Real Data
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildStatCard(
                  title: 'Total seniors',
                  count: adminProvider.seniorCount.toString(),
                  icon: Icons.accessible,
                  iconColor: Colors.blue,
                  bgColor: Colors.blue.shade50,
                ),
                _buildStatCard(
                  title: 'Volunteer',
                  count: adminProvider.volunteerCount.toString(),
                  icon: Icons.volunteer_activism,
                  iconColor: Colors.green,
                  bgColor: Colors.green.shade50,
                ),
                _buildStatCard(
                  title: "Accepted Visits",
                  count: adminProvider.todayVisitCount.toString(),
                  icon: Icons.calendar_today,
                  iconColor: Colors.orange,
                  bgColor: Colors.orange.shade50,
                ),
                _buildStatCard(
                  title: 'Pending Tasks',
                  count: adminProvider.pendingTaskCount.toString(),
                  icon: Icons.assignment_late,
                  iconColor: Colors.red,
                  bgColor: Colors.red.shade50,
                ),
              ],
            ),

            if (adminProvider.activeSOSAlerts.isNotEmpty) ...[
              const SizedBox(height: 32),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text(
                    'Active SOS Alerts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: adminProvider.activeSOSAlerts.length,
                itemBuilder: (context, index) {
                  final sos = adminProvider.activeSOSAlerts[index];
                  return Card(
                    color: Colors.red.shade50,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(Icons.bolt, color: Colors.white),
                      ),
                      title: Text(
                        sos['userName'] ?? 'Unknown Senior',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Triggered: ${sos['createdAt'] != null ? DateFormat('hh:mm a').format((sos['createdAt'] as Timestamp).toDate()) : 'Recently'}',
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final url = sos['locationUrl'];
                          if (url != null) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                        child: const Text('View Location'),
                      ),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 32),
            const Text(
              'Recent System Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (adminProvider.recentLogs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text(
                    'No recent activity logs found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: adminProvider.recentLogs.length,
                itemBuilder: (context, index) {
                  final log = adminProvider.recentLogs[index];
                  final timestamp = log['timestamp'] as Timestamp?;
                  final dateStr = timestamp != null
                      ? DateFormat('MMM d, hh:mm a').format(timestamp.toDate())
                      : 'Just now';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _getLogIcon(log['action']),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    log['userName'] ?? 'User',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    dateStr,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                log['details'] ?? '',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _getLogIcon(String? action) {
    IconData icon;
    Color color;

    switch (action) {
      case 'SOS_TRIGGERED':
        icon = Icons.error_outline;
        color = Colors.red;
        break;
      case 'MEDICINE_TAKEN':
        icon = Icons.medication;
        color = Colors.blue;
        break;
      case 'TASK_COMPLETED':
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case 'TASK_ACCEPTED':
        icon = Icons.handshake_outlined;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info_outline;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              color: iconColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
