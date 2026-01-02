import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? avatarEmoji;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime lastActive;
  final List<String> jarIds;
  final String? familyId;
  final List<String> achievements;
  final bool hasCompletedOnboarding;
  final bool hasAcceptedTerms;
  final DateTime? termsAcceptedAt;
  final UserSettings settings;
  final UserStats stats;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.avatarEmoji,
    this.isAnonymous = false,
    required this.createdAt,
    required this.lastActive,
    this.jarIds = const [],
    this.familyId,
    this.achievements = const [],
    this.hasCompletedOnboarding = false,
    this.hasAcceptedTerms = false,
    this.termsAcceptedAt,
    UserSettings? settings,
    UserStats? stats,
  }) : settings = settings ?? UserSettings(),
       stats = stats ?? UserStats();

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      avatarUrl: data['avatarUrl'],
      avatarEmoji: data['avatarEmoji'],
      isAnonymous: data['isAnonymous'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      jarIds: List<String>.from(data['jarIds'] ?? []),
      familyId: data['familyId'],
      achievements: List<String>.from(data['achievements'] ?? []),
      hasCompletedOnboarding: data['hasCompletedOnboarding'] ?? false,
      hasAcceptedTerms: data['hasAcceptedTerms'] ?? false,
      termsAcceptedAt: (data['termsAcceptedAt'] as Timestamp?)?.toDate(),
      settings: UserSettings.fromMap(data['settings'] ?? {}),
      stats: UserStats.fromMap(data['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'avatarEmoji': avatarEmoji,
      'isAnonymous': isAnonymous,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
        'jarIds': jarIds,
      'familyId': familyId,
      'achievements': achievements,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'hasAcceptedTerms': hasAcceptedTerms,
      'termsAcceptedAt': termsAcceptedAt != null ? Timestamp.fromDate(termsAcceptedAt!) : null,
      'settings': settings.toMap(),
      'stats': stats.toMap(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? avatarEmoji,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? lastActive,
    List<String>? jarIds,
    String? familyId,
    List<String>? achievements,
    bool? hasCompletedOnboarding,
    bool? hasAcceptedTerms,
    DateTime? termsAcceptedAt,
    UserSettings? settings,
    UserStats? stats,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      jarIds: jarIds ?? this.jarIds,
      familyId: familyId ?? this.familyId,
      achievements: achievements ?? this.achievements,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      hasAcceptedTerms: hasAcceptedTerms ?? this.hasAcceptedTerms,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      settings: settings ?? this.settings,
      stats: stats ?? this.stats,
    );
  }
}

class UserSettings {
  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final String reminderTime;
  final bool hapticFeedback;
  final bool soundEffects;

  UserSettings({
    this.notificationsEnabled = true,
    this.dailyReminderEnabled = false,
    this.reminderTime = '20:00',
    this.hapticFeedback = true,
    this.soundEffects = true,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      dailyReminderEnabled: map['dailyReminderEnabled'] ?? false,
      reminderTime: map['reminderTime'] ?? '20:00',
      hapticFeedback: map['hapticFeedback'] ?? true,
      soundEffects: map['soundEffects'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'dailyReminderEnabled': dailyReminderEnabled,
      'reminderTime': reminderTime,
      'hapticFeedback': hapticFeedback,
      'soundEffects': soundEffects,
    };
  }

  UserSettings copyWith({
    bool? notificationsEnabled,
    bool? dailyReminderEnabled,
    String? reminderTime,
    bool? hapticFeedback,
    bool? soundEffects,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEffects: soundEffects ?? this.soundEffects,
    );
  }
}

class UserStats {
  final int totalMemories;
  final int totalJars;
  final int currentStreak;
  final int longestStreak;
  final int photosCount;
  final int textCount;
  final DateTime? lastMemoryDate;

  UserStats({
    this.totalMemories = 0,
    this.totalJars = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.photosCount = 0,
    this.textCount = 0,
    this.lastMemoryDate,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      totalMemories: map['totalMemories'] ?? 0,
      totalJars: map['totalJars'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      photosCount: map['photosCount'] ?? 0,
      textCount: map['textCount'] ?? 0,
      lastMemoryDate: map['lastMemoryDate'] != null 
          ? (map['lastMemoryDate'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalMemories': totalMemories,
      'totalJars': totalJars,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'photosCount': photosCount,
      'textCount': textCount,
      'lastMemoryDate': lastMemoryDate != null 
          ? Timestamp.fromDate(lastMemoryDate!) 
          : null,
    };
  }

  UserStats copyWith({
    int? totalMemories,
    int? totalJars,
    int? currentStreak,
    int? longestStreak,
    int? photosCount,
    int? textCount,
    DateTime? lastMemoryDate,
  }) {
    return UserStats(
      totalMemories: totalMemories ?? this.totalMemories,
      totalJars: totalJars ?? this.totalJars,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      photosCount: photosCount ?? this.photosCount,
      textCount: textCount ?? this.textCount,
      lastMemoryDate: lastMemoryDate ?? this.lastMemoryDate,
    );
  }
}
