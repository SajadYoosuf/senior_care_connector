import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/core/app_constants.dart';
import 'package:app/presentation/providers/admin_provider.dart';
import 'package:app/presentation/providers/auth_provider.dart';
import 'package:app/presentation/pages/login_screen.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: authProvider.user?.profileImageUrl != null
                  ? NetworkImage(authProvider.user!.profileImageUrl!)
                  : null,
              child: authProvider.user?.profileImageUrl == null
                  ? Text(
                      (authProvider.user?.name ?? 'A')[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        // letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            // 6-Card Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _buildStatCard(
                  title: 'Total Seniors',
                  count: adminProvider.seniorCount.toString(),
                  icon: Icons.accessible_forward,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  title: 'Volunteers',
                  count: adminProvider.volunteerCount.toString(),
                  icon: Icons.volunteer_activism,
                  color: Colors.green,
                ),
                _buildStatCard(
                  title: 'Pending',
                  count: adminProvider.pendingTaskCount.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  title: 'Today\'s Visits',
                  count: adminProvider.todayActiveUsersCount.toString(),
                  icon: Icons.supervised_user_circle_outlined,
                  color: Colors.deepPurple,
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              "Recent Activity",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildActivityLog(adminProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLog(AdminProvider provider) {
    final logs = provider.recentLogs.take(5).toList();
    return Column(
      children: logs.map((log) {
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: _getLogIcon(log['action']),
          title: Text(
            log['details'] ?? '',
            style: const TextStyle(fontSize: 13),
          ),
          subtitle: Text(
            log['timestamp'] != null
                ? DateFormat(
                    'hh:mm a',
                  ).format((log['timestamp'] as Timestamp).toDate())
                : 'Recently',
            style: const TextStyle(fontSize: 11),
          ),
        );
      }).toList(),
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
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
