# Memory Jar - Quick Deployment Guide for Beta

## 🚀 Deploy to Production Today

Follow these steps to get your app running:

---

## Step 1: Firebase Console Setup (5 minutes)

### 1.1 Enable Authentication
Go to Firebase Console → Authentication → Sign-in method:
- ✅ Enable **Google** provider
- ✅ Enable **Email/Password** provider

### 1.2 Add Android SHA-1 (for Google Sign-In)
```bash
# Get debug SHA-1
cd android
./gradlew signingReport
```
Add the SHA-1 fingerprint to Firebase Console → Project Settings → Your Apps → Android app

### 1.3 Create Firestore Database
Firebase Console → Firestore Database → Create database
- Start in **production mode**
- Choose your preferred region

### 1.4 Create Storage Bucket
Firebase Console → Storage → Get started
- Start in **production mode**

### 1.5 Deploy Security Rules
Option A: Firebase Console UI
- Copy rules from `firebase/firestore.rules` to Firestore → Rules
- Copy rules from `firebase/storage.rules` to Storage → Rules

Option B: Firebase CLI
```bash
npm install -g firebase-tools
firebase login
firebase init
firebase deploy --only firestore:rules,storage
```

---

## Step 2: Local Development (2 minutes)

```bash
# Navigate to project
cd memory_jar

# Get dependencies
flutter pub get

# Run on connected device
flutter run
```

---

## Step 3: Build for Distribution

### Android APK (Internal Testing)
```bash
flutter build apk --release
```
**Output**: `build/app/outputs/flutter-apk/app-release.apk`

Share this APK directly with beta testers.

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```
**Output**: `build/app/outputs/bundle/release/app-release.aab`

### iOS (TestFlight)
```bash
flutter build ipa --release
```
Then upload to App Store Connect via Transporter.

### Web (Firebase Hosting)
```bash
flutter build web --release
firebase init hosting
firebase deploy --only hosting
```

---

## Step 4: Test Checklist ✓

Before sharing with beta users, test:

- [ ] Google Sign-In works
- [ ] Email registration works
- [ ] Profile setup saves correctly
- [ ] Family creation generates invite code
- [ ] Family joining with code works
- [ ] Memory creation with text only
- [ ] Memory creation with photos
- [ ] Photos upload successfully
- [ ] Memories appear in real-time
- [ ] Reactions work
- [ ] Sign out and sign back in
- [ ] Dark mode toggle

---

## Step 5: Share with Beta Testers

### Android
1. Share the APK file directly via email/drive
2. Or use Firebase App Distribution:
   ```bash
   firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
     --app YOUR_APP_ID \
     --groups beta-testers
   ```

### iOS
1. Upload to TestFlight
2. Add internal testers via App Store Connect
3. Send TestFlight invitation links

---

## Quick Fixes

### "Google Sign-In Failed"
1. Check SHA-1 is added to Firebase
2. Re-download `google-services.json`
3. Replace `android/app/google-services.json`

### "Network Error" / "Permission Denied"
1. Check Firestore rules are deployed
2. Check Storage rules are deployed
3. Verify user is authenticated

### "Build Failed"
```bash
flutter clean
flutter pub get
cd ios && pod deintegrate && pod install && cd ..
flutter run
```

---

## What's Working in This Beta

✅ User authentication (Google, Email, Anonymous)
✅ Profile setup with avatar selection
✅ Family creation with invite codes
✅ Family joining
✅ Memory creation with text
✅ Memory creation with photos (up to 5)
✅ Real-time memory list
✅ Memory reactions
✅ User stats tracking
✅ Light/dark theme
✅ Glassmorphism UI

## Coming in Future Updates

🔜 Voice recordings
🔜 AI-powered weekly reflections
🔜 Push notifications
🔜 Offline mode
🔜 Achievement badges
🔜 Memory search
🔜 Export memories

---

## Need Help?

1. Check the full README.md for detailed documentation
2. Review Firebase Console logs for backend errors
3. Run `flutter doctor` to verify setup

---

**Happy memory making! 🫙✨**
