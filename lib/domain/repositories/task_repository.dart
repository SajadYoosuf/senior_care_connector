import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasks();
  Future<TaskEntity?> getTaskById(String id);
  Future<String> createTask(TaskEntity task);
  Future<List<TaskEntity>> getNearbyTasks(
    double lat,
    double lng,
    double radiusKm,
  );
  Future<void> acceptTask(String taskId, String volunteerId);
  Future<void> completeTask(String taskId);
  Future<List<TaskEntity>> getMyTasks(String volunteerId);
  Future<List<TaskEntity>> getRequesterTasks(String requesterId);
  Stream<List<TaskEntity>> watchNearbyTasks(
    double lat,
    double lng,
    double radiusKm,
  );
}
