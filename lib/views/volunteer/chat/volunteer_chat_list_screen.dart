// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';
// import 'package:senior_care/core/app_constants.dart';
// import 'package:senior_care/viewmodels/auth_viewmodel.dart';
// import 'package:senior_care/views/volunteer/chat/volunteer_chat_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:senior_care/core/app_constants.dart';
import 'package:senior_care/viewmodels/auth_viewmodel.dart';
import 'package:senior_care/views/volunteer/chat/volunteer_chat_details_screen.dart';

class VolunteerChatListScreen extends StatefulWidget {
  const VolunteerChatListScreen({super.key});

  @override
  State<VolunteerChatListScreen> createState() =>
      _VolunteerChatListScreenState();
}

class _VolunteerChatListScreenState extends State<VolunteerChatListScreen> {
  // Mock data for seniors/needy
  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthViewModel>().user?.id ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Chat',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('help_requests')
            .where('volunteerId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data!.docs;
          final Set<String> seenUsers = {};
          final List<QueryDocumentSnapshot> docs = [];

          for (var doc in allDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final requesterId = data['userId'] as String? ?? '';
            if (requesterId.isNotEmpty && !seenUsers.contains(requesterId)) {
              seenUsers.add(requesterId);
              docs.add(doc);
            }
          }

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No active chats.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: docs.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 80),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final taskId = docs[index].id;
              final taskTitle = data['title'] ?? 'Task';
              final requesterId = data['userId'] ?? '';
              final requesterName = data['userName'] ?? 'Senior User';
              final requesterPhoto = data['requesterPhoto'] ?? '';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child:
                      requesterPhoto.isNotEmpty &&
                          requesterPhoto.startsWith('http')
                      ? null
                      : Text(
                          requesterName[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  backgroundImage:
                      requesterPhoto.isNotEmpty &&
                          requesterPhoto.startsWith('http')
                      ? NetworkImage(requesterPhoto)
                      : null,
                ),
                title: Text(
                  requesterName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Task: $taskTitle',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VolunteerChatDetailsScreen(
                        taskId: taskId,
                        currentUserId: currentUserId,
                        userName: requesterName,
                        userAvatar: requesterPhoto,
                        recipientId: requesterId,
                      ),
                    ),
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
