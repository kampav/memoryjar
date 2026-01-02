# Memory Jar - Firestore Database Schema

This document describes the complete Firestore database structure for the Memory Jar application.

---

## Collections Overview

```
firestore/
├── users/                    # User profiles and settings
│   └── {userId}/
│       ├── notifications/    # User notifications
│       └── preferences/      # User preferences
├── jars/                     # Memory jars (containers)
│   └── {jarId}/
│       └── invites/          # Pending invitations
├── memories/                 # Individual memories
│   └── {memoryId}/
│       ├── comments/         # Memory comments
│       └── reactions/        # Memory reactions
├── reflections/              # AI-generated reflections
├── invites/                  # Global invite codes lookup
├── exports/                  # GDPR data export requests
├── feedback/                 # User feedback
└── config/                   # App configuration
```

---

## Users Collection

**Path:** `/users/{userId}`

```typescript
interface UserDocument {
  // Core Identity
  uid: string;                    // Firebase Auth UID
  email: string;                  // User email
  displayName: string;            // Display name (2-50 chars)
  avatarUrl?: string;             // Profile photo URL (Firebase Storage)
  avatarEmoji?: string;           // Selected emoji avatar
  isAnonymous: boolean;           // Anonymous account flag
  
  // Timestamps
  createdAt: Timestamp;           // Account creation
  lastActive: Timestamp;          // Last activity
  
  // Onboarding & Compliance
  hasCompletedOnboarding: boolean;
  hasAcceptedTerms: boolean;
  termsAcceptedAt?: Timestamp;    // GDPR: When terms were accepted
  
  // Relationships
  jarIds: string[];               // Array of jar IDs user belongs to
  
  // Settings (embedded document)
  settings: {
    notificationsEnabled: boolean;  // Push notifications
    dailyReminderEnabled: boolean;  // Daily reminder
    reminderTime: string;           // "HH:mm" format
    hapticFeedback: boolean;        // Haptic feedback
    soundEffects: boolean;          // Sound effects
  };
  
  // Stats (embedded document)
  stats: {
    totalMemories: number;
    totalJars: number;
    currentStreak: number;
    longestStreak: number;
    lastMemoryDate?: Timestamp;
  };
}
```

### Users Subcollections

**Notifications:** `/users/{userId}/notifications/{notificationId}`
```typescript
interface NotificationDocument {
  type: 'memory_added' | 'reflection_ready' | 'jar_invite' | 'comment' | 'reaction' | 'system';
  title: string;
  body: string;
  data?: Record<string, any>;     // Additional payload
  read: boolean;
  createdAt: Timestamp;
  expiresAt?: Timestamp;          // Auto-delete after expiry
}
```

---

## Jars Collection

**Path:** `/jars/{jarId}`

```typescript
interface JarDocument {
  // Core Info
  id: string;                     // Auto-generated ID
  name: string;                   // Jar name (1-100 chars)
  description?: string;           // Optional description
  type: JarType;                  // 'personal' | 'family' | 'friends' | 'work' | 'custom'
  emoji: string;                  // Display emoji
  colorHex: string;               // Hex color code
  coverImageUrl?: string;         // Cover image URL
  
  // Ownership
  ownerId: string;                // Creator's user ID
  createdAt: Timestamp;
  updatedAt: Timestamp;
  
  // Members (embedded map)
  members: {
    [userId: string]: {
      role: MemberRole;           // 'owner' | 'admin' | 'member' | 'viewer'
      joinedAt: Timestamp;
      displayName: string;        // Cached for display
      avatarEmoji?: string;       // Cached for display
    };
  };
  
  // Sharing
  inviteCode?: string;            // 6-character invite code
  inviteCodeExpiresAt?: Timestamp;
  
  // Settings (embedded document)
  settings: {
    allowMemberInvites: boolean;  // Can members invite others?
    requireApproval: boolean;     // Require owner approval for joins?
    notifyOnNewMemory: boolean;   // Notify members on new memories?
    reflectionSchedule: ReflectionSchedule; // 'weekly' | 'monthly' | 'yearly' | 'none'
    isPrivate: boolean;           // Hidden from discovery
    blockedUsers: string[];       // Blocked user IDs
  };
  
  // Stats
  memoryCount: number;
  isArchived: boolean;
}

type JarType = 'personal' | 'family' | 'friends' | 'work' | 'custom';
type MemberRole = 'owner' | 'admin' | 'member' | 'viewer';
type ReflectionSchedule = 'weekly' | 'monthly' | 'yearly' | 'none';
```

### Jar Invites Subcollection

**Path:** `/jars/{jarId}/invites/{inviteId}`
```typescript
interface JarInviteDocument {
  email?: string;                 // Invited email (optional)
  role: MemberRole;               // Role to assign
  invitedBy: string;              // Inviter's user ID
  createdAt: Timestamp;
  expiresAt: Timestamp;
  status: 'pending' | 'accepted' | 'declined' | 'expired';
}
```

---

## Memories Collection

**Path:** `/memories/{memoryId}`

