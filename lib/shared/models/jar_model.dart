import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Types of memory jars available
enum JarType {
  personal,
  family,
  friends,
  work,
  custom,
}

extension JarTypeExtension on JarType {
  String get displayName {
    switch (this) {
      case JarType.personal:
        return 'Personal';
      case JarType.family:
        return 'Family';
      case JarType.friends:
        return 'Friends';
      case JarType.work:
        return 'Work';
      case JarType.custom:
        return 'Custom';
    }
  }

  String get description {
    switch (this) {
      case JarType.personal:
        return 'A private space for your personal memories';
      case JarType.family:
        return 'Share precious moments with family members';
      case JarType.friends:
        return 'Create memories with your friend group';
      case JarType.work:
        return 'Professional milestones and achievements';
      case JarType.custom:
        return 'Create a jar for any purpose';
    }
  }

  String get defaultEmoji {
    switch (this) {
      case JarType.personal:
        return '🫙';
      case JarType.family:
        return '👨‍👩‍👧‍👦';
      case JarType.friends:
        return '🎉';
      case JarType.work:
        return '💼';
      case JarType.custom:
        return '✨';
    }
  }

  Color get defaultColor {
    switch (this) {
      case JarType.personal:
        return const Color(0xFF8B5CF6); // Violet
      case JarType.family:
        return const Color(0xFFF472B6); // Pink
      case JarType.friends:
        return const Color(0xFF06B6D4); // Cyan
      case JarType.work:
        return const Color(0xFF3B82F6); // Blue
      case JarType.custom:
        return const Color(0xFF6366F1); // Indigo
    }
  }

  IconData get icon {
    switch (this) {
      case JarType.personal:
        return Icons.person_rounded;
      case JarType.family:
        return Icons.family_restroom_rounded;
      case JarType.friends:
        return Icons.groups_rounded;
      case JarType.work:
        return Icons.work_rounded;
      case JarType.custom:
        return Icons.auto_awesome_rounded;
    }
  }
}

/// Represents a memory jar
class JarModel {
  final String id;
  final String name;
  final JarType type;
  final String emoji;
  final String colorHex;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, JarMember> members;
  final String? inviteCode;
  final JarSettings settings;
  final bool isArchived;
  final String? coverImageUrl;
  final int memoryCount;

  JarModel({
    required this.id,
    required this.name,
    required this.type,
    String? emoji,
    String? colorHex,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.members = const {},
    this.inviteCode,
    JarSettings? settings,
    this.isArchived = false,
    this.coverImageUrl,
    this.memoryCount = 0,
  })  : emoji = emoji ?? type.defaultEmoji,
        colorHex = colorHex ?? _colorToHex(type.defaultColor),
        settings = settings ?? JarSettings();

  Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

  bool get isPersonal => type == JarType.personal;
  bool get isShared => members.length > 1;

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  factory JarModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse members
    final membersData = data['members'] as Map<String, dynamic>? ?? {};
    final members = membersData.map(
      (key, value) => MapEntry(key, JarMember.fromMap(value as Map<String, dynamic>)),
    );

    return JarModel(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Jar',
      type: JarType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => JarType.personal,
      ),
      emoji: data['emoji'],
      colorHex: data['colorHex'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      members: members,
      inviteCode: data['inviteCode'],
      settings: JarSettings.fromMap(data['settings'] ?? {}),
      isArchived: data['isArchived'] ?? false,
      coverImageUrl: data['coverImageUrl'],
      memoryCount: data['memoryCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.name,
      'emoji': emoji,
      'colorHex': colorHex,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'members': members.map((key, value) => MapEntry(key, value.toMap())),
      'inviteCode': inviteCode,
      'settings': settings.toMap(),
      'isArchived': isArchived,
      'coverImageUrl': coverImageUrl,
      'memoryCount': memoryCount,
    };
  }

  JarModel copyWith({
    String? id,
    String? name,
    JarType? type,
    String? emoji,
    String? colorHex,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, JarMember>? members,
    String? inviteCode,
    JarSettings? settings,
    bool? isArchived,
    String? coverImageUrl,
    int? memoryCount,
  }) {
    return JarModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      members: members ?? this.members,
      inviteCode: inviteCode ?? this.inviteCode,
      settings: settings ?? this.settings,
      isArchived: isArchived ?? this.isArchived,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      memoryCount: memoryCount ?? this.memoryCount,
    );
  }

  /// Create a new personal jar for a user
  factory JarModel.createPersonal({
    required String userId,
    required String userName,
  }) {
    return JarModel(
      id: '', // Will be set by Firestore
      name: 'My Memories',
      type: JarType.personal,
      createdBy: userId,
      createdAt: DateTime.now(),
      members: {
        userId: JarMember(
          userId: userId,
          displayName: userName,
          role: JarMemberRole.owner,
          joinedAt: DateTime.now(),
        ),
      },
    );
  }

  /// Create a new shared jar
  factory JarModel.createShared({
    required String userId,
    required String userName,
    required String name,
    required JarType type,
    String? emoji,
    String? colorHex,
  }) {
    return JarModel(
      id: '', // Will be set by Firestore
      name: name,
      type: type,
      emoji: emoji,
      colorHex: colorHex,
      createdBy: userId,
      createdAt: DateTime.now(),
      members: {
        userId: JarMember(
          userId: userId,
          displayName: userName,
          role: JarMemberRole.owner,
          joinedAt: DateTime.now(),
        ),
      },
      inviteCode: _generateInviteCode(),
    );
  }

  static String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) {
      return chars[(DateTime.now().microsecondsSinceEpoch + index * 7) % chars.length];
    }).join();
  }
}

