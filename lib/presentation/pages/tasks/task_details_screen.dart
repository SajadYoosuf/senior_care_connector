import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/app_constants.dart';
import '../../../domain/entities/task_entity.dart';
import 'add_task_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskEntity task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.task.status;
    if (_currentStatus != 'Pending' &&
        _currentStatus != 'In Progress' &&
        _currentStatus != 'Completed' &&
        _currentStatus != 'Complete') {
      _currentStatus = 'Pending';
    }
    if (_currentStatus == 'Complete') {
      _currentStatus = 'Completed';
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _currentStatus = newStatus);

    try {
      int keyInt = int.parse(widget.task.id);
      final box = Hive.box('tasks');
      final currentData = box.get(keyInt);

      if (currentData != null) {
        Map<String, dynamic> mapData = {};
        if (currentData is Map) {
          mapData = currentData.map((k, v) => MapEntry(k.toString(), v));
        }

        mapData['status'] = newStatus;
        await box.put(keyInt, mapData);
      }
    } catch (e) {
      debugPrint('Failed to update status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Task Details',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // ignore: deprecated_member_use
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddTaskScreen(taskToEdit: widget.task),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            Stack(
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Builder(
                    builder: (context) {
                      if (widget.task.imageUrl.isEmpty) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      }
                      if (widget.task.imageUrl.startsWith('http')) {
                        return Image.network(
                          widget.task.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                  ),
                                ),
                              ),
                        );
                      }
                      try {
                        return Image.memory(
                          base64Decode(widget.task.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                  ),
                                ),
                              ),
                        );
                      } catch (e) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      }
                    },
                  ),
                ),
                // Status Pill
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _currentStatus == 'Completed'
                          ? Colors.green
                          : Colors.blue,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      _currentStatus.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.task.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags (Category & Date)
                  Row(
                    children: [
                      _buildTag(
                        icon: Icons.shopping_cart,
                        label: widget.task.category,
                        color: Colors.blue.shade50,
                        textColor: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildTag(
                        icon: Icons.calendar_month,
                        label: DateFormat(
                          'EEEE h:mma',
                        ).format(widget.task.date),
                        color: Colors.blue.shade50,
                        textColor: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Status Dropdown Modifier
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Task Status:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        const Spacer(),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _currentStatus,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.primary,
                            ),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            items: ['Pending', 'In Progress', 'Completed']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (newVal) {
                              if (newVal != null) {
                                _updateStatus(newVal);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    widget.task.description.isEmpty
                        ? 'No notes provided.'
                        : widget.task.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
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
