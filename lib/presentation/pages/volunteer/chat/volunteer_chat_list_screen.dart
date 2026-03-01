import 'package:flutter/material.dart';
import '../../../../core/app_constants.dart';
import 'volunteer_chat_details_screen.dart';

class VolunteerChatListScreen extends StatefulWidget {
  const VolunteerChatListScreen({super.key});

  @override
  State<VolunteerChatListScreen> createState() =>
      _VolunteerChatListScreenState();
}

class _VolunteerChatListScreenState extends State<VolunteerChatListScreen> {
  // Mock data for seniors/needy
  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Lincoln Workman',
      'message': 'HELLO',
      'image': 'https://i.pravatar.cc/150?img=11',
      'status': 'seen',
    },
    {
      'name': 'Gustavo Dias',
      'message': 'HELLO',
      'image': 'https://i.pravatar.cc/150?img=5',
      'status': 'seen',
    },
    {
      'name': 'Jocelyn Schleifer',
      'message': 'HELLO',
      'image': 'https://i.pravatar.cc/150?img=3',
      'status': 'seen',
    },
    {
      'name': 'Rayna Dias',
      'message': 'HELLO',
      'image': 'https://i.pravatar.cc/150?img=9',
      'status': 'seen',
    },
    {
      'name': 'Leo Bergson',
      'message': 'HELLO',
      'image': 'https://i.pravatar.cc/150?img=8',
      'status': 'seen',
    },
    {
      'name': 'Justin Geidt',
      'message': 'HELLO',
      'image': 'https://i.pravatar.cc/150?img=2',
      'status': 'seen',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'chat',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: _chats.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 80),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(chat['image']),
            ),
            title: Text(
              chat['name'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.done_all, size: 16, color: Colors.blue.shade400),
                const SizedBox(width: 4),
                Text(
                  chat['message'],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VolunteerChatDetailsScreen(
                    userName: chat['name'],
                    userAvatar: chat['image'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
