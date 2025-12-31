import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? avatarEmoji;
  final String? avatarUrl;
  final String? familyId;
  final String role;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime lastActive;
  final UserSettings settings;
  final UserStats stats;
  final List<String> achievements;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.avatarEmoji,
    this.avatarUrl,
    this.familyId,
    this.role = 'member',
    this.isAnonymous = false,
    required this.createdAt,
    required this.lastActive,
    required this.settings,
    required this.stats,
    this.achievements = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'User',
      avatarEmoji: data['avatarEmoji'],
      avatarUrl: data['avatarUrl'],
      familyId: data['familyId'],
      role: data['role'] ?? 'member',
      isAnonymous: data['isAnonymous'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      settings: UserSettings.fromMap(data['settings'] ?? {}),
      stats: UserStats.fromMap(data['stats'] ?? {}),
      achievements: List<String>.from(data['achievements'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'avatarEmoji': avatarEmoji,
      'avatarUrl': avatarUrl,
      'familyId': familyId,
      'role': role,
      'isAnonymous': isAnonymous,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'settings': settings.toMap(),
      'stats': stats.toMap(),
      'achievements': achievements,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? avatarEmoji,
    String? avatarUrl,
    String? familyId,
    String? role,
    DateTime? lastActive,
    UserSettings? settings,
    UserStats? stats,
    List<String>? achievements,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      familyId: familyId ?? this.familyId,
      role: role ?? this.role,
      isAnonymous: isAnonymous,
      createdAt: createdAt,
      lastActive: lastActive ?? this.lastActive,
      settings: settings ?? this.settings,
      stats: stats ?? this.stats,
      achievements: achievements ?? this.achievements,
    );
  }
}

class UserSettings {
  final bool notificationsEnabled;
  final bool dailyReminder;
  final String reminderTime;
  final String theme;
  final String language;

  UserSettings({
    this.notificationsEnabled = true,
    this.dailyReminder = true,
    this.reminderTime = '20:00',
    this.theme = 'system',
    this.language = 'en',
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      dailyReminder: map['dailyReminder'] ?? true,
      reminderTime: map['reminderTime'] ?? '20:00',
      theme: map['theme'] ?? 'system',
      language: map['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'dailyReminder': dailyReminder,
      'reminderTime': reminderTime,
      'theme': theme,
      'language': language,
    };
  }
}

class UserStats {
  final int totalMemories;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastMemoryDate;
  final int photosCount;
  final int voiceCount;
  final int textCount;

  UserStats({
    this.totalMemories = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastMemoryDate,
    this.photosCount = 0,
    this.voiceCount = 0,
    this.textCount = 0,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      totalMemories: map['totalMemories'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastMemoryDate: (map['lastMemoryDate'] as Timestamp?)?.toDate(),
      photosCount: map['photosCount'] ?? 0,
      voiceCount: map['voiceCount'] ?? 0,
      textCount: map['textCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalMemories': totalMemories,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastMemoryDate': lastMemoryDate != null 
          ? Timestamp.fromDate(lastMemoryDate!) 
          : null,
      'photosCount': photosCount,
      'voiceCount': voiceCount,
      'textCount': textCount,
    };
  }

  UserStats copyWith({
    int? totalMemories,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastMemoryDate,
    int? photosCount,
    int? voiceCount,
    int? textCount,
  }) {
    return UserStats(
      totalMemories: totalMemories ?? this.totalMemories,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastMemoryDate: lastMemoryDate ?? this.lastMemoryDate,
      photosCount: photosCount ?? this.photosCount,
      voiceCount: voiceCount ?? this.voiceCount,
      textCount: textCount ?? this.textCount,
    );
  }
}
