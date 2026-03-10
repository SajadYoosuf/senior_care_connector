import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_constants.dart';
import '../../../../data/repositories/activity_log_repository.dart';

class AdminSeniorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> senior;
  final ActivityLogRepository _activityLogRepository = ActivityLogRepository();

  AdminSeniorDetailsScreen({super.key, required this.senior});

  @override
  Widget build(BuildContext context) {
    final String seniorId = senior['id'] ?? '';
    final String name = senior['name'] ?? 'Senior';
    final String status = senior['status'] ?? 'Active';
    final String age = senior['age']?.toString() ?? 'N/A';
    final String dob = senior['dob'] ?? 'N/A';
    final String phone = senior['phone'] ?? 'N/A';
    final String address = senior['address'] ?? 'N/A';
    final String emergencyContact = senior['emergencyContact'] ?? 'N/A';
    final String emergencyPhone = senior['emergencyPhone'] ?? 'N/A';
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Senior Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Profile Header
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 5,
                  bottom: 5,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: status.toLowerCase().contains('high')
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: status.toLowerCase().contains('high')
                      ? Colors.red
                      : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Message'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Update care'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey.shade200),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Personal Information
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personal information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.assignment_ind_outlined,
                    title: 'Age / Dob',
                    value: '$age years ($dob)',
                  ),
                  const Divider(height: 32),
                  _buildInfoRow(
                    icon: Icons.phone_outlined,
                    title: 'Phone Number',
                    value: phone,
                  ),
                  const Divider(height: 32),
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    title: 'Address',
                    value: address,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Emergency Number
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Emergency number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_pin_outlined,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emergencyContact,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          emergencyPhone,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Safety Timeline
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Safety Timeline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _activityLogRepository.getSeniorLogs(seniorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: const Center(
                      child: Text(
                        'No safety logs recorded for this senior.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final logs = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final timestamp = log['timestamp'] as Timestamp?;
                    final dateStr = timestamp != null
                        ? DateFormat(
                            'MMM d, hh:mm a',
                          ).format(timestamp.toDate())
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
                        children: [
                          _getLogIcon(log['action']),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log['details'] ?? 'Activity',
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
                          ),
                        ],
                      ),
                    );
                  },
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

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.grey, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
