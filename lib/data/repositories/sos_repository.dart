import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/fcm_service.dart';
import 'activity_log_repository.dart';

class SOSRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ActivityLogRepository _activityLogRepository = ActivityLogRepository();

  Future<void> sendSOSAlert({
    required String userId,
    required String userName,
    required double? latitude,
    required double? longitude,
    required String? locationUrl,
  }) async {
    try {
      // 1. Save to Firestore for real-time app internal alerts
      await _firestore.collection('sos_alerts').add({
        'userId': userId,
        'userName': userName,
        'latitude': latitude,
        'longitude': longitude,
        'locationUrl': locationUrl,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Log activity
      await _activityLogRepository.logActivity(
        userId: userId,
        userName: userName,
        role: 'senior',
        action: 'SOS_TRIGGERED',
        details:
            'Emergency SOS alert triggered${locationUrl != null ? ' at $locationUrl' : ''}',
      );

      // 2. Send Push Notification to 'volunteers' topic
      await FCMService.instance.sendNotificationToTopic(
        topic: 'volunteers',
        title: '🚨 EMERGENCY: $userName',
        body: locationUrl != null
            ? 'Requires immediate help! Location: $locationUrl'
            : 'Requires immediate help! Click to view location.',
        channelId: 'sos_alerts',
        data: {
          'type': 'sos',
          'userName': userName,
          'locationUrl': locationUrl ?? '',
          'latitude': latitude?.toString() ?? '',
          'longitude': longitude?.toString() ?? '',
        },
      );
    } catch (e) {
      debugPrint('Error sending SOS alert: $e');
    }
  }
}
