import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _seniorCount = 0;
  int _volunteerCount = 0;
  int _pendingTaskCount = 0;
  int _todayVisitCount = 0;
  List<Map<String, dynamic>> _seniors = [];
  List<Map<String, dynamic>> _volunteers = [];

  int get seniorCount => _seniorCount;
  int get volunteerCount => _volunteerCount;
  int get pendingTaskCount => _pendingTaskCount;
  int get todayVisitCount => _todayVisitCount;
  List<Map<String, dynamic>> get seniors => _seniors;
  List<Map<String, dynamic>> get volunteers => _volunteers;

  AdminProvider() {
    _initStats();
  }

  void _initStats() {
    // Listen to Seniors count and list
    _firestore
        .collection('users')
        .where('role', isEqualTo: 'senior')
        .snapshots()
        .listen((snapshot) {
          _seniorCount = snapshot.docs.length;
          _seniors = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          notifyListeners();
        });

    // Listen to Volunteers count and list
    _firestore
        .collection('users')
        .where('role', isEqualTo: 'volunteer')
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
        .collection('tasks')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .listen((snapshot) {
          _pendingTaskCount = snapshot.docs.length;
          notifyListeners();
        });

    // Today's visits (Mock logic: count tasks created today or scheduled for today)
    // For now, let's just count tasks updated in the last 24h as a proxy or keep it real if date field exists
    _firestore
        .collection('tasks')
        .where('status', isEqualTo: 'Accepted')
        .snapshots()
        .listen((snapshot) {
          _todayVisitCount = snapshot.docs.length; // Simplified for now
          notifyListeners();
        });
  }
}
