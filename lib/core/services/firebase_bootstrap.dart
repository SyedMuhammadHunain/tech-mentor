import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Attempts Firebase init. Returns false when config is missing (demo mode).
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool isAvailable = false;
  static String? statusMessage;

  static Future<bool> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      isAvailable = true;
      statusMessage = 'Firebase connected';
      await _ensureAnonymousAuth();
      return true;
    } catch (e) {
      isAvailable = false;
      statusMessage =
          'Demo mode: Firebase not configured. Progress is saved on this device.';
      debugPrint('Firebase unavailable: $e');
      return false;
    }
  }

  static Future<void> _ensureAnonymousAuth() async {
    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
      }
    } catch (e) {
      debugPrint('Anonymous auth failed: $e');
    }
  }

  static String? get uid {
    if (!isAvailable) return null;
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }
}
