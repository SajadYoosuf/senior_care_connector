import 'package:flutter/material.dart';
import '../../../../core/app_constants.dart';
import '../../../../agora_logic.dart';

class VolunteerContactScreen extends StatelessWidget {
  final String userName;
  final String channelName;
  final String userAvatar;

  const VolunteerContactScreen({
    super.key,
    required this.userName,
    required this.channelName,
    this.userAvatar = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Contact',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // Profile pic
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      userAvatar.isNotEmpty
                          ? userAvatar
                          : 'https://i.pravatar.cc/150?u=$userName',
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.volunteer_activism,
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Community Member',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Ready to connect with ${userName.split(' ')[0]}?',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 30),

          // Big Call Button
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoCallScreen(
                        channelName: channelName,
                        isAudioOnly: true,
                      ),
                    ),
                  );
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.call, size: 40, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      'Call Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'This call will connect you directly to their primary line\nvia the community app',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const Spacer(),

          // Bottom Options Card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOptionItem(
                  context,
                  Icons.message,
                  'Message',
                  Colors.blue,
                  onTap: () => Navigator.pop(context),
                ),
                _buildOptionItem(
                  context,
                  Icons.videocam,
                  'Video Call',
                  Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCallScreen(
                          channelName: channelName,
                          isAudioOnly: false,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'calls are routed through our secure system to protect privacy',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
