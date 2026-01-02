import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/jar_model.dart';

// ============================================
// SHARED PREFERENCES PROVIDER
// ============================================
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

// ============================================
// FIREBASE AUTH PROVIDER
// ============================================
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// ============================================
// AUTH INITIALIZATION STATE
// ============================================
/// Tracks whether Firebase Auth has completed initialization
/// This is crucial for fixing the login persistence issue
final authInitializedProvider = StateProvider<bool>((ref) => false);

// ============================================
// AUTH STATE STREAM PROVIDER
// ============================================
/// Properly streams auth state changes
/// The key fix: This now properly waits for Firebase to restore the session
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// ============================================
// CURRENT USER PROVIDER
// ============================================
/// Provides synchronous access to current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

// ============================================
// USER DOCUMENT STREAM PROVIDER
// ============================================
/// Streams the user document from Firestore
final userDocProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        return UserModel.fromFirestore(doc);
      });
});

// ============================================
// THEME MODE PROVIDER WITH PERSISTENCE
// ============================================
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  static const String _key = 'theme_mode';

  ThemeModeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final value = _prefs.getString(_key);
    if (value != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_key, mode.name);
  }

  /// Compatibility alias for older callers
  Future<void> setThemeMode(ThemeMode mode) async => setTheme(mode);
}

// ============================================
// AUTH SERVICE PROVIDER
// ============================================
final authServiceProvider = Provider<AuthService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthService(ref.watch(firebaseAuthProvider), prefs);
});

