import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/reminder_entity.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

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
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder(
              valueListenable: Hive.box('tasks').listenable(),
              builder: (context, boxTasks, _) {
                return ValueListenableBuilder(
                  valueListenable: Hive.box('medicines').listenable(),
                  builder: (context, boxMed, _) {
                    final List<ReminderEntity> reminders = [];

                    final userTasks = boxTasks.values
                        .where((e) => e is Map && e['userId'] == user.id)
                        .toList();
                    final userMeds = boxMed.values
                        .where((e) => e is Map && e['userId'] == user.id)
                        .toList();

                    for (var task in userTasks) {
                      final t = task as Map;
                      var timeStr = 'Any time';
                      if (t['scheduledAt'] != null) {
                        try {
                          final dt = DateTime.parse(t['scheduledAt']);
                          timeStr =
                              '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                        } catch (_) {}
                      }
                      reminders.add(
                        ReminderEntity(
                          id: t['createdAt'].toString(),
                          title: t['title'] ?? 'Task',
                          subtitle: t['notes'] != null && t['notes'].isNotEmpty
                              ? t['notes']
                              : timeStr,
                          time: timeStr,
                          isCompleted: t['status'] == 'Completed',
                          type: 'Task',
                        ),
                      );
                    }

                    for (var med in userMeds) {
                      final m = med as Map;
                      reminders.add(
                        ReminderEntity(
                          id: m['createdAt'].toString(),
                          title: 'Take ${m['name'] ?? 'medicine'}',
                          subtitle: '${m['frequency']} . ${m['time']}',
                          time: m['time'] ?? '',
                          isCompleted:
                              false, // Medicines are tracked via activity logs
                          type: 'pill',
                        ),
                      );
                    }

                    int completedCount = reminders
                        .where((r) => r.isCompleted)
                        .length;
                    double progress = reminders.isEmpty
                        ? 0.0
                        : completedCount / reminders.length;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          const Text(
                            'Upcoming Reminders',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (reminders.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'No tasks remaining for today.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...reminders.map(
                              (reminder) => _buildReminderCard(reminder),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
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
              image: null,
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
