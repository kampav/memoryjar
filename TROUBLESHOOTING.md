# Memory Jar - Troubleshooting Guide

## Common Build Errors & Fixes

---

### 1. compileSdk Version Error (MOST COMMON)

**Error:**
```
Dependency 'androidx.core:core-ktx:1.17.0' requires libraries and applications 
that depend on it to compile against version 36 or later of the Android APIs.
:app is currently compiled against android-34.
```

**Cause:** AndroidX dependencies have been updated and require compileSdk 36.

**Fix (Already Applied):**
In `android/app/build.gradle`, compileSdk is set to 36:
```gradle
android {
    compileSdk 36
    // ...
}
```

**If still having issues:**
1. Make sure you have Android SDK 36 installed
2. Open Android Studio → SDK Manager → Install "Android 16" (API 36)
3. Or run: `flutter clean && flutter pub get && flutter run`

---

### 2. splitinstall Dependency Error

**Error:**
```
Could not find com.google.android.play:splitinstall:2.0.1
```

**Cause:** Flutter's deferred components feature requires Play Core library.

**Fix (Already Applied):**
The gradle files have been updated to:
1. Disable deferred components: `flutter.deferred-components-enabled=false` in `android/gradle.properties`
2. Substitute splitinstall with play-core library in `android/build.gradle`
3. Add play-core dependency in `android/app/build.gradle`

**If still having issues:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

### 3. Asset Directory Errors

**Error:**
```
Error: unable to find directory entry in pubspec.yaml: assets/images/
Error: unable to find directory entry in pubspec.yaml: assets/icons/
```

**Cause:** Asset directories referenced in pubspec.yaml don't exist or are empty.

**Fix (Already Applied):**
- Asset references have been commented out in `pubspec.yaml`
- Empty directories with `.gitkeep` files have been created
- The app uses emojis and Firebase Storage instead of local assets

**If you want to use local assets:**
1. Create the directories: `assets/images/` and `assets/icons/`
2. Add at least one file to each directory
3. Uncomment the asset lines in `pubspec.yaml`

---

### 4. Google Sign-In Not Working

**Error:**
```
PlatformException(sign_in_failed, ...)
```

**Fix:**
1. Get your SHA-1 fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Go to Firebase Console → Project Settings → Your Apps → Android
3. Add the SHA-1 fingerprint
4. Download updated `google-services.json`
5. Replace `android/app/google-services.json`
6. Rebuild the app

---

### 5. Firestore Permission Denied

**Error:**
```
[cloud_firestore/permission-denied] The caller does not have permission...
```

**Fix:**
1. Go to Firebase Console → Firestore → Rules
2. Copy the rules from `firebase/firestore.rules`
3. Publish the rules
4. Do the same for Storage rules from `firebase/storage.rules`

---

### 6. iOS Build Errors

**Pod Install Errors:**
```bash
cd ios
pod deintegrate
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..
flutter clean
flutter run -d ios
```

**Signing Issues:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner → Signing & Capabilities
3. Choose your Team
4. Xcode will handle provisioning profiles

---

### 7. Gradle Sync Failed

**Error:**
```
Gradle sync failed: ...
```

**Fix:**
1. Check internet connection
2. Delete Gradle cache:
   ```bash
   # Windows
   rd /s /q %USERPROFILE%\.gradle\caches
   
   # Mac/Linux
   rm -rf ~/.gradle/caches
   ```
3. In Android Studio: File → Invalidate Caches / Restart
4. Rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

### 8. MultiDex Error

**Error:**
```
Cannot fit requested classes in a single dex file
```

**Fix (Already Applied):**
MultiDex is enabled in `android/app/build.gradle`:
```gradle
defaultConfig {
    multiDexEnabled true
}
dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

---

### 9. Firebase Initialization Error

**Error:**
```
No Firebase App '[DEFAULT]' has been created
```

**Fix:**
Ensure Firebase is initialized in `main.dart` before `runApp()`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MemoryJarApp()));
}
```

---

### 10. Image Picker Not Working

**Android:**
Permissions are already set in `AndroidManifest.xml`:
- `CAMERA`
- `READ_MEDIA_IMAGES`
- `READ_EXTERNAL_STORAGE`

**iOS:**
Permissions are already set in `Info.plist`:
- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`

---

### 11. Build Taking Too Long

**Speed up builds:**
1. Enable Gradle daemon (already configured)
2. Increase memory in `android/gradle.properties`:
   ```
   org.gradle.jvmargs=-Xmx4G
   ```
3. Use `flutter run --debug` for development
4. Use `flutter build apk --release` only for production

---

## Clean Build Commands

```bash
# Full clean rebuild
flutter clean
cd android && ./gradlew clean && cd ..
cd ios && pod deintegrate && pod install && cd ..
flutter pub get
flutter run
```

## Still Having Issues?

1. Check Flutter doctor: `flutter doctor -v`
2. Update Flutter: `flutter upgrade`
3. Check Dart version: `dart --version` (needs >=3.2.0)
4. Verify Firebase config files are present:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

---

## Contact

If issues persist after trying all fixes, check:
- Flutter GitHub issues
- Firebase Flutter plugin issues
- Stack Overflow with error messages
