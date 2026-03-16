import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';

/// Service de cache local avec Hive (mode offline 7 jours)
class CacheService {
  late Box<String> _cacheBox;
  late Box<String> _settingsBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox<String>(AppConstants.hiveCacheBox);
    _settingsBox = await Hive.openBox<String>(AppConstants.hiveSettingsBox);
  }

  /// Sauvegarde des données avec timestamp
  Future<void> put(String key, dynamic data) async {
    final entry = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _cacheBox.put(key, jsonEncode(entry));
  }

  /// Lecture avec vérification d'expiration
  T? get<T>(String key, {Duration maxAge = AppConstants.offlineCacheDuration}) {
    final raw = _cacheBox.get(key);
    if (raw == null) return null;

    try {
      final entry = jsonDecode(raw) as Map<String, dynamic>;
      final timestamp = DateTime.parse(entry['timestamp'] as String);

      if (DateTime.now().difference(timestamp) > maxAge) {
        _cacheBox.delete(key); // Expiré
        return null;
      }
      return entry['data'] as T;
    } catch (_) {
      return null;
    }
  }

  /// Vérifie si le cache est encore valide
  bool isValid(String key, {Duration maxAge = AppConstants.offlineCacheDuration}) {
    final raw = _cacheBox.get(key);
    if (raw == null) return false;
    try {
      final entry = jsonDecode(raw) as Map<String, dynamic>;
      final timestamp = DateTime.parse(entry['timestamp'] as String);
      return DateTime.now().difference(timestamp) <= maxAge;
    } catch (_) {
      return false;
    }
  }

  /// Timestamp du cache
  DateTime? getCacheTime(String key) {
    final raw = _cacheBox.get(key);
    if (raw == null) return null;
    try {
      final entry = jsonDecode(raw) as Map<String, dynamic>;
      return DateTime.parse(entry['timestamp'] as String);
    } catch (_) {
      return null;
    }
  }

  /// Settings persistants
  Future<void> saveSetting(String key, String value) async {
    await _settingsBox.put(key, value);
  }

  String? getSetting(String key) => _settingsBox.get(key);

  /// Nettoyage du cache expiré
  Future<void> cleanExpired() async {
    final keysToDelete = <String>[];
    for (final key in _cacheBox.keys) {
      if (!isValid(key as String)) {
        keysToDelete.add(key);
      }
    }
    for (final key in keysToDelete) {
      await _cacheBox.delete(key);
    }
  }

  Future<void> clearAll() async {
    await _cacheBox.clear();
  }
}
