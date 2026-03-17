import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_constants.dart';
import '../../../providers/admin_provider.dart';

class AdminVolunteerDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> volunteer;
  const AdminVolunteerDetailsScreen({super.key, required this.volunteer});

  @override
  Widget build(BuildContext context) {
    final String name = volunteer['name'] ?? 'Volunteer';
    final String email = volunteer['email'] ?? 'N/A';
    final String phone = volunteer['phone'] ?? 'N/A';
    final String status = volunteer['status'] ?? 'Active';
    final String photoUrl =
        volunteer['profileImageUrl'] ??
        'https://i.pravatar.cc/150?u=${volunteer['id']}';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Volunteer Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Profile Header
            CircleAvatar(radius: 60, backgroundImage: NetworkImage(photoUrl)),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: status.toLowerCase() == 'pending'
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: status.toLowerCase() == 'pending'
                      ? Colors.red
                      : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                if (!(volunteer['isApproved'] == true))
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<AdminProvider>().approveVolunteer(volunteer['id']);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Approve Volunteer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<AdminProvider>().toggleVolunteerStatus(volunteer['id'], !(volunteer['isActive'] != false));
                        Navigator.pop(context);
                      },
                      icon: Icon(volunteer['isActive'] != false ? Icons.block : Icons.replay),
                      label: Text(volunteer['isActive'] != false ? 'Deactivate Account' : 'Reactivate Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: volunteer['isActive'] != false ? Colors.red : Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),

            // Communication Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Direct Communication',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCommButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                  color: Colors.blue,
                  onTap: () {
                    // Navigate to ChatDetailScreen
                  },
                ),
                _buildCommButton(
                  icon: Icons.phone_outlined,
                  label: 'Voice',
                  color: Colors.green,
                  onTap: () {
                    // Logic for Voice Call (Agora)
                  },
                ),
                _buildCommButton(
                  icon: Icons.video_call_outlined,
                  label: 'Video',
                  color: Colors.purple,
                  onTap: () {
                    // Logic for Video Call (Agora)
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Contact information
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contact information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.email_outlined,
                    title: 'Email Address',
                    value: email,
                  ),
                  const Divider(height: 32),
                  _buildInfoRow(
                    icon: Icons.phone_outlined,
                    title: 'Phone Number',
                    value: phone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Skills/Tags
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildSkillTag('Medical assistance'),
                _buildSkillTag('Driver'),
                _buildSkillTag('CPR certified'),
                _buildSkillTag('First Aid'),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFFEFF3F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.black54, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillTag(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCommButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