// ============================================
// AUTH SERVICE CLASS
// ============================================
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SharedPreferences _prefs;

  // Preference keys
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _termsAcceptedKey = 'terms_accepted';

  AuthService(this._auth, this._prefs);

  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ============================================
  // CRITICAL FIX: Wait for auth state restoration
  // ============================================
  /// This method properly waits for Firebase Auth to restore the session
  /// before checking if the user is authenticated
  Future<bool> isAuthenticated() async {
    // Give Firebase Auth time to restore the session from secure storage
    // This is the key fix for the login persistence issue
    await Future.delayed(const Duration(milliseconds: 500));
    return _auth.currentUser != null;
  }

  /// Check if user is logged in with a longer timeout for cold starts
  Future<User?> waitForAuthReady({Duration timeout = const Duration(seconds: 3)}) async {
    final stopwatch = Stopwatch()..start();
    
    while (stopwatch.elapsed < timeout) {
      final user = _auth.currentUser;
      if (user != null) {
        return user;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return _auth.currentUser;
  }

  // ============================================
  // LOCAL ONBOARDING STATE
  // ============================================
  bool get isOnboardingComplete => _prefs.getBool(_onboardingCompleteKey) ?? false;
  
  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_onboardingCompleteKey, value);
  }

  bool get hasAcceptedTerms => _prefs.getBool(_termsAcceptedKey) ?? false;
  
  Future<void> setTermsAccepted(bool value) async {
    await _prefs.setBool(_termsAcceptedKey, value);
  }

  // ============================================
  // SIGN IN METHODS
  // ============================================
  
  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _createOrUpdateUserDocument(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      rethrow;
    }
  }

  /// Sign in with Apple (stub for platforms that support it)
  Future<UserCredential?> signInWithApple() async {
    // Apple sign-in isn't required for our main validation flow; provide a
    // simple stub that returns null (no-op) so UI can call it safely.
    debugPrint('signInWithApple is not implemented on this platform');
    return null;
  }

  /// Update profile with optional photo upload
  Future<void> updateProfile({
    String? displayName,
    File? photoFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final updates = <String, dynamic>{
      'lastActive': FieldValue.serverTimestamp(),
    };

    if (displayName != null) updates['displayName'] = displayName;

    if (photoFile != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('profile')
          .child('avatar.jpg');

      final uploadTask = storageRef.putFile(
        photoFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      await uploadTask;
      final url = await storageRef.getDownloadURL();
      updates['avatarUrl'] = url;
    }

    await _firestore.collection('users').doc(user.uid).update(updates);
  }

  /// Create a new jar and add the creator as a member
  Future<String> createJar({required JarType type, required String name}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final jarRef = _firestore.collection('jars').doc();
    final inviteCode = _generateInviteCode();

    final jarData = {
      'name': name,
      'type': type.name,
      'inviteCode': inviteCode,
      'members': {
        user.uid: {
          'role': 'owner',
          'joinedAt': FieldValue.serverTimestamp(),
          'displayName': user.displayName ?? '',
          'avatarEmoji': null,
        }
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await jarRef.set(jarData);

    // Add jarId to user's doc
    await _firestore.collection('users').doc(user.uid).update({
      'jarIds': FieldValue.arrayUnion([jarRef.id])
    });

    return jarRef.id;
  }

  /// Join a jar using an invite code
  Future<void> joinJar(String inviteCode) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final query = await _firestore
        .collection('jars')
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) throw Exception('Invite code not found');

    final jarDoc = query.docs.first;
    final jarRef = jarDoc.reference;

    await jarRef.update({
      'members.${user.uid}': {
        'role': 'member',
        'joinedAt': FieldValue.serverTimestamp(),
        'displayName': user.displayName ?? '',
        'avatarEmoji': null,
      }
    });

    await _firestore.collection('users').doc(user.uid).update({
      'jarIds': FieldValue.arrayUnion([jarRef.id])
    });
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await _updateLastActive(userCredential.user!.uid);
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('Email Sign In Error: $e');
      rethrow;
    }
  }

  /// Register with email and password
  Future<UserCredential> registerWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await _createOrUpdateUserDocument(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('Email Registration Error: $e');
      rethrow;
    }
  }

  /// Sign in anonymously
  Future<UserCredential> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      
      if (userCredential.user != null) {
        await _createOrUpdateUserDocument(userCredential.user!, isAnonymous: true);
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('Anonymous Sign In Error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    // Clear local preferences
    await _prefs.remove(_onboardingCompleteKey);
    await _prefs.remove(_termsAcceptedKey);
    
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ============================================
  // USER DOCUMENT METHODS
  // ============================================
  
  /// Create or update user document in Firestore
  Future<void> _createOrUpdateUserDocument(User user, {bool isAnonymous = false}) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      final newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'Memory Keeper',
        avatarUrl: user.photoURL,
        isAnonymous: isAnonymous,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
        settings: UserSettings(),
        stats: UserStats(),
        jarIds: [],
        hasCompletedOnboarding: false,
        hasAcceptedTerms: false,
      );
      
      await userDoc.set(newUser.toFirestore());
    } else {
      await _updateLastActive(user.uid);
    }
  }

  /// Update last active timestamp
  Future<void> _updateLastActive(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? avatarEmoji,
    List<String>? jarIds,
    String? familyId,
  }) async {
    final updates = <String, dynamic>{
      'lastActive': FieldValue.serverTimestamp(),
    };
    
    if (displayName != null) updates['displayName'] = displayName;
    if (avatarEmoji != null) updates['avatarEmoji'] = avatarEmoji;
    if (jarIds != null) updates['jarIds'] = jarIds;
    if (familyId != null) updates['familyId'] = familyId;
    
    await _firestore.collection('users').doc(uid).update(updates);
  }

  /// Update user settings
  Future<void> updateUserSettings({
    required String uid,
    bool? notificationsEnabled,
    bool? dailyReminder,
    bool? hapticFeedback,
    bool? soundEffects,
  }) async {
    final updates = <String, dynamic>{
      'lastActive': FieldValue.serverTimestamp(),
    };
    
    if (notificationsEnabled != null) {
      updates['settings.notificationsEnabled'] = notificationsEnabled;
    }
    if (dailyReminder != null) {
      updates['settings.dailyReminder'] = dailyReminder;
    }
    if (hapticFeedback != null) {
      updates['settings.hapticFeedback'] = hapticFeedback;
    }
    if (soundEffects != null) {
      updates['settings.soundEffects'] = soundEffects;
    }
    
    await _firestore.collection('users').doc(uid).update(updates);
  }

  /// Mark onboarding as complete in Firestore
  Future<void> completeOnboarding(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'hasCompletedOnboarding': true,
      'lastActive': FieldValue.serverTimestamp(),
    });
    await setOnboardingComplete(true);
  }

  /// Mark terms as accepted
  Future<void> acceptTerms(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'hasAcceptedTerms': true,
      'termsAcceptedAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    });
    await setTermsAccepted(true);
  }

  /// Check if user needs onboarding
  Future<bool> needsOnboarding([String? uid]) async {
    final id = uid ?? _auth.currentUser?.uid;
    if (id == null) return true;

    final doc = await _firestore.collection('users').doc(id).get();
    if (!doc.exists) return true;

    final data = doc.data();

    // Check multiple conditions for onboarding completion
    final hasCompletedOnboarding = data?['hasCompletedOnboarding'] ?? false;
    final hasAcceptedTerms = data?['hasAcceptedTerms'] ?? false;
    final hasProfile = data?['displayName'] != null && 
                       data?['displayName'] != 'Memory Keeper' &&
                       data?['avatarEmoji'] != null;

    return !hasCompletedOnboarding || !hasAcceptedTerms || !hasProfile;
  }

  /// Check if user needs to accept terms only
  Future<bool> needsTermsAcceptance(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return true;
    
    final data = doc.data();
    return !(data?['hasAcceptedTerms'] ?? false);
  }

  // ============================================
  // ACCOUNT MANAGEMENT (GDPR)
  // ============================================
  
  /// Export user data (GDPR Data Portability)
  Future<Map<String, dynamic>> exportUserData(String uid) async {
    final userData = await _firestore.collection('users').doc(uid).get();
    final memories = await _firestore
        .collection('memories')
        .where('authorId', isEqualTo: uid)
        .get();
    
    return {
      'user': userData.data(),
      'memories': memories.docs.map((d) => d.data()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Delete user account (GDPR Right to Erasure)
  Future<void> deleteAccount(String uid) async {
    // Delete user document
    await _firestore.collection('users').doc(uid).delete();
    
    // Delete user memories
    final memories = await _firestore
        .collection('memories')
        .where('authorId', isEqualTo: uid)
        .get();
    
    for (final doc in memories.docs) {
      await doc.reference.delete();
    }
    
    // Clear local preferences
    await _prefs.clear();
    
    // Delete Firebase Auth account
    await _auth.currentUser?.delete();
  }
}

// ============================================
// NEEDS ONBOARDING PROVIDER
// ============================================
final needsOnboardingProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  
  final authService = ref.watch(authServiceProvider);
  return await authService.needsOnboarding(user.uid);
});

// ============================================
// NEEDS TERMS PROVIDER
// ============================================
final needsTermsProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  
  final authService = ref.watch(authServiceProvider);
  return await authService.needsTermsAcceptance(user.uid);
});
