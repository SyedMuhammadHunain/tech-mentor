import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/firebase_bootstrap.dart';
import '../models/user_preferences.dart';

class UserRepository {
  static const _prefsKey = 'techsaathi_user_prefs_v1';

  Future<UserPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        return UserPreferences.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (e) {
        debugPrint('Prefs parse error: $e');
      }
    }
    return const UserPreferences();
  }

  Future<void> save(UserPreferences user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(user.toJson()));
    await _syncFirestore(user);
  }

  Future<void> _syncFirestore(UserPreferences user) async {
    final deviceId = FirebaseBootstrap.deviceId;
    if (!FirebaseBootstrap.isAvailable || deviceId == null) return;
    try {
      await FirebaseFirestore.instance.collection('devices').doc(deviceId).set({
        'name': user.name,
        'preferredLanguage': user.language.code,
        'skillLevel': user.skillLevel.name,
        'learningStyle': user.learningStyle.name,
        'lessonsCompleted': user.lessonsCompleted,
        'learningStreak': user.learningStreak,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore sync failed: $e');
    }
  }

  Future<void> saveLessonProgress({
    required String lessonId,
    required bool completed,
    int? quizScore,
    bool independentCompletion = false,
  }) async {
    final deviceId = FirebaseBootstrap.deviceId;
    if (!FirebaseBootstrap.isAvailable || deviceId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .collection('progress')
          .doc(lessonId)
          .set({
        'lessonId': lessonId,
        'completed': completed,
        'quizScore': quizScore,
        'independentCompletion': independentCompletion,
        'completedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Progress sync failed: $e');
    }
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
