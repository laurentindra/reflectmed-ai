import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/gibbs_reflection.dart';
import '../models/student_profile.dart';

class StorageService {
  static const String _keyProfile = 'reflectmed_profile';
  static const String _keyReflections = 'reflectmed_reflections';
  static const String _keyChatHistory = 'reflectmed_current_chat';

  // PROFILE
  static Future<StudentProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyProfile);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final map = jsonDecode(jsonString);
        return StudentProfile.fromJson(map);
      } catch (_) {}
    }
    return StudentProfile();
  }

  static Future<void> saveProfile(StudentProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  // REFLECTIONS ARCHIVE
  static Future<List<GibbsReflection>> loadReflections() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyReflections);
    if (list != null && list.isNotEmpty) {
      return list.map((item) {
        try {
          return GibbsReflection.fromJson(jsonDecode(item));
        } catch (_) {
          return null;
        }
      }).whereType<GibbsReflection>().toList();
    }
    return [];
  }

  static Future<void> saveReflection(GibbsReflection reflection) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadReflections();
    final index = current.indexWhere((r) => r.id == reflection.id);
    if (index >= 0) {
      current[index] = reflection;
    } else {
      current.insert(0, reflection);
    }
    final encoded = current.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_keyReflections, encoded);
  }

  // ACTIVE CHAT
  static Future<List<ChatMessage>> loadActiveChat() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyChatHistory);
    if (list != null && list.isNotEmpty) {
      return list.map((item) {
        try {
          return ChatMessage.fromJson(jsonDecode(item));
        } catch (_) {
          return null;
        }
      }).whereType<ChatMessage>().toList();
    }
    return [];
  }

  static Future<void> saveActiveChat(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = messages.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_keyChatHistory, encoded);
  }

  static Future<void> clearActiveChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyChatHistory);
  }
}
