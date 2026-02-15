import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../data/repositories/mock_task_repository.dart';
import '../../widgets/task_card.dart';
import 'task_details_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MockTaskRepository _repository = MockTaskRepository();
  List<TaskEntity> _allTasks = [];
  bool _isLoading = true;

  final List<String> _tabs = ['All', 'Pending', 'In Progress', 'Complete'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _repository.getTasks();
    if (mounted) {
      setState(() {
        _allTasks = tasks;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TaskEntity> _getFilteredTasks(String status) {
    if (status == 'All') {
      return _allTasks;
    }

    // Basic mapping, in real app match status strings exactly or use enums
    if (status == 'Complete') {
      return _allTasks.where((t) => t.status == 'Completed').toList();
    }
    return _allTasks.where((t) => t.status == status).toList();
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
            // In MainScreen tab, pop might not be desired logic if it is root tab
            // But if pushed, pop works.
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: AppColors.primary,
              ),
              dividerColor: Colors.transparent,
              labelPadding: const EdgeInsets.symmetric(horizontal: 20),
              tabs: _tabs.map((tab) {
                return Tab(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      // border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(alignment: Alignment.center, child: Text(tab)),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: _tabs.map((tabName) {
                      final tasks = _getFilteredTasks(tabName);
                      if (tasks.isEmpty) {
                        return Center(child: Text('No $tabName tasks found'));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          // Add section header "Available community task" for 'All' or just list?
                          // For now just list
                          return TaskCard(
                            task: tasks[index],
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
                  ),
          ),
        ],
      ),
    );
  }
}
