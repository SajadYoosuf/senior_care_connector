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
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics Row
            _buildAnalyticsRow(adminProvider),
            const SizedBox(height: 24),

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
                  title: 'Completed',
                  count: adminProvider.completedTaskCount.toString(),
                  icon: Icons.task_alt,
                  color: Colors.teal,
                ),
                _buildStatCard(
                  title: 'Medicine Pres.',
                  count: adminProvider.medicineReminderCount.toString(),
                  icon: Icons.medication,
                  color: Colors.purple,
                ),
                _buildStatCard(
                  title: 'SOS Alerts',
                  count: adminProvider.activeSOSAlerts.length.toString(),
                  icon: Icons.emergency,
                  color: adminProvider.activeSOSAlerts.isNotEmpty
                      ? Colors.red
                      : Colors.grey,
                ),
              ],
            ),

            if (adminProvider.activeSOSAlerts.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildSectionHeader('🚨 ACTIVE SOS ALERTS', Colors.red),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: adminProvider.activeSOSAlerts.length,
                itemBuilder: (context, index) {
                  final sos = adminProvider.activeSOSAlerts[index];
                  return _buildSOSCard(sos);
                },
              ),
            ],

            const SizedBox(height: 32),
            _buildSectionHeader('Recent Help Requests', Colors.black87),
            const SizedBox(height: 12),
            _buildRecentRequests(context, adminProvider),

            const SizedBox(height: 32),
            _buildSectionHeader('System Activity Log', Colors.black87),
            const SizedBox(height: 12),
            _buildActivityLog(adminProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsRow(AdminProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAnalyticItem(
            'Completion Rate',
            '${((provider.completedTaskCount / (provider.helpRequests.length == 0 ? 1 : provider.helpRequests.length)) * 100).toInt()}%',
          ),
          Container(width: 1, height: 24, color: Colors.grey.shade300),
          _buildAnalyticItem(
            'Total Tasks',
            provider.helpRequests.length.toString(),
          ),
          Container(width: 1, height: 24, color: Colors.grey.shade300),
          _buildAnalyticItem(
            'Today Visits',
            provider.todayVisitCount.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        ),
      ],
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

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
    );
  }

  Widget _buildSOSCard(Map<String, dynamic> sos) {
    return Card(
      color: Colors.red.shade50,
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
          sos['userName'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('EMERGENCY - Senior triggered SOS'),
        trailing: IconButton(
          icon: const Icon(Icons.location_on, color: Colors.red),
          onPressed: () async {
            final url = sos['locationUrl'];
            if (url != null) await launchUrl(Uri.parse(url));
          },
        ),
      ),
    );
  }

  Widget _buildRecentRequests(BuildContext context, AdminProvider provider) {
    // Show top 6 requests, prioritize 'Pending' (Unassigned)
    final allRequests = List<Map<String, dynamic>>.from(provider.helpRequests);
    allRequests.sort((a, b) {
      if (a['status'] == 'Pending' && b['status'] != 'Pending') return -1;
      if (a['status'] != 'Pending' && b['status'] == 'Pending') return 1;
      return 0;
    });

    final recent = allRequests.take(6).toList();
    if (recent.isEmpty) return const Center(child: Text('No requests yet'));

    return Column(
      children: recent.map((req) {
        return GestureDetector(
          onTap: req['status'] == 'Pending'
              ? () => _showAssignSheet(context, req['id'], provider)
              : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                _buildCategoryIcon(req['category']),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req['title'] ?? 'Request',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        req['userName'] ?? 'Senior',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSmallStatusBadge(req['status']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAssignSheet(
    BuildContext context,
    String requestId,
    AdminProvider adminProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final volunteers = adminProvider.volunteers
            .where((v) => v['isApproved'] == true && v['isActive'] != false)
            .toList();

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Assign Volunteer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Text(
                'Select an approved volunteer to assign this task.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              if (volunteers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('No active volunteers available.')),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: volunteers.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final v = volunteers[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            (v['name'] ?? 'V')[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          v['name'] ?? 'Volunteer',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Approved & Active',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            adminProvider.assignVolunteer(requestId, v['id']);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Volunteer assigned and notified!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Assign'),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryIcon(String? category) {
    IconData icon;
    switch (category?.toLowerCase()) {
      case 'medical':
        icon = Icons.medical_services;
        break;
      case 'grocery':
        icon = Icons.shopping_basket;
        break;
      case 'companionship':
        icon = Icons.favorite;
        break;
      default:
        icon = Icons.help_outline;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: AppColors.primary),
    );
  }

  Widget _buildSmallStatusBadge(String? status) {
    Color color = status == 'Pending'
        ? Colors.orange
        : (status == 'Accepted' ? Colors.blue : Colors.green);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status == 'Pending' ? 'Unassigned' : (status ?? '?'),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
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

  void _showBroadcastDialog(BuildContext context, AdminProvider provider) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Broadcast Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This message will be sent as a push notification to all volunteers.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title (e.g. Emergency)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message Body',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.broadcastAlert(
                titleController.text,
                bodyController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Broadcast sent successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Broadcast'),
          ),
        ],
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
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
