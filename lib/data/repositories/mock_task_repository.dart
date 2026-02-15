import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

class MockTaskRepository implements TaskRepository {
  @override
  Future<List<TaskEntity>> getTasks() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay
    return [
      TaskEntity(
        id: '1',
        title: 'Grocery delivery',
        date: DateTime.now().add(const Duration(days: 1)),
        status: 'Pending',
        imageUrl:
            'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=500&q=60',
        category: 'Shopping',
        description:
            'Looking for someone to help pick up a weekly grocery list from the local market and deliver to Mrs. Higgins residence. The list includes fresh produce and household essentials. Please call before arriving.',
        location: 'Central Market .2nd street',
      ),
      TaskEntity(
        id: '2',
        title: 'Garden maintenance',
        date: DateTime.now().add(const Duration(days: 2)),
        status: 'Pending',
        imageUrl:
            'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?auto=format&fit=crop&w=500&q=60',
        category: 'Gardening',
        description:
            'Need help weeding the front garden and trimming the hedges.',
        location: '123 Maple Avenue',
      ),
      TaskEntity(
        id: '3',
        title: 'Dog walking support',
        date: DateTime.now().subtract(const Duration(hours: 4)),
        status: 'In Progress',
        imageUrl:
            'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=500&q=60',
        category: 'Pet Care',
        description: 'Walk max around the park for 30 minutes.',
        location: 'City Park',
      ),
      TaskEntity(
        id: '4',
        title: 'Medical appointment ride',
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: 'Completed',
        imageUrl:
            'https://images.unsplash.com/photo-1516574187841-69301740b370?auto=format&fit=crop&w=500&q=60',
        category: 'Transport',
        description: 'Ride to Dr. Smiths office for checkup.',
        location: 'Medical Center, Suite 404',
      ),
    ];
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return null; // Implemented when needed
  }
}
