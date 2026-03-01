import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _taskRepository;

  TaskProvider(this._taskRepository);

  List<TaskEntity> _nearbyTasks = [];
  List<TaskEntity> get nearbyTasks => _nearbyTasks;

  List<TaskEntity> _myTasks = [];
  List<TaskEntity> get myTasks => _myTasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> createTask(TaskEntity task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _taskRepository.createTask(task);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNearbyTasks(double lat, double lng, double radiusKm) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _nearbyTasks = await _taskRepository.getNearbyTasks(lat, lng, radiusKm);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyTasks(String volunteerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _myTasks = await _taskRepository.getMyTasks(volunteerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptTask(String taskId, String volunteerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _taskRepository.acceptTask(taskId, volunteerId);
      // Remove from nearby, it will be fetched in My Tasks
      _nearbyTasks.removeWhere((t) => t.id == taskId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeTask(String taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _taskRepository.completeTask(taskId);
      _myTasks.removeWhere((t) => t.id == taskId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<TaskEntity>> watchNearbyTasks(
    double lat,
    double lng,
    double radiusKm,
  ) {
    return _taskRepository.watchNearbyTasks(lat, lng, radiusKm);
  }
}
