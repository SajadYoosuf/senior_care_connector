import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_constants.dart';
import '../../../providers/auth_provider.dart';

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _controller = TextEditingController();
  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('support_chats')
        .doc(user.id)
        .collection('messages')
        .add({
          'text': text,
          'isMe': true,
          'timestamp': FieldValue.serverTimestamp(),
          'senderName': user.name,
        });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'Support Team',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text('Online', style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('support_chats')
                  .doc(user.id)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['isMe'] ?? false;
                    final text = data['text'] ?? '';
                    final timestamp = data['timestamp'] as Timestamp?;

                    String timeStr = '';
                    if (timestamp != null) {
                      final dt = timestamp.toDate();
                      timeStr =
                          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                    }

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.primary
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text,
                              style: TextStyle(
                                color: isMe ? Colors.white : AppColors.black,
                                fontSize: 14,
                              ),
                            ),
                            if (timeStr.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                timeStr,
                                style: TextStyle(
                                  color: isMe ? Colors.white70 : Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
