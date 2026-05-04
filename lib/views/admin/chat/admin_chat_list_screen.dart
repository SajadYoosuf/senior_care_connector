import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senior_care/core/app_constants.dart';
import 'package:senior_care/views/admin/chat/admin_support_chat_details_screen.dart';

class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});

  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${time.day}/${time.month}/${time.year}';
  }

  Future fetchFirebaseData() async {
    // try {
    //   // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    //   //     .collection('support_chats')
    //   //     .doc()
    //   //     .collection('messages')
    //   //     .doc()
    //   //     .snapshots();

    //   if (querySnapshot.docs.isNotEmpty) {
    //     String documentId = querySnapshot.docs[0].id;
    //     print("Document ID: $documentId");
    //   } else {
    //     print("No documents found with status 'pending'");
    //   }
    // } catch (e) {
    //   print("error fetching Firebase Data");
    // }
  }

  @override
  void initState() {
    fetchFirebaseData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Support Chats',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('support_chats')
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Firestore Error: ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allChats = snapshot.data?.docs ?? [];
          print('AdminChatListScreen: Total chats found: ${allChats.length}');

          if (allChats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.support_agent,
                      size: 56,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No support chats yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Volunteer support requests will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }


          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: allChats.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, indent: 80, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final chatDoc = allChats[index];
              final volunteerId = chatDoc.id;
              final chatData = chatDoc.data() as Map<String, dynamic>;
              final messageData = {
                'text': chatData['lastMessage'],
                'timestamp': chatData['lastMessageTime'],
              };

              return _SupportChatTile(
                volunteerId: volunteerId,
                messageData: messageData,
                onTap: (name) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminSupportChatDetailsScreen(
                        volunteerId: volunteerId,
                        volunteerName: name,
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

class _SupportChatTile extends StatelessWidget {
  final String volunteerId;
  final Map<String, dynamic> messageData;
  final Function(String) onTap;

  const _SupportChatTile({
    required this.volunteerId,
    required this.messageData,
    required this.onTap,
  });

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    final lastMessage = messageData['text'] as String? ?? '';
    final lastTime = (messageData['timestamp'] as Timestamp?)?.toDate();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(volunteerId)
          .snapshots(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final volunteerName = userData?['name'] as String? ?? 'User';

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('support_chats')
              .doc(volunteerId)
              .snapshots(),
          builder: (context, supportSnapshot) {
            final supportData =
                supportSnapshot.data?.data() as Map<String, dynamic>?;
            final unread = supportData?['unreadByAdmin'] as int? ?? 0;

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    child: Text(
                      volunteerName.isNotEmpty
                          ? volunteerName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      volunteerName,
                      style: TextStyle(
                        fontWeight:
                            unread > 0 ? FontWeight.bold : FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatTime(lastTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: unread > 0
                          ? AppColors.primary
                          : Colors.grey.shade400,
                      fontWeight:
                          unread > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              unread > 0 ? Colors.black54 : Colors.grey.shade400,
                          fontWeight:
                              unread > 0 ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () => onTap(volunteerName),
            );
          },
        );
      },
    );
  }
}
