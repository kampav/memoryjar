import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/user_model.dart';

// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Auth state stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

// User document provider
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

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService(this._auth);

  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
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
      
      // Create or update user document
      if (userCredential.user != null) {
        await _createOrUpdateUserDocument(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
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
      rethrow;
    }
  }

  // Register with email and password
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
      rethrow;
    }
  }

  // Sign in anonymously
  Future<UserCredential> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      
      if (userCredential.user != null) {
        await _createOrUpdateUserDocument(userCredential.user!, isAnonymous: true);
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Create or update user document in Firestore
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
      );
      
      await userDoc.set(newUser.toFirestore());
    } else {
      await _updateLastActive(user.uid);
    }
  }

  // Update last active timestamp
  Future<void> _updateLastActive(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? avatarEmoji,
    String? familyId,
  }) async {
    final updates = <String, dynamic>{
      'lastActive': FieldValue.serverTimestamp(),
    };
    
    if (displayName != null) updates['displayName'] = displayName;
    if (avatarEmoji != null) updates['avatarEmoji'] = avatarEmoji;
    if (familyId != null) updates['familyId'] = familyId;
    
    await _firestore.collection('users').doc(uid).update(updates);
  }

  // Check if user needs onboarding
  Future<bool> needsOnboarding(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return true;
    
    final data = doc.data();
    return data?['displayName'] == null || 
           data?['displayName'] == 'Memory Keeper' ||
           data?['avatarEmoji'] == null;
  }
}

// Provider for checking if user needs onboarding
final needsOnboardingProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  
  final authService = ref.watch(authServiceProvider);
  return await authService.needsOnboarding(user.uid);
});
