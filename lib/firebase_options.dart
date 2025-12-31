import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAglc0OTKjHNe7FG64E1UmrojobN2omahI',
    appId: '1:577582673730:android:8c71bada45ae02952862db',
    messagingSenderId: '577582673730',
    projectId: 'memory-jarapp',
    storageBucket: 'memory-jarapp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCDQe2CaVWPFr20xQJTsxZCuJsULEyNxHk',
    appId: '1:577582673730:ios:3b2269fa0e22632b2862db',
    messagingSenderId: '577582673730',
    projectId: 'memory-jarapp',
    storageBucket: 'memory-jarapp.firebasestorage.app',
    iosBundleId: 'com.familylegacy.memoryJar',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAglc0OTKjHNe7FG64E1UmrojobN2omahI',
    appId: '1:577582673730:web:e25cd53277e50ee92862db',
    messagingSenderId: '577582673730',
    projectId: 'memory-jarapp',
    storageBucket: 'memory-jarapp.firebasestorage.app',
    authDomain: 'memory-jarapp.firebaseapp.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCDQe2CaVWPFr20xQJTsxZCuJsULEyNxHk',
    appId: '1:577582673730:ios:3b2269fa0e22632b2862db',
    messagingSenderId: '577582673730',
    projectId: 'memory-jarapp',
    storageBucket: 'memory-jarapp.firebasestorage.app',
    iosBundleId: 'com.familylegacy.memoryJar',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAglc0OTKjHNe7FG64E1UmrojobN2omahI',
    appId: '1:577582673730:web:e25cd53277e50ee92862db',
    messagingSenderId: '577582673730',
    projectId: 'memory-jarapp',
    storageBucket: 'memory-jarapp.firebasestorage.app',
    authDomain: 'memory-jarapp.firebaseapp.com',
  );
}
