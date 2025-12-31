# memoryjar
A beautiful, family-centric mobile and web application that transforms everyday moments into cherished memories.

---

## Local README (appended from local changes)

A beautiful family memory capture application built with Flutter and Firebase. Create, share, and cherish memories with your loved ones.

## Features

### Core Features
- **Memory Creation**: Capture text memories with photos, mood, and tags
- **Family Sharing**: Create or join family groups with invite codes
- **Real-time Updates**: See new memories as they're added
- **Mood Tracking**: Track emotions with expressive emoji moods
- **Theme Tags**: Categorize memories (Family Time, Adventure, Milestone, etc.)
- **Photo Support**: Attach up to 5 photos per memory
- **Reactions**: React to family members' memories with emojis
- **User Stats**: Track your memory streak, total memories, and more

### Authentication
- Google Sign-In
- Email/Password authentication
- Anonymous sign-in for quick start

### Design
- Beautiful glassmorphism UI
- Smooth animations with Flutter Animate
- Light and dark theme support
- Material Design 3

## Getting Started

### Prerequisites
- Flutter SDK (>=3.2.0)
- Firebase project
- Android Studio or VS Code
- Xcode (for iOS development)

### Installation

1. **Clone or extract the project**:
```bash
cd memory_jar
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Firebase Setup** (Already configured):
   - `android/app/google-services.json` ✅
   - `ios/Runner/GoogleService-Info.plist` ✅
   - `lib/firebase_options.dart` ✅

4. **Firebase Console Setup**:
   - Enable Authentication methods:
     - Google Sign-In
     - Email/Password
   - Create Firestore Database
   - Create Storage bucket
   - Deploy security rules (see `firebase/` folder)

5. **Run the app**:
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # App widget with routing
├── firebase_options.dart     # Firebase configuration
├── core/
│   ├── router/              # GoRouter navigation
│   └── theme/               # App theming
├── features/
│   ├── auth/                # Authentication screens & providers
│   ├── onboarding/          # Profile & family setup
│   ├── home/                # Main shell & home screen
│   ├── family/              # Family management
│   ├── memories/            # Memory creation & detail
│   ├── reflections/         # Stats & reflections
│   └── profile/             # User profile & settings
└── shared/
    ├── models/              # Data models
    └── widgets/             # Reusable widgets

## Firebase Collections

### users
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "avatarEmoji": "string",
  "familyId": "string",
  "stats": {
    "totalMemories": 0,
    "currentStreak": 0,
    "photosCount": 0,
    "textCount": 0
  }
}
```

### families
```json
{
  "name": "string",
  "inviteCode": "string (8 chars)",
  "createdBy": "uid",
  "roles": {
    "uid": "admin|member"
  }
}
```

### families/{familyId}/memories
```json
{
  "authorId": "uid",
  "authorName": "string",
  "content": "string",
  "mediaUrls": ["url1", "url2"],
  "mood": "emoji",
  "themes": ["tag1", "tag2"],
  "memoryDate": "timestamp",
  "reactions": {
    "uid": "emoji"
  }
}
```

## Build for Production

### Android
```bash
# Generate release APK
flutter build apk --release

# Generate App Bundle (recommended for Play Store)
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS
```bash
flutter build ipa --release
```

### Web
```bash
flutter build web --release
```

Output: `build/web/`

## Firebase Security Rules

### Firestore Rules
Deploy rules from `firebase/firestore.rules`:
```bash
firebase deploy --only firestore:rules
```

### Storage Rules
Deploy rules from `firebase/storage.rules`:
```bash
firebase deploy --only storage
```

## Configuration

### Package Name
- Android: `com.familylegacy.memory_jar`
- iOS: `com.familylegacy.memoryJar`

## Permissions

### Android (AndroidManifest.xml)
- `INTERNET`
- `CAMERA`
- `READ_MEDIA_IMAGES`
- `RECORD_AUDIO`

### iOS (Info.plist)
- Camera Usage
- Photo Library Usage
- Microphone Usage

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| firebase_core | ^3.8.1 | Firebase initialization |
| firebase_auth | ^5.3.4 | Authentication |
| cloud_firestore | ^5.5.1 | Database |
| firebase_storage | ^12.3.7 | File storage |
| google_sign_in | ^6.2.2 | Google auth |
| flutter_riverpod | ^2.6.1 | State management |
| go_router | ^14.6.2 | Navigation |
| flutter_animate | ^4.5.2 | Animations |
| cached_network_image | ^3.4.1 | Image caching |
| image_picker | ^1.1.2 | Photo capture |
| qr_flutter | ^4.1.0 | QR code generation |

## Troubleshooting

### Google Sign-In Issues
1. Ensure SHA-1 fingerprint is added to Firebase Console
2. Enable Google Sign-In in Firebase Authentication
3. Check that `google-services.json` is up to date

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

### splitinstall Dependency Error
If you see `Could not find com.google.android.play:splitinstall:2.0.1`:

1. This is already fixed in the gradle configuration
2. Run `flutter clean` and rebuild
3. If issue persists, add to `android/gradle.properties`:
   ```
   flutter.deferred-components-enabled=false
   ```

### iOS Pod Issues
```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Asset Directory Errors
If you see "unable to find directory entry" for assets:
- The `assets/images/` and `assets/icons/` directories exist but are empty
- This is normal - the app uses emojis and Firebase Storage for images
- You can add local assets later if needed

## License

MIT License - See LICENSE file for details.

## Support

For issues or feature requests, contact the development team.

---

Built with ❤️ using Flutter and Firebase