```typescript
interface MemoryDocument {
  // Core Info
  id: string;
  jarId: string;                  // Parent jar ID
  authorId: string;               // Creator's user ID
  authorName: string;             // Cached author name
  authorEmoji?: string;           // Cached author emoji
  
  // Content
  type: MemoryType;               // 'text' | 'photo' | 'voice' | 'video' | 'milestone'
  title?: string;                 // Optional title
  content?: string;               // Text content or caption
  mediaUrls: string[];            // Array of media URLs
  thumbnailUrl?: string;          // Thumbnail for videos
  duration?: number;              // Duration in seconds (voice/video)
  
  // Metadata
  mood?: string;                  // 'joyful' | 'peaceful' | 'grateful' | 'nostalgic' | 'excited' | 'reflective'
  tags: string[];                 // User-defined tags
  location?: {                    // Optional location
    name: string;
    latitude: number;
    longitude: number;
  };
  
  // Timestamps
  createdAt: Timestamp;
  updatedAt: Timestamp;
  memoryDate?: Timestamp;         // When memory occurred (can differ from createdAt)
  
  // Engagement
  reactionCount: number;
  commentCount: number;
  
  // Privacy
  isPrivate: boolean;             // Only visible to author
  isPinned: boolean;              // Pinned to top
}

type MemoryType = 'text' | 'photo' | 'voice' | 'video' | 'milestone';
```

### Memory Comments Subcollection

**Path:** `/memories/{memoryId}/comments/{commentId}`
```typescript
interface CommentDocument {
  authorId: string;
  authorName: string;
  authorEmoji?: string;
  content: string;
  createdAt: Timestamp;
  updatedAt?: Timestamp;
  isEdited: boolean;
}
```

### Memory Reactions Subcollection

**Path:** `/memories/{memoryId}/reactions/{userId}`
```typescript
interface ReactionDocument {
  emoji: string;                  // Reaction emoji
  createdAt: Timestamp;
}
```

---

## Reflections Collection

**Path:** `/reflections/{reflectionId}`

```typescript
interface ReflectionDocument {
  // Core Info
  id: string;
  jarId: string;
  type: ReflectionType;           // 'weekly' | 'monthly' | 'yearly'
  
  // Period
  periodStart: Timestamp;
  periodEnd: Timestamp;
  
  // Content (AI-generated)
  title: string;
  summary: string;                // Short summary
  narrative: string;              // Full narrative text
  highlights: string[];           // Key highlights
  themes: string[];               // Detected themes
  
  // Source
  memoryIds: string[];            // Memories included
  memoryCount: number;
  
  // Metadata
  generatedAt: Timestamp;
  modelVersion: string;           // AI model version used
}

type ReflectionType = 'weekly' | 'monthly' | 'yearly';
```

---

## Invites Collection (Global Lookup)

**Path:** `/invites/{inviteCode}`

```typescript
interface InviteDocument {
  jarId: string;
  jarName: string;                // Cached for display
  jarType: JarType;
  createdBy: string;
  createdAt: Timestamp;
  expiresAt: Timestamp;
  usageCount: number;
  maxUsages?: number;             // Optional limit
  isActive: boolean;
}
```

---

## Exports Collection (GDPR)

**Path:** `/exports/{exportId}`

```typescript
interface ExportDocument {
  userId: string;
  requestedAt: Timestamp;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  downloadUrl?: string;           // Signed URL when ready
  expiresAt?: Timestamp;          // URL expiry
  completedAt?: Timestamp;
  errorMessage?: string;
}
```

---

## Feedback Collection

**Path:** `/feedback/{feedbackId}`

```typescript
interface FeedbackDocument {
  userId: string;
  type: 'bug' | 'feature' | 'general' | 'complaint';
  subject: string;
  message: string;
  appVersion: string;
  platform: 'ios' | 'android' | 'web';
  deviceInfo?: string;
  screenshotUrls?: string[];
  createdAt: Timestamp;
  status: 'new' | 'reviewed' | 'resolved';
}
```

---

## Config Collection

**Path:** `/config/{configId}`

```typescript
// App version config
interface AppConfigDocument {
  minVersion: string;             // Minimum supported app version
  latestVersion: string;          // Latest available version
  forceUpdate: boolean;           // Force update required
  maintenanceMode: boolean;
  maintenanceMessage?: string;
  features: {
    aiReflections: boolean;
    voiceMemories: boolean;
    videoMemories: boolean;
  };
}
```

---

## Security Rules Summary

| Collection | Read | Create | Update | Delete |
|------------|------|--------|--------|--------|
| users | Owner only | Owner only | Owner only | Owner only |
| jars | Members only | Authenticated | Admin/Owner | Owner only |
| memories | Jar members | Jar members (not viewers) | Author or Admin | Author or Admin |
| reflections | Jar members | Backend only | None | None |
| invites | Authenticated | Backend only | None | None |
| exports | Owner only | Backend only | None | None |
| feedback | Owner only | Authenticated | None | None |
| config | Authenticated | None | None | None |

---

## Deployment Commands

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Firestore indexes
firebase deploy --only firestore:indexes

# Deploy both
firebase deploy --only firestore
```

---

## Notes

1. **Member caching:** User display names and emojis are cached in jar.members for faster reads
2. **Denormalization:** Memory counts are cached on jars and users for dashboard performance
3. **TTL:** Notifications and exports should have TTL policies configured in Firebase Console
4. **Backups:** Enable Point-in-time Recovery in Firebase Console for GDPR compliance
5. **Audit trail:** Consider adding a separate audit collection for GDPR compliance logging
