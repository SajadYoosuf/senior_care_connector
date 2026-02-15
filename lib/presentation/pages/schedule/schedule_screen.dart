import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';
import '../../../domain/entities/reminder_entity.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final List<ReminderEntity> reminders = [
      const ReminderEntity(
        id: '1',
        title: 'Take blood pressure pill',
        subtitle: '1 Tablet . 8:00 AM',
        time: '8:00 AM', // not strictly used in loop if subtitle used
        isCompleted: true,
        type: 'pill',
      ),
      const ReminderEntity(
        id: '2',
        title: 'Visit sarah',
        subtitle: 'Arrival at 3:00 PM',
        time: '3:00 PM',
        isCompleted: false,
        type: 'visit',
      ),
      const ReminderEntity(
        id: '3',
        title: 'Afternoon lunch',
        subtitle: 'Prepare salad . 1:00 PM',
        time: '1:00 PM',
        isCompleted: false,
        type: 'food',
      ),
      const ReminderEntity(
        id: '4',
        title: 'Check blood sugar',
        subtitle: '1 Tablet . 8:00 AM',
        time: '8:00 AM',
        isCompleted: false,
        type: 'checkup',
      ),
    ];

    int completedCount = reminders.where((r) => r.isCompleted).length;
    double progress = completedCount / reminders.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Today\'s Schedule',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: AppColors.black,
            ),
            onPressed: () {
              // This might be main tab, check back button behavior
              // If it's a tab, back button logic might differ
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Progress
            const Text(
              'Daily Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${reminders.length - completedCount} tasks remaining for today',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  '$completedCount of ${reminders.length}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 32),

            // Upcoming Reminders
            const Text(
              'Upcoming Reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 16),
            ...reminders.map((reminder) => _buildReminderCard(reminder)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: SafeArea(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // Call support
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.call, size: 20),
                SizedBox(width: 8),
                Text(
                  'Call for support',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(ReminderEntity reminder) {
    IconData icon;
    Color iconColor;
    Color iconBgColor;

    switch (reminder.type) {
      case 'pill':
        icon = Icons.medication;
        iconColor = Colors.blue;
        iconBgColor = Colors.blue.shade50;
        break;
      case 'visit':
        icon = Icons.person; // Or update with image if available
        iconColor = Colors.blue; // Placeholder, design uses image
        iconBgColor = Colors.transparent;
        break;
      case 'food':
        icon = Icons.restaurant;
        iconColor = Colors.orange;
        iconBgColor = Colors.orange.shade50;
        break;
      case 'checkup':
        icon = Icons.medical_services;
        iconColor = Colors.purple;
        iconBgColor = Colors.purple.shade50;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
        iconBgColor = Colors.grey.shade100;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Subtle shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
              image: (reminder.type == 'visit')
                  ? const DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/150?img=5'),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (reminder.type == 'visit')
                ? null
                : Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
