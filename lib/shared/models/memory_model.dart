import 'package:cloud_firestore/cloud_firestore.dart';

class MemoryModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarEmoji;
  final String? authorAvatarUrl;
  final String familyId;
  final String content;
  final List<String> mediaUrls;
  final List<String> thumbnailUrls;
  final String? voiceNoteUrl;
  final int? voiceDurationMs;
  final String mood;
  final List<String> themes;
  final List<String> aiTags;
  final String privacy;
  final List<String> allowedViewers;
  final DateTime createdAt;
  final DateTime memoryDate;
  final Map<String, String> reactions;
  final int commentCount;
  final bool isHighlight;
  final int yearTag;
  final int monthTag;
  final int? weekTag;

  MemoryModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatarEmoji,
    this.authorAvatarUrl,
    required this.familyId,
    required this.content,
    this.mediaUrls = const [],
    this.thumbnailUrls = const [],
    this.voiceNoteUrl,
    this.voiceDurationMs,
    required this.mood,
    this.themes = const [],
    this.aiTags = const [],
    this.privacy = 'family',
    this.allowedViewers = const [],
    required this.createdAt,
    required this.memoryDate,
    this.reactions = const {},
    this.commentCount = 0,
    this.isHighlight = false,
    required this.yearTag,
    required this.monthTag,
    this.weekTag,
  });

  factory MemoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final memoryDate = (data['memoryDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    
    return MemoryModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown',
      authorAvatarEmoji: data['authorAvatarEmoji'],
      authorAvatarUrl: data['authorAvatarUrl'],
      familyId: data['familyId'] ?? '',
      content: data['content'] ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      thumbnailUrls: List<String>.from(data['thumbnailUrls'] ?? []),
      voiceNoteUrl: data['voiceNoteUrl'],
      voiceDurationMs: data['voiceDurationMs'],
      mood: data['mood'] ?? '😊',
      themes: List<String>.from(data['themes'] ?? []),
      aiTags: List<String>.from(data['aiTags'] ?? []),
      privacy: data['privacy'] ?? 'family',
      allowedViewers: List<String>.from(data['allowedViewers'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      memoryDate: memoryDate,
      reactions: Map<String, String>.from(data['reactions'] ?? {}),
      commentCount: data['commentCount'] ?? 0,
      isHighlight: data['isHighlight'] ?? false,
      yearTag: data['yearTag'] ?? memoryDate.year,
      monthTag: data['monthTag'] ?? memoryDate.month,
      weekTag: data['weekTag'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarEmoji': authorAvatarEmoji,
      'authorAvatarUrl': authorAvatarUrl,
      'familyId': familyId,
      'content': content,
      'mediaUrls': mediaUrls,
      'thumbnailUrls': thumbnailUrls,
      'voiceNoteUrl': voiceNoteUrl,
      'voiceDurationMs': voiceDurationMs,
      'mood': mood,
      'themes': themes,
      'aiTags': aiTags,
      'privacy': privacy,
      'allowedViewers': allowedViewers,
      'createdAt': Timestamp.fromDate(createdAt),
      'memoryDate': Timestamp.fromDate(memoryDate),
      'reactions': reactions,
      'commentCount': commentCount,
      'isHighlight': isHighlight,
      'yearTag': yearTag,
      'monthTag': monthTag,
      'weekTag': weekTag,
    };
  }

  MemoryModel copyWith({
    String? content,
    List<String>? mediaUrls,
    String? mood,
    List<String>? themes,
    String? privacy,
    Map<String, String>? reactions,
    int? commentCount,
    bool? isHighlight,
  }) {
    return MemoryModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatarEmoji: authorAvatarEmoji,
      authorAvatarUrl: authorAvatarUrl,
      familyId: familyId,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      thumbnailUrls: thumbnailUrls,
      voiceNoteUrl: voiceNoteUrl,
      voiceDurationMs: voiceDurationMs,
      mood: mood ?? this.mood,
      themes: themes ?? this.themes,
      aiTags: aiTags,
      privacy: privacy ?? this.privacy,
      allowedViewers: allowedViewers,
      createdAt: createdAt,
      memoryDate: memoryDate,
      reactions: reactions ?? this.reactions,
      commentCount: commentCount ?? this.commentCount,
      isHighlight: isHighlight ?? this.isHighlight,
      yearTag: yearTag,
      monthTag: monthTag,
      weekTag: weekTag,
    );
  }

  bool get hasMedia => mediaUrls.isNotEmpty;
  bool get hasVoice => voiceNoteUrl != null;
  int get reactionCount => reactions.length;
  
  String get previewText {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }
}
