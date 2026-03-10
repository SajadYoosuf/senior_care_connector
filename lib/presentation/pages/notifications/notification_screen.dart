import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/app_constants.dart';
import '../../providers/auth_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().user?.id ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll notify you when something important happens.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Notification';
              final body = data['body'] ?? '';
              final timestamp = data['timestamp'] as Timestamp?;
              final isRead = data['read'] ?? false;
              final type = data['type'] ?? 'info';

              IconData icon = Icons.notifications;
              Color color = AppColors.primary;

              if (type == 'sos') {
                icon = Icons.warning_amber_rounded;
                color = Colors.red;
              } else if (type == 'task') {
                icon = Icons.assignment_turned_in;
                color = Colors.green;
              } else if (type == 'chat') {
                icon = Icons.chat_bubble_outline;
                color = Colors.blue;
              }

              String timeStr = 'Just now';
              if (timestamp != null) {
                final dt = timestamp.toDate();
                timeStr =
                    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: isRead
                      ? null
                      : Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                          width: 1,
                        ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.black,
                                ),
                              ),
                              Text(
                                timeStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            body,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isRead)
                      Container(
                        margin: const EdgeInsets.only(left: 8, top: 4),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
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
}
