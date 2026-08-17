import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../core/services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseService _firebaseService = FirebaseService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      UserModel baseUser = UserModel.fromFirebaseUser(firebaseUser);

      // Fetch additional profile data (gender, dob)
      if (!baseUser.isGuest) {
        try {
          final profileData = await _firebaseService.getUserProfile(
            baseUser.uid,
          );
          if (profileData != null) {
            baseUser = baseUser.copyWith(
              gender: profileData['gender'],
              dob: profileData['dob'],
            );
          }
        } catch (e, stackTrace) {
          debugPrint('Error fetching user profile: $e\n$stackTrace');
        }
      }

      _user = baseUser;
    } else {
      _user = null;
    }
    notifyListeners();
  }

  /// Clear any previous error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign in with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      debugPrint('Login unexpected error: $e\n$stackTrace');
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Create a new account with email and password
  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Set the display name
      await credential.user?.updateDisplayName(name);
      // Reload to get updated profile
      await credential.user?.reload();
      // Update local user model with the display name
      final updatedUser = _auth.currentUser;
      if (updatedUser != null) {
        _user = UserModel.fromFirebaseUser(updatedUser);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Exception in signUp: ${e.code} - ${e.message}');
      _isLoading = false;
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      debugPrint('SignUp unexpected error: $e\n$stackTrace');
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      debugPrint('Google sign-in failed: $e\n$stackTrace');
      _isLoading = false;
      _errorMessage = 'Google sign-in failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Continue as anonymous guest
  Future<void> continueAsGuest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInAnonymously();
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Guest sign-in failed: $e\n$stackTrace');
      _isLoading = false;
      _errorMessage = 'Could not sign in as guest. Please try again.';
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> logout() async {
    // 1. Immediately clear the local user state.
    // This synchronously triggers the ProxyProviders (MoodProvider, MoodThemeProvider)
    // to receive a null user, causing them to cancel their listeners and clear
    // their in-memory data *before* the async sign-out finishes.
    _user = null;
    notifyListeners();

    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Google sign out may fail if not signed in with Google — ignore
    }
    
    // 4. Sign out Firebase user
    await _auth.signOut();

    // We intentionally DO NOT call clearPersistence() or terminate() here to 
    // preserve logical user isolation without destroying Firestore cache stability.
  }

  /// Map Firebase error codes to user-friendly messages
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'requires-recent-login':
        return 'This operation requires a recent login. Please log out and log back in, then try again.';
      default:
        return 'Authentication failed ($code). Please try again.';
    }
  }

  /// Update Profile Details (Optimistic Update for speed)
  Future<bool> updateProfileDetails({
    required String name,
    String? gender,
    String? dob,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      // 1. Optimistic Update: Update local state immediately
      if (_user != null) {
        _user = _user!.copyWith(name: name, gender: gender, dob: dob);
      }

      // 2. Fire backend updates without awaiting them to block the UI
      // We catch errors silently here so they don't crash the app if they fail later
      Future.microtask(() async {
        try {
          await Future.wait([
            currentUser.updateDisplayName(name),
            _firebaseService.saveUserProfile(currentUser.uid, {
              'name': name,
              'gender': gender,
              'dob': dob,
            }),
          ]);
        } catch (e, stackTrace) {
          debugPrint('Background update profile error: $e\n$stackTrace');
        }
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      debugPrint('Update profile error: $e\n$stackTrace');
      _isLoading = false;
      _errorMessage = 'Failed to update profile. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Update Email Address
  Future<bool> updateEmail(String newEmail) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      await currentUser.verifyBeforeUpdateEmail(newEmail);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      debugPrint('Update email unexpected error: $e\n$stackTrace');
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred.';
      notifyListeners();
      return false;
    }
  }

  /// Update Password
  Future<bool> updatePassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      await currentUser.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      debugPrint('Update password unexpected error: $e\n$stackTrace');
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred.';
      notifyListeners();
      return false;
    }
  }
}
