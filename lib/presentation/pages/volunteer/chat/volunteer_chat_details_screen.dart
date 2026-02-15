import 'package:flutter/material.dart';
import '../../../../core/app_constants.dart';
import '../../../../domain/entities/message_entity.dart';
import '../contact/volunteer_contact_screen.dart';

class VolunteerChatDetailsScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;

  const VolunteerChatDetailsScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
  });

  @override
  State<VolunteerChatDetailsScreen> createState() =>
      _VolunteerChatDetailsScreenState();
}

class _VolunteerChatDetailsScreenState
    extends State<VolunteerChatDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<MessageEntity> _messages = [
    MessageEntity(
      id: '1',
      text:
          'Hello! im here to help you today.do you need assistance with your groceries',
      isMe: true, // Volunteer is "Me" now
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      senderName: 'Me',
      senderAvatar: 'https://i.pravatar.cc/150?img=12', // Volunteer avatar
    ),
    MessageEntity(
      id: '2',
      text: 'Yes, please.i’ve sent a list.',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 4)),
      senderName: 'Phillip Lipshutz',
      senderAvatar: 'https://i.pravatar.cc/150?img=11', // Senior avatar
    ),
    MessageEntity(
      id: '3',
      text: 'I see it. i’ll be there in 20 minutes to pick them up',
      isMe: true,
      time: DateTime.now().subtract(const Duration(minutes: 3)),
      senderName: 'Me',
      senderAvatar: 'https://i.pravatar.cc/150?img=12',
    ),
    MessageEntity(
      id: '4',
      text: 'Okk',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 1)),
      senderName: 'Phillip Lipshutz',
      senderAvatar: 'https://i.pravatar.cc/150?img=11',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.userAvatar),
              radius: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Available Now',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VolunteerContactScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.call, size: 16, color: Colors.white),
              label: const Text('Call', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Today',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageEntity message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              backgroundImage: NetworkImage(message.senderAvatar),
              radius: 16,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isMe ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isMe ? 20 : 4),
                  bottomRight: Radius.circular(message.isMe ? 4 : 20),
                ),
                boxShadow: [
                  if (!message.isMe)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isMe ? Colors.white : AppColors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (message.isMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              // Current User (Volunteer)
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
              radius: 16,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.white)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.camera_alt, color: Colors.blueGrey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  setState(() {
                    _messages.add(
                      MessageEntity(
                        id: DateTime.now().toString(),
                        text: _messageController.text,
                        isMe: true,
                        time: DateTime.now(),
                        senderName: 'Me',
                        senderAvatar:
                            'https://i.pravatar.cc/150?img=12', // Volunteer avatar
                      ),
                    );
                    _messageController.clear();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
