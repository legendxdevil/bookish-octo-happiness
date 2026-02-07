import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/errors/failures.dart';
import '../data/models/user_model.dart';
import 'storage_service.dart';

/// Service for handling authentication (Email/Password and Google Sign-In)
/// Falls back to local-only mode if Firebase is not configured
class AuthService {
  FirebaseAuth? _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final StorageService _storageService = StorageService();
  bool _offlineMode = false;

  AuthService() {
    try {
      _firebaseAuth = FirebaseAuth.instance;
    } catch (e) {
      debugPrint('Firebase Auth not available, running in offline mode');
      _offlineMode = true;
    }
  }

  /// Get current Firebase user
  User? get currentUser => _firebaseAuth?.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth?.authStateChanges() ?? Stream.value(null);

  /// Check if user is signed in
  bool get isSignedIn => _offlineMode ? _storageService.getCurrentUser() != null : currentUser != null;

  /// Check if running in offline mode
  bool get isOfflineMode => _offlineMode;

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (_offlineMode) {
      // Local-only signup
      final userModel = UserModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName,
        isGoogleUser: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      await _storageService.saveUser(userModel);
      await _storageService.setAuthToken('local_token');
      return userModel;
    }

    try {
      final UserCredential credential = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthFailure('Failed to create user');
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);

      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        isGoogleUser: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _storageService.saveUser(userModel);
      await _storageService.setAuthToken(await credential.user!.getIdToken() ?? '');

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_getFirebaseAuthErrorMessage(e), code: e.code);
    } catch (e) {
      throw AuthFailure('Sign up failed: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (_offlineMode) {
      // Check local user
      final localUser = _storageService.getCurrentUser();
      if (localUser != null && localUser.email == email) {
        await _storageService.setAuthToken('local_token');
        return localUser.copyWith(lastLoginAt: DateTime.now());
      }
      throw const AuthFailure('Invalid email or password (offline mode)');
    }

    try {
      final UserCredential credential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthFailure('Failed to sign in');
      }

      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: credential.user!.displayName,
        photoUrl: credential.user!.photoURL,
        isGoogleUser: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _storageService.saveUser(userModel);
      await _storageService.setAuthToken(await credential.user!.getIdToken() ?? '');

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_getFirebaseAuthErrorMessage(e), code: e.code);
    } catch (e) {
      throw AuthFailure('Sign in failed: ${e.toString()}');
    }
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    if (_offlineMode) {
      throw const AuthFailure('Google Sign-In not available in offline mode');
    }

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthFailure('Google sign in cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await _firebaseAuth!.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthFailure('Failed to sign in with Google');
      }

      final userModel = UserModel(
        id: userCredential.user!.uid,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
        isGoogleUser: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _storageService.saveUser(userModel);
      await _storageService.setAuthToken(await userCredential.user!.getIdToken() ?? '');

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_getFirebaseAuthErrorMessage(e), code: e.code);
    } catch (e) {
      throw AuthFailure('Google sign in failed: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      if (!_offlineMode) {
        await _googleSignIn.signOut();
        await _firebaseAuth?.signOut();
      }
      await _storageService.clearAllData();
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
      throw AuthFailure('Sign out failed: ${e.toString()}');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    if (_offlineMode) {
      throw const AuthFailure('Password reset not available in offline mode');
    }

    try {
      await _firebaseAuth!.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_getFirebaseAuthErrorMessage(e), code: e.code);
    } catch (e) {
      throw AuthFailure('Password reset failed: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      if (!_offlineMode) {
        final user = _firebaseAuth?.currentUser;
        if (user != null) {
          if (displayName != null) {
            await user.updateDisplayName(displayName);
          }
          if (photoURL != null) {
            await user.updatePhotoURL(photoURL);
          }
        }
      }

      // Update local storage
      final currentUserModel = _storageService.getCurrentUser();
      if (currentUserModel != null) {
        await _storageService.saveUser(currentUserModel.copyWith(
          displayName: displayName ?? currentUserModel.displayName,
          photoUrl: photoURL ?? currentUserModel.photoUrl,
        ));
      }
    } catch (e) {
      throw AuthFailure('Profile update failed: ${e.toString()}');
    }
  }

  /// Re-authenticate user (required for sensitive operations)
  Future<void> reauthenticate(String password) async {
    if (_offlineMode) {
      // In offline mode, just verify local password
      return;
    }

    try {
      final user = _firebaseAuth?.currentUser;
      if (user == null) {
        throw const AuthFailure('No user logged in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_getFirebaseAuthErrorMessage(e), code: e.code);
    } catch (e) {
      throw AuthFailure('Re-authentication failed: ${e.toString()}');
    }
  }

  /// Get Firebase Auth error message
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return e.message ?? 'Authentication error occurred';
    }
  }
}
