import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/app_constants.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/task_card.dart';
import 'task_details_screen.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<String> _tabs = ['All', 'Pending', 'In Progress', 'Complete'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  List<TaskEntity> _getFilteredTasks(List<TaskEntity> allTasks, String status) {
    if (status == 'All') {
      return allTasks;
    }

    if (status == 'Complete') {
      return allTasks
          .where((t) => t.status == 'Completed' || t.status == 'Complete')
          .toList();
    }
    return allTasks.where((t) => t.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Task List',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () {
            // If pushed directly like from a quick action card
            Navigator.maybePop(context);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 16,
              right: 16,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 40),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade700,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 24),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                dividerColor: Colors.transparent,
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box('tasks').listenable(),
              builder: (context, box, _) {
                final userTasksRaw = box.keys
                    .map((key) {
                      final val = box.get(key);
                      Map<String, dynamic> mapVal = {};
                      if (val is Map) {
                        mapVal = val.map((k, v) => MapEntry(k.toString(), v));
                      }
                      return {'key': key, ...mapVal};
                    })
                    .where(
                      (e) =>
                          e['userId'] == context.read<AuthProvider>().user?.id,
                    )
                    .toList();

                if (userTasksRaw.isEmpty) {
                  return _buildEmptyState();
                }

                // Sort locally by createdAt
                userTasksRaw.sort((a, b) {
                  final tA = a['createdAt'] as String?;
                  final tB = b['createdAt'] as String?;
                  if (tA == null || tB == null) return 0;
                  return DateTime.tryParse(
                        tB,
                      )?.compareTo(DateTime.tryParse(tA) ?? DateTime.now()) ??
                      0;
                });

                final allTasks = userTasksRaw.map((data) {
                  final dateStr = data['scheduledAt'] as String?;
                  return TaskEntity(
                    id: data['key'].toString(),
                    title: data['title'] ?? data['category'] ?? 'Task',
                    date: dateStr != null
                        ? DateTime.tryParse(dateStr) ?? DateTime.now()
                        : DateTime.now(),
                    status: data['status'] ?? 'Pending',
                    imageUrl:
                        (data['imageUrl'] != null &&
                            data['imageUrl'].toString().isNotEmpty)
                        ? data['imageUrl']
                        : 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=500&q=60',
                    category: data['category'] ?? 'Other',
                    description: data['notes'] ?? '',
                    location: data['location'] ?? 'Unknown location',
                  );
                }).toList();

                return TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tabName) {
                    final tasks = _getFilteredTasks(allTasks, tabName);
                    if (tasks.isEmpty) {
                      return _buildEmptyState(
                        message: 'No $tabName tasks found',
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: 80,
                      ),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return TaskCard(
                          task: tasks[index],
                          onDelete: () async {
                            try {
                              int keyInt = int.parse(tasks[index].id);
                              await Hive.box('tasks').delete(keyInt);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Task deleted successfully'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to delete task'),
                                  ),
                                );
                              }
                            }
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TaskDetailsScreen(task: tasks[index]),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({String message = 'No tasks available'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 60,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
