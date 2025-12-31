import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyModel {
  final String id;
  final String name;
  final String jarEmoji;
  final DateTime createdAt;
  final String createdBy;
  final Map<String, String> roles;
  final String inviteCode;
  final FamilySettings settings;

  FamilyModel({
    required this.id,
    required this.name,
    this.jarEmoji = '🫙',
    required this.createdAt,
    required this.createdBy,
    required this.roles,
    required this.inviteCode,
    required this.settings,
  });

  factory FamilyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FamilyModel(
      id: doc.id,
      name: data['name'] ?? 'Family Jar',
      jarEmoji: data['jarEmoji'] ?? '🫙',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
      roles: Map<String, String>.from(data['roles'] ?? {}),
      inviteCode: data['inviteCode'] ?? '',
      settings: FamilySettings.fromMap(data['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'jarEmoji': jarEmoji,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'roles': roles,
      'inviteCode': inviteCode,
      'settings': settings.toMap(),
    };
  }

  FamilyModel copyWith({
    String? name,
    String? jarEmoji,
    Map<String, String>? roles,
    String? inviteCode,
    FamilySettings? settings,
  }) {
    return FamilyModel(
      id: id,
      name: name ?? this.name,
      jarEmoji: jarEmoji ?? this.jarEmoji,
      createdAt: createdAt,
      createdBy: createdBy,
      roles: roles ?? this.roles,
      inviteCode: inviteCode ?? this.inviteCode,
      settings: settings ?? this.settings,
    );
  }

  bool isMember(String userId) => roles.containsKey(userId);
  
  bool isAdmin(String userId) => roles[userId] == 'admin';
  
  String? getRole(String userId) => roles[userId];
  
  int get memberCount => roles.length;
  
  List<String> get memberIds => roles.keys.toList();
}

class FamilySettings {
  final bool allowChildPosting;
  final bool moderationEnabled;
  final String reflectionSchedule;
  final bool notifyOnNewMemory;

  FamilySettings({
    this.allowChildPosting = true,
    this.moderationEnabled = false,
    this.reflectionSchedule = 'weekly',
    this.notifyOnNewMemory = true,
  });

  factory FamilySettings.fromMap(Map<String, dynamic> map) {
    return FamilySettings(
      allowChildPosting: map['allowChildPosting'] ?? true,
      moderationEnabled: map['moderationEnabled'] ?? false,
      reflectionSchedule: map['reflectionSchedule'] ?? 'weekly',
      notifyOnNewMemory: map['notifyOnNewMemory'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'allowChildPosting': allowChildPosting,
      'moderationEnabled': moderationEnabled,
      'reflectionSchedule': reflectionSchedule,
      'notifyOnNewMemory': notifyOnNewMemory,
    };
  }
}
