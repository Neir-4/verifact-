import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_model.dart';

class PersistenceService {
  static const _sessionKey = 'caught_session';

  final SharedPreferences _prefs;

  PersistenceService(this._prefs);

  static Future<PersistenceService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PersistenceService(prefs);
  }

  Future<void> saveSession(GameSession session) async {
    final json = jsonEncode(session.toJson());
    await _prefs.setString(_sessionKey, json);
  }

  GameSession? loadSession() {
    final json = _prefs.getString(_sessionKey);
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return GameSession.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  bool get hasSavedSession => _prefs.containsKey(_sessionKey);

  Future<void> clearSession() async {
    await _prefs.remove(_sessionKey);
  }
}
