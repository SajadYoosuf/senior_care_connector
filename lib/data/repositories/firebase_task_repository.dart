import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../../core/services/fcm_service.dart';

class FirebaseTaskRepository implements TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> createTask(TaskEntity task) async {
    final docRef = await _firestore.collection('help_requests').add({
      'title': task.title,
      'scheduledAt': Timestamp.fromDate(task.date),
      'status': 'Pending',
      'imageUrl': task.imageUrl,
      'category': task.category,
      'notes': task.description,
      'location': task.location,
      'latitude': task.latitude,
      'longitude': task.longitude,
      'userId': task.requesterId,
      'userName': task.requesterName,
      'requesterPhoto': task.requesterPhoto,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Notify nearby online volunteers via FCM
    if (task.latitude != null && task.longitude != null) {
      await _notifyNearbyVolunteers(
        taskId: docRef.id,
        taskTitle: task.title,
        requesterName: task.requesterName,
        category: task.category,
        requestLat: task.latitude!,
        requestLng: task.longitude!,
        radiusKm: 5.0,
      );
    }

    return docRef.id;
  }

  /// Queries all online volunteers, filters those within [radiusKm] km of the
  /// new request, and sends an FCM push notification to each one.
  Future<void> _notifyNearbyVolunteers({
    required String taskId,
    required String taskTitle,
    required String requesterName,
    required String category,
    required double requestLat,
    required double requestLng,
    double radiusKm = 5.0,
  }) async {
    try {
      // Fetch all online volunteers who have a saved location and FCM token
      final snapshot = await _firestore
          .collection('users')
          .where('isOnline', isEqualTo: true)
          .where('role', whereIn: ['volunteer', 'both'])
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final double? volLat = (data['latitude'] as num?)?.toDouble();
        final double? volLng = (data['longitude'] as num?)?.toDouble();
        final String? fcmToken = data['fcmToken']?.toString();

        // Skip if location or token is missing
        if (volLat == null || volLng == null || fcmToken == null || fcmToken.isEmpty) {
          continue;
        }

        // Calculate distance between volunteer and the new request
        final distanceMeters = Geolocator.distanceBetween(
          volLat,
          volLng,
          requestLat,
          requestLng,
        );

        if ((distanceMeters / 1000) <= radiusKm) {
          await FCMService.instance.sendNotificationToToken(
            token: fcmToken,
            title: '🆘 New Help Request Nearby',
            body: '$requesterName needs help with "$taskTitle" ($category)',
            data: {
              'type': 'new_request',
              'taskId': taskId,
            },
            channelId: 'sos_alerts',
          );
        }
      }
    } catch (e) {
      debugPrint('Error notifying nearby volunteers: $e');
    }
  }

  @override
  Future<List<TaskEntity>> getTasks() async {
    final snapshot = await _firestore.collection('help_requests').get();
    return snapshot.docs.map((doc) => _mapDocToEntity(doc)).toList();
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    final doc = await _firestore.collection('help_requests').doc(id).get();
    if (doc.exists) {
      return _mapDocToEntity(doc);
    }
    return null;
  }

  @override
  Future<List<TaskEntity>> getNearbyTasks(
    double lat,
    double lng,
    double radiusKm, {
    String? excludeUserId,
  }) async {
    final snapshot = await _firestore
        .collection('help_requests')
        .where('status', isEqualTo: 'Pending')
        .get();

    final allTasks = snapshot.docs.map((doc) => _mapDocToEntity(doc)).toList();

    return allTasks.where((task) {
      if (task.latitude == null || task.longitude == null) return false;

      // Filter out tasks created by the same user
      if (excludeUserId != null && task.requesterId == excludeUserId) {
        return false;
      }

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
    double radiusKm, {
    String? excludeUserId,
  }) {
    return _firestore
        .collection('help_requests')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _mapDocToEntity(doc)).where((task) {
        // Legacy task protection: show it if location wasn't available
        if (task.latitude == null || task.longitude == null) return false;

        // Filter out tasks created by the same user
        if (excludeUserId != null && task.requesterId == excludeUserId) {
          return false;
        }

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
    await _firestore.collection('help_requests').doc(taskId).update({
      'status': 'Accepted',
      'volunteerId': volunteerId,
      'acceptedAt': FieldValue.serverTimestamp(),
    });

    // Notify requester
    final task = await getTaskById(taskId);
    if (task != null) {
      await FCMService.instance.sendNotificationToUser(
        userId: task.requesterId,
        title: 'Help is on the way!',
        body: 'A volunteer has accepted your request: ${task.title}',
        data: {'type': 'task_accepted', 'taskId': taskId},
        channelId: 'sos_alerts',
      );
    }
  }

  @override
  Future<void> completeTask(String taskId) async {
    final doc = await _firestore.collection('help_requests').doc(taskId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final volunteerId = data['volunteerId'];
    final requesterId = data['userId'];

    await _firestore.runTransaction((transaction) async {
      // Update Task
      transaction.update(_firestore.collection('help_requests').doc(taskId), {
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

    // Notify requester
    if (requesterId != null) {
      final taskTitle = data['title'] ?? 'your request';
      await FCMService.instance.sendNotificationToUser(
        userId: requesterId,
        title: 'Task Completed',
        body:
            'Your request "$taskTitle" has been marked as completed. Thank you!',
        data: {'type': 'task_completed', 'taskId': taskId},
        channelId: 'sos_alerts',
      );
    }
  }

  @override
  Future<List<TaskEntity>> getMyTasks(String volunteerId) async {
    final snapshot = await _firestore
        .collection('help_requests')
        .where('volunteerId', isEqualTo: volunteerId)
        .where('status', isEqualTo: 'Accepted')
        .get();
    return snapshot.docs.map((doc) => _mapDocToEntity(doc)).toList();
  }

  @override
  Future<List<TaskEntity>> getRequesterTasks(String requesterId) async {
    final snapshot = await _firestore
        .collection('help_requests')
        .where('userId', isEqualTo: requesterId)
        .get();
    return snapshot.docs.map((doc) => _mapDocToEntity(doc)).toList();
  }

  TaskEntity _mapDocToEntity(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskEntity(
      id: doc.id,
      title: data['title'] ?? '',
      date: (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'Pending',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      description: data['notes'] ?? '',
      location: data['location'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      volunteerId: data['volunteerId'],
      requesterId: data['userId'] ?? '',
      requesterName: data['userName'] ?? 'Senior User',
      requesterPhoto:
          data['requesterPhoto'] ?? 'https://i.pravatar.cc/150?img=12',
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }
}
