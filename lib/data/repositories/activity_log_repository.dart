import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ActivityLogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logActivity({
    required String userId,
    required String userName,
    required String role,
    required String action,
    required String details,
    String? targetId,
    String? targetName,
  }) async {
    try {
      await _firestore.collection('activity_logs').add({
        'userId': userId,
        'userName': userName,
        'role': role,
        'action': action,
        'details': details,
        'targetId': targetId,
        'targetName': targetName,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('Activity logged: $action - $details');
    } catch (e) {
      debugPrint('Error logging activity: $e');
    }
  }

  Stream<QuerySnapshot> getRecentLogs({int limit = 50}) {
    return _firestore
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Stream<List<Map<String, dynamic>>> getSeniorLogs(String seniorId) {
    return _firestore
        .collection('activity_logs')
        .where('userId', isEqualTo: seniorId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }
}
