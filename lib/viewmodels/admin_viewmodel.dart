import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:senior_care/core/services/fcm_service.dart';

class AdminViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _seniorCount = 0;
  int _volunteerCount = 0;
  int _pendingTaskCount = 0;
  int _completedTaskCount = 0;
  int _todayVisitCount = 0;
  int _todayActiveUsersCount = 0;
  int _medicineReminderCount = 0;
  List<Map<String, dynamic>> _seniors = [];
  List<Map<String, dynamic>> _volunteers = [];
  List<Map<String, dynamic>> _activeSOSAlerts = [];
  List<Map<String, dynamic>> _recentLogs = [];
  List<Map<String, dynamic>> _helpRequests = [];
  Map<String, int> _userMedicineCounts = {};
  Map<String, bool> _userHasCriticalMeds = {};

  int get seniorCount => _seniorCount;
  int get volunteerCount => _volunteerCount;
  int get pendingTaskCount => _pendingTaskCount;
  int get completedTaskCount => _completedTaskCount;
  int get todayVisitCount => _todayVisitCount;
  int get todayActiveUsersCount => _todayActiveUsersCount;
  int get medicineReminderCount => _medicineReminderCount;
  List<Map<String, dynamic>> get seniors => _seniors;
  List<Map<String, dynamic>> get volunteers => _volunteers;
  List<Map<String, dynamic>> get activeSOSAlerts => _activeSOSAlerts;
  List<Map<String, dynamic>> get recentLogs => _recentLogs;
  List<Map<String, dynamic>> get helpRequests => _helpRequests;
  Map<String, int> get userMedicineCounts => _userMedicineCounts;
  Map<String, bool> get userHasCriticalMeds => _userHasCriticalMeds;

  AdminViewModel() {
    _initStats();
  }

  void _initStats() {
    // Listen to Seniors count and list
    _firestore
        .collection('users')
        .where('role', whereIn: ['senior', 'both'])
        .snapshots()
        .listen((snapshot) {
          _seniorCount = snapshot.docs.length;
          _seniors = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          notifyListeners();
        });

    // Listen to ALL Volunteers (including both)
    _firestore
        .collection('users')
        .where('role', whereIn: ['volunteer', 'both'])
        .snapshots()
        .listen((snapshot) {
          _volunteerCount = snapshot.docs.length;
          _volunteers = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          notifyListeners();
        });

    // Listen to Pending Tasks count
    _firestore
        .collection('help_requests')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .listen((snapshot) {
          _pendingTaskCount = snapshot.docs.length;
          notifyListeners();
        });

    // Listen to Completed Tasks count
    _firestore
        .collection('help_requests')
        .where('status', isEqualTo: 'Completed')
        .snapshots()
        .listen((snapshot) {
          _completedTaskCount = snapshot.docs.length;
          notifyListeners();
        });

    // Today's task assignments (Accepted status)
    _firestore
        .collection('help_requests')
        .where('status', isEqualTo: 'Accepted')
        .snapshots()
        .listen((snapshot) {
          _todayVisitCount = snapshot.docs.length;
          notifyListeners();
        });

    // Today's app visits (Active Users Count based on lastActive)
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    _firestore
        .collection('users')
        .where(
          'lastActive',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday),
        )
        .snapshots()
        .listen((snapshot) {
          _todayActiveUsersCount = snapshot.docs.length;
          notifyListeners();
        });

    // Listen to Help Requests List
    _firestore
        .collection('help_requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _helpRequests = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          notifyListeners();
        });

    // Listen to Medicine Reminders Count
    _firestore.collection('medicine_reminders').snapshots().listen((snapshot) {
      _medicineReminderCount = snapshot.docs.length;
      Map<String, int> counts = {};
      Map<String, bool> criticalMeds = {};

      final highCareKeywords = [
        'insulin',
        'heart',
        'bp',
        'blood pressure',
        'diabetes',
        'sugar',
        'sugar control',
        'cancer',
        'chemo',
        'oxygen',
        'cardiac',
        'hypertension',
        'dialysis',
      ];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String?;
        final medName = (data['name'] ?? '').toString().toLowerCase();

        if (userId != null) {
          counts[userId] = (counts[userId] ?? 0) + 1;

          if (highCareKeywords.any((k) => medName.contains(k))) {
            criticalMeds[userId] = true;
          }
        }
      }
      _userMedicineCounts = counts;
      _userHasCriticalMeds = criticalMeds;
      notifyListeners();
    });

    // Listen to Active SOS Alerts (Filtered by Today)
    _firestore
        .collection('sos_alerts')
        .where('status', isEqualTo: 'Active')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday),
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _activeSOSAlerts = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          notifyListeners();
        });

    // Listen to Recent Activity Logs
    _firestore
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
          _recentLogs = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          notifyListeners();
        });
  }

  Future<void> approveVolunteer(String id) async {
    await _firestore.collection('users').doc(id).update({'isApproved': true});
    _addLog('VOLUNTEER_APPROVED', 'Approved volunteer account: $id');
  }

  Future<void> toggleVolunteerStatus(String id, bool isActive) async {
    await _firestore.collection('users').doc(id).update({'isActive': isActive});
    _addLog(
      isActive ? 'VOLUNTEER_ACTIVATED' : 'VOLUNTEER_DEACTIVATED',
      'Changed volunteer status to ${isActive ? 'Active' : 'Inactive'} for: $id',
    );
  }

  Future<void> assignVolunteer(String requestId, String volunteerId) async {
    try {
      final volunteer = _volunteers.firstWhere((v) => v['id'] == volunteerId);
      final requestDoc = await _firestore
          .collection('help_requests')
          .doc(requestId)
          .get();
      final requestTitle = requestDoc.data()?['title'] ?? 'Help Request';

      await _firestore.collection('help_requests').doc(requestId).update({
        'status': 'Accepted',
        'volunteerId': volunteerId,
        'volunteerName': volunteer['name'],
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // Send FCM notification to the assigned volunteer
      await FCMService.instance.sendNotificationToUser(
        userId: volunteerId,
        title: 'New Task Assigned',
        body: 'An administrator has assigned you to: $requestTitle',
        data: {'type': 'task_assigned', 'requestId': requestId},
      );

      _addLog(
        'TASK_ASSIGNED',
        'Assigned volunteer ${volunteer['name']} to request $requestId',
      );
    } catch (e) {
      debugPrint('Error assigning volunteer: $e');
    }
  }

  Future<void> broadcastAlert(String title, String body) async {
    try {
      // Send FCM notification to 'volunteers' topic
      await FCMService.instance.sendNotificationToTopic(
        topic: 'volunteers',
        title: title,
        body: body,
      );

      await _addLog('BROADCAST_SENT', 'Broadcast: $title - $body');
    } catch (e) {
      debugPrint('Error broadcasting alert: $e');
    }
  }

  Future<void> _addLog(String action, String details) async {
    await _firestore.collection('activity_logs').add({
      'action': action,
      'details': details,
      'userName': 'Admin',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
