import 'package:flutter/material.dart';
import '../../../../core/app_constants.dart';
import '../../../../domain/entities/task_entity.dart';
import 'volunteer_task_details_screen.dart';

class VolunteerTaskListScreen extends StatefulWidget {
  const VolunteerTaskListScreen({super.key});

  @override
  State<VolunteerTaskListScreen> createState() =>
      _VolunteerTaskListScreenState();
}

class _VolunteerTaskListScreenState extends State<VolunteerTaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<TaskEntity> _tasks = [
    TaskEntity(
      id: '1',
      title: 'Grocery delivery',
      date: DateTime.now().add(const Duration(days: 1)),
      status: 'Pending',
      imageUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=500&q=60',
      category: 'Shopping',
      description:
          'Looking for someone to help pick up a weekly grocery list...',
      location: 'Central Market .2nd street',
    ),
    TaskEntity(
      id: '2',
      title: 'Tech Support for john',
      date: DateTime.now().add(const Duration(days: 2)),
      status: 'Pending',
      imageUrl:
          'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=500&q=60', // Placeholder
      category: 'Tech',
      description: 'Need help setting up a new tablet and printer.',
      location: 'North Market .2nd street',
    ),
    TaskEntity(
      id: '3',
      title: 'Garden maintenance',
      date: DateTime.now().add(const Duration(days: 3)),
      status: 'Pending',
      imageUrl:
          'https://images.unsplash.com/photo-1557429287-b2e26467fc2b?auto=format&fit=crop&w=500&q=60', // Placeholder
      category: 'Gardening',
      description: 'Weeding and watering the backyard garden.',
      location: 'South Park .5th avenue',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Request Help', // Matching the image title "Request Help" even though it's "Available Tasks" logically
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
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
            onPressed: () {
              // Handle back logic or if it's a main tab, maybe nothing or switch tab
            },
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'In progress'), // lowercase 'p' in image
                Tab(text: 'Complete'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Available community task',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(_tasks), // All
                _buildTaskList(
                  _tasks.where((t) => t.status == 'Pending').toList(),
                ), // Pending
                _buildTaskList(
                  _tasks.where((t) => t.status == 'In Progress').toList(),
                ), // In progress
                _buildTaskList(
                  _tasks.where((t) => t.status == 'Completed').toList(),
                ), // Complete
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<TaskEntity> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildVolunteerTaskCard(tasks[index]);
      },
    );
  }

  Widget _buildVolunteerTaskCard(TaskEntity task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                task.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.blue.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'feb 03 2026 3:00 pm', // Mock date format
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.blue.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.location,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue.shade600, // Slightly simpler blue
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VolunteerTaskDetailsScreen(task: task),
                        ),
                      );
                    },
                    child: const Text(
                      'Accept Task',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