/// Member roles within a jar
enum JarMemberRole {
  owner,
  admin,
  member,
  viewer,
}

extension JarMemberRoleExtension on JarMemberRole {
  String get displayName {
    switch (this) {
      case JarMemberRole.owner:
        return 'Owner';
      case JarMemberRole.admin:
        return 'Admin';
      case JarMemberRole.member:
        return 'Member';
      case JarMemberRole.viewer:
        return 'Viewer';
    }
  }

  bool get canAddMemories => this != JarMemberRole.viewer;
  bool get canEditSettings => this == JarMemberRole.owner || this == JarMemberRole.admin;
  bool get canInviteMembers => this == JarMemberRole.owner || this == JarMemberRole.admin;
  bool get canRemoveMembers => this == JarMemberRole.owner || this == JarMemberRole.admin;
}

/// Represents a member of a jar
class JarMember {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final JarMemberRole role;
  final DateTime joinedAt;
  final int memoriesContributed;

  JarMember({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.joinedAt,
    this.memoriesContributed = 0,
  });

  bool get isOwner => role == JarMemberRole.owner;
  bool get isAdmin => role == JarMemberRole.admin;
  bool get canEdit => role.canAddMemories;

  factory JarMember.fromMap(Map<String, dynamic> map) {
    return JarMember(
      userId: map['userId'] ?? '',
      displayName: map['displayName'] ?? 'Unknown',
      photoUrl: map['photoUrl'],
      role: JarMemberRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => JarMemberRole.member,
      ),
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      memoriesContributed: map['memoriesContributed'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'memoriesContributed': memoriesContributed,
    };
  }

  JarMember copyWith({
    String? userId,
    String? displayName,
    String? photoUrl,
    JarMemberRole? role,
    DateTime? joinedAt,
    int? memoriesContributed,
  }) {
    return JarMember(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      memoriesContributed: memoriesContributed ?? this.memoriesContributed,
    );
  }
}

/// Settings for a jar
class JarSettings {
  final bool allowMemberInvites;
  final bool requireApprovalForMemories;
  final bool notifyOnNewMemory;
  final String reflectionSchedule; // 'weekly', 'monthly', 'yearly'
  final bool isPrivate;
  final List<String> blockedUsers;

  JarSettings({
    this.allowMemberInvites = true,
    this.requireApprovalForMemories = false,
    this.notifyOnNewMemory = true,
    this.reflectionSchedule = 'weekly',
    this.isPrivate = false,
    this.blockedUsers = const [],
  });

  factory JarSettings.fromMap(Map<String, dynamic> map) {
    return JarSettings(
      allowMemberInvites: map['allowMemberInvites'] ?? true,
      requireApprovalForMemories: map['requireApprovalForMemories'] ?? false,
      notifyOnNewMemory: map['notifyOnNewMemory'] ?? true,
      reflectionSchedule: map['reflectionSchedule'] ?? 'weekly',
      isPrivate: map['isPrivate'] ?? false,
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'allowMemberInvites': allowMemberInvites,
      'requireApprovalForMemories': requireApprovalForMemories,
      'notifyOnNewMemory': notifyOnNewMemory,
      'reflectionSchedule': reflectionSchedule,
      'isPrivate': isPrivate,
      'blockedUsers': blockedUsers,
    };
  }

  JarSettings copyWith({
    bool? allowMemberInvites,
    bool? requireApprovalForMemories,
    bool? notifyOnNewMemory,
    String? reflectionSchedule,
    bool? isPrivate,
    List<String>? blockedUsers,
  }) {
    return JarSettings(
      allowMemberInvites: allowMemberInvites ?? this.allowMemberInvites,
      requireApprovalForMemories: requireApprovalForMemories ?? this.requireApprovalForMemories,
      notifyOnNewMemory: notifyOnNewMemory ?? this.notifyOnNewMemory,
      reflectionSchedule: reflectionSchedule ?? this.reflectionSchedule,
      isPrivate: isPrivate ?? this.isPrivate,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }
}
