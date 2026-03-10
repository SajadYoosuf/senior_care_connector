import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_constants.dart';
import '../../../../core/app_localizations.dart';
import '../../../../domain/entities/task_entity.dart';
import '../contact/volunteer_contact_screen.dart';
import '../chat/volunteer_chat_details_screen.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/task_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../data/repositories/activity_log_repository.dart';

class VolunteerTaskDetailsScreen extends StatefulWidget {
  final TaskEntity task;

  VolunteerTaskDetailsScreen({super.key, required this.task});

  @override
  State<VolunteerTaskDetailsScreen> createState() =>
      _VolunteerTaskDetailsScreenState();
}

class _VolunteerTaskDetailsScreenState
    extends State<VolunteerTaskDetailsScreen> {
  final ActivityLogRepository _activityLogRepository = ActivityLogRepository();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.viewDetails,
          style: const TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Requester Profile
            Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    widget.task.requesterName.isNotEmpty
                        ? widget.task.requesterName[0].toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.task.requesterName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  l10n.verifiedMember,
                  style: TextStyle(color: Colors.blue.shade400, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.blue.shade400,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.task.location,
                        style: TextStyle(
                          color: Colors.blue.shade400,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Task Info Card
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildTag(
                        _getCategoryIcon(widget.task.category),
                        widget.task.category,
                        Colors.blue.shade50,
                        Colors.blue,
                      ),
                      _buildTag(
                        Icons.calendar_today,
                        DateFormat('MMM dd, h:mm a').format(widget.task.date),
                        Colors.blue.shade50,
                        Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.task.description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Location Card
            GestureDetector(
              onTap: () async {
                final lat = widget.task.latitude;
                final lng = widget.task.longitude;
                Uri uri;
                if (lat != null && lng != null) {
                  uri = Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                  );
                } else {
                  uri = Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.task.location)}',
                  );
                }

                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  debugPrint('Could not launch \$uri: \$e');
                }
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Area Location',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.task.location,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map,
                            color: Colors.blue.shade300,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tap to Open in Google Maps',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100), // Spacing
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: AppColors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VolunteerContactScreen(
                        userName: widget.task.requesterName ?? 'Senior',
                        channelName: 'task_${widget.task.id}',
                        userAvatar:
                            'https://i.pravatar.cc/150?u=${widget.task.requesterId}',
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: AppColors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final userId = context.read<AuthProvider>().user?.id ?? '';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VolunteerChatDetailsScreen(
                        taskId: widget.task.id,
                        currentUserId: userId,
                        userName: widget.task.requesterName,
                        userAvatar: '',
                        recipientId: widget.task.requesterId,
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.chat_bubble_outline),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Consumer<TaskProvider>(
                builder: (context, taskProvider, _) {
                  final isAccepted =
                      widget.task.status == 'Accepted' ||
                      widget.task.status == 'In Progress';
                  final isCompleted =
                      widget.task.status == 'Completed' ||
                      widget.task.status == 'Complete';

                  if (isCompleted) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Task Completed',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAccepted ? Colors.green : Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: taskProvider.isLoading
                        ? null
                        : () async {
                            final auth = context.read<AuthProvider>();
                            if (auth.user == null) return;

                            try {
                              if (isAccepted) {
                                await taskProvider.completeTask(widget.task.id);

                                // Log activity
                                await _activityLogRepository.logActivity(
                                  userId: auth.user!.id,
                                  userName: auth.user!.name,
                                  role: 'volunteer',
                                  action: 'TASK_COMPLETED',
                                  details:
                                      'Completed task: ${widget.task.title}',
                                  targetId: widget.task.id,
                                  targetName: widget.task.title,
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Task completed! Points rewarded.',
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              } else {
                                await taskProvider.acceptTask(
                                  widget.task.id,
                                  auth.user!.id,
                                );

                                // Log activity
                                await _activityLogRepository.logActivity(
                                  userId: auth.user!.id,
                                  userName: auth.user!.name,
                                  role: 'volunteer',
                                  action: 'TASK_ACCEPTED',
                                  details:
                                      'Accepted task: ${widget.task.title}',
                                  targetId: widget.task.id,
                                  targetName: widget.task.title,
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Task accepted! It's now in your list.",
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                    child: taskProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isAccepted ? 'Complete Task' : 'Accept Task',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isAccepted
                                    ? Icons.check_circle
                                    : Icons.arrow_forward,
                                size: 20,
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'grocery delivery':
        return Icons.shopping_cart;
      case 'transportation':
        return Icons.directions_car;
      case 'housekeeping':
        return Icons.cleaning_services;
      case 'companionship':
        return Icons.favorite;
      case 'medical assistance':
        return Icons.medical_services;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildTag(IconData icon, String label, Color color, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
