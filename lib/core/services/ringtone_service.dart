import 'package:flutter/services.dart';

class RingtoneService {
  static const _channel = MethodChannel('com.example.app/ringtone_picker');

  static Future<String?> pickRingtone() async {
    try {
      final String? uri = await _channel.invokeMethod('pickRingtone');
      return uri;
    } on PlatformException catch (e) {
      print("Failed to pick ringtone: '${e.message}'.");
      return null;
    }
  }
}
