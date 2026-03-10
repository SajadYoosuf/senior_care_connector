import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../core/app_constants.dart';
import '../../providers/auth_provider.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('help_requests')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data.containsKey('volunteerId') &&
                data['volunteerId'] != null;
          }).toList();

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No active chats.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final taskId = docs[index].id;
              final taskTitle = data['title'] ?? 'Task';

              final volunteerId = data['volunteerId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(volunteerId)
                    .get(),
                builder: (context, userSnapshot) {
                  String volunteerName = 'Volunteer';
                  if (userSnapshot.hasData &&
                      userSnapshot.data != null &&
                      userSnapshot.data!.exists) {
                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    volunteerName = userData['name'] ?? 'Volunteer';
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      radius: 28,
                      child: Text(
                        volunteerName.isNotEmpty
                            ? volunteerName[0].toUpperCase()
                            : 'V',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      volunteerName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Task: $taskTitle',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            taskId: taskId,
                            currentUserId: currentUserId,
                            userName: volunteerName,
                            userAvatar: '',
                            recipientId: volunteerId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
