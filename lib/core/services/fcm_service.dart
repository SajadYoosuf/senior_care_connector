import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FCMService {
  static final FCMService instance = FCMService._internal();
  FCMService._internal();

  String get _serverKey => dotenv.env['FCM_SERVER_KEY'] ?? '';
  final String _fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  Future<void> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, String>? data,
    String? channelId,
  }) async {
    await _send(
      to: '/topics/$topic',
      title: title,
      body: body,
      data: data,
      channelId: channelId,
    );
  }

  /// Sends a notification to a specific user by looking up their FCM token
  /// from Firestore using their [userId].
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
    String? channelId,
  }) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final token = userDoc.data()?['fcmToken'];
        if (token != null && token.toString().isNotEmpty) {
          await _send(
            to: token.toString(),
            title: title,
            body: body,
            data: data,
            channelId: channelId,
          );
        }
      }
    } catch (e) {
      debugPrint('Error sending user notification: $e');
    }
  }

  /// Sends a notification directly to a known device [token].
  /// Use this when the FCM token is already available (e.g. from a Firestore
  /// query result) to avoid an extra database lookup per recipient.
  Future<void> sendNotificationToToken({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
    String? channelId,
  }) async {
    try {
      await _send(
        to: token,
        title: title,
        body: body,
        data: data,
        channelId: channelId,
      );
    } catch (e) {
      debugPrint('Error sending token notification: $e');
    }
  }

  Future<void> _send({
    required String to,
    required String title,
    required String body,
    Map<String, String>? data,
    String? channelId,
  }) async {
    if (_serverKey.isEmpty) {
      debugPrint('FCM Server Key is empty. Notification not sent.');
      return;
    }

    final Map<String, dynamic> notificationPayload = {
      'to': to,
      'notification': {
        'title': title,
        'body': body,
        'sound': 'default',
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'android_channel_id': channelId ?? 'default_channel',
      },
      'data': data ?? {},
      'priority': 'high',
    };

    try {
      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode(notificationPayload),
      );

      if (response.statusCode == 200) {
        debugPrint('FCM Notification sent successfully to $to');
      } else {
        debugPrint('FCM Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending FCM: $e');
    }
  }
}
