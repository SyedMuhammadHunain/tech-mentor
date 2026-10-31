import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Initializes Firebase without Authentication.
/// Progress is keyed by a local device id, never a login.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static const _deviceIdKey = 'techsaathi_device_id';

  static bool isAvailable = false;
  static String? statusMessage;
  static String? deviceId;

  static Future<bool> initialize() async {
    await _ensureDeviceId();
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      isAvailable = true;
      statusMessage = null;
      return true;
    } catch (e) {
      isAvailable = false;
      statusMessage =
          'Progress is saved on this device. Firebase cloud sync is not connected yet.';
      debugPrint('Firebase unavailable: $e');
      return false;
    }
  }

  static Future<void> _ensureDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceIdKey);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await prefs.setString(_deviceIdKey, id);
    }
    deviceId = id;
  }
}
