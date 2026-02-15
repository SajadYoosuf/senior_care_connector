import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';
import '../../../domain/entities/volunteer_entity.dart';
import '../../../data/repositories/mock_volunteer_repository.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final MockVolunteerRepository _repository = MockVolunteerRepository();
  List<VolunteerEntity> _volunteers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final volunteers = await _repository.getVolunteers();
    if (mounted) {
      setState(() {
        _volunteers = volunteers;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _volunteers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final volunteer = _volunteers[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(volunteer.imageUrl),
                    radius: 28,
                  ),
                  title: Text(
                    volunteer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Tap to chat...', // Placeholder last message
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  trailing: const Text(
                    '9:41 AM', // Placeholder time
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          userName: volunteer.name,
                          userAvatar: volunteer.imageUrl,
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
