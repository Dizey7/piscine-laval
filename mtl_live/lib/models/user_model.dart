import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final List<String> favoriteIds;
  final DateTime createdAt;
  final UserPreferences preferences;

  const AppUser({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.favoriteIds = const [],
    required this.createdAt,
    this.preferences = const UserPreferences(),
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      displayName: data['displayName'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      favoriteIds: List<String>.from(data['favoriteIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'favoriteIds': favoriteIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'preferences': preferences.toMap(),
    };
  }
}

class UserPreferences {
  final double notificationRadiusKm;
  final Set<String> preferredCategories;
  final bool notificationsEnabled;
  final bool darkMode;

  const UserPreferences({
    this.notificationRadiusKm = 5.0,
    this.preferredCategories = const {},
    this.notificationsEnabled = true,
    this.darkMode = true,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      notificationRadiusKm: (map['notificationRadiusKm'] ?? 5.0).toDouble(),
      preferredCategories: Set<String>.from(map['preferredCategories'] ?? []),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      darkMode: map['darkMode'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationRadiusKm': notificationRadiusKm,
      'preferredCategories': preferredCategories.toList(),
      'notificationsEnabled': notificationsEnabled,
      'darkMode': darkMode,
    };
  }
}
