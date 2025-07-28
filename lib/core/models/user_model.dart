import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final UserRole role;
  final UserPreferences preferences;
  
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    required this.role,
    required this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    UserRole? role,
    UserPreferences? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      role: role ?? this.role,
      preferences: preferences ?? this.preferences,
    );
  }
}

enum UserRole { admin, manager, member, viewer }

@JsonSerializable()
class UserPreferences {
  final bool darkMode;
  final String language;
  final bool notifications;
  final bool emailUpdates;
  
  const UserPreferences({
    required this.darkMode,
    required this.language,
    required this.notifications,
    required this.emailUpdates,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  UserPreferences copyWith({
    bool? darkMode,
    String? language,
    bool? notifications,
    bool? emailUpdates,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
      emailUpdates: emailUpdates ?? this.emailUpdates,
    );
  }
}