import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

class FirebaseTaskRepository implements TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> createTask(TaskEntity task) async {
    final docRef = await _firestore.collection('tasks').add({
      'title': task.title,
      'date': Timestamp.fromDate(task.date),
      'status': 'Pending',
      'imageUrl': task.imageUrl,
      'category': task.category,
      'description': task.description,
      'location': task.location,
      'latitude': task.latitude,
      'longitude': task.longitude,
      'requesterId': task.requesterId,
      'requesterName': task.requesterName,
      'requesterPhoto': task.requesterPhoto,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  @override
  Future<List<TaskEntity>> getTasks() async {
    final snapshot = await _firestore.collection('tasks').get();
    return snapshot.docs.map((doc) => _mapDocToEntity(doc)).toList();
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    final doc = await _firestore.collection('tasks').doc(id).get();
    if (doc.exists) {
      return _mapDocToEntity(doc);
    }
    return null;
  }

  @override
  Future<List<TaskEntity>> getNearbyTasks(
    double lat,
    double lng,
    double radiusKm,
  ) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('status', isEqualTo: 'Pending')
        .get();

    final allTasks = snapshot.docs.map((doc) => _mapDocToEntity(doc)).toList();

    return allTasks.where((task) {
      if (task.latitude == null || task.longitude == null) return false;
      final distance = Geolocator.distanceBetween(
        lat,
        lng,
        task.latitude!,
        task.longitude!,
      );
      return (distance / 1000) <= radiusKm;
    }).toList();
  }

  @override
  Stream<List<TaskEntity>> watchNearbyTasks(
    double lat,
    double lng,
    double radiusKm,
  ) {
    return _firestore
        .collection('tasks')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => _mapDocToEntity(doc)).where((task) {
            if (task.latitude == null || task.longitude == null) return false;
            final distance = Geolocator.distanceBetween(
              lat,
              lng,
              task.latitude!,
              task.longitude!,
            );
            return (distance / 1000) <= radiusKm;
          }).toList();
        });
  }

  @override
  Future<void> acceptTask(String taskId, String volunteerId) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'status': 'Accepted',
      'volunteerId': volunteerId,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> completeTask(String taskId) async {
    final doc = await _firestore.collection('tasks').doc(taskId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final volunteerId = data['volunteerId'];

    await _firestore.runTransaction((transaction) async {
      // Update Task
      transaction.update(_firestore.collection('tasks').doc(taskId), {
        'status': 'Completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Update Volunteer Rewards
      if (volunteerId != null) {
        final volunteerRef = _firestore.collection('users').doc(volunteerId);
        final volunteerDoc = await transaction.get(volunteerRef);

        if (volunteerDoc.exists) {
          final vData = volunteerDoc.data()!;
          int completedCount = (vData['completedTasks'] ?? 0) + 1;
          int points = (vData['points'] ?? 0) + 100;

          String badge = 'None';
          if (completedCount >= 30)
            badge = 'Gold';
          else if (completedCount >= 15)
            badge = 'Silver';
          else if (completedCount >= 5)
            badge = 'Bronze';

          transaction.update(volunteerRef, {
            'completedTasks': completedCount,
            'points': points,
            'badge': badge,
          });
        }
      }
    });
  }

  @override
  Future<List<TaskEntity>> getMyTasks(String volunteerId) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('volunteerId', isEqualTo: volunteerId)
        .where('status', isEqualTo: 'Accepted')
        .get();
    return snapshot.docs.map((doc) => _mapDocToEntity(doc)).toList();
  }

  @override
  Future<List<TaskEntity>> getRequesterTasks(String requesterId) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('requesterId', isEqualTo: requesterId)
        .get();
    return snapshot.docs.map((doc) => _mapDocToEntity(doc)).toList();
  }

  TaskEntity _mapDocToEntity(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskEntity(
      id: doc.id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'Pending',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      latitude: data['latitude'],
      longitude: data['longitude'],
      volunteerId: data['volunteerId'],
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? 'Senior User',
      requesterPhoto:
          data['requesterPhoto'] ?? 'https://i.pravatar.cc/150?img=12',
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }
}
