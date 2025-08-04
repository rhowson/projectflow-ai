import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/user_service.dart';

/// Comprehensive authentication service for ProjectFlow AI
/// Handles Google Sign-In, Apple Sign-In, Firebase Auth, and biometric authentication
class AuthService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _hasLoggedInOnceKey = 'has_logged_in_once';
  
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final LocalAuthentication _localAuth;
  final UserService _userService;
  final SharedPreferences _prefs;

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    LocalAuthentication? localAuth,
    UserService? userService,
    required SharedPreferences prefs,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(
          clientId: kIsWeb 
            ? '539417743939-lc2s6m6cv9e2tlccq506dqot2fm2a8kc.apps.googleusercontent.com'
            : null,
        ),
        _localAuth = localAuth ?? LocalAuthentication(),
        _userService = userService ?? UserService(),
        _prefs = prefs;

  /// Current authenticated user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Whether user has logged in at least once
  bool get hasLoggedInOnce => _prefs.getBool(_hasLoggedInOnceKey) ?? false;

  /// Whether biometric authentication is enabled
  bool get isBiometricEnabled => _prefs.getBool(_biometricEnabledKey) ?? false;

  /// Check if Apple Sign-In is available on the current platform
  bool get isAppleSignInAvailable => !kIsWeb;

  /// Check if biometric authentication is supported on the current platform  
  bool get isBiometricSupported => !kIsWeb;

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
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
          await _firebaseAuth.signInWithCredential(credential);

      // Create or update user profile
      await _createOrUpdateUserProfile(userCredential.user!, AuthProvider.google);
      
      // Mark as logged in at least once
      await _setHasLoggedInOnce(true);

      return userCredential;
    } catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }
  }

  /// Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    // Apple Sign-In is not available on web platform
    if (kIsWeb) {
      throw AuthException('Apple Sign-In is not available on web platform');
    }
    
    try {
      // Request credential for the currently signed in Apple account
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in to Firebase with the Apple credential
      final UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(oauthCredential);

      // Create or update user profile with Apple-specific data
      await _createOrUpdateUserProfile(
        userCredential.user!, 
        AuthProvider.apple,
        appleCredential: appleCredential,
      );
      
      // Mark as logged in at least once
      await _setHasLoggedInOnce(true);

      return userCredential;
    } catch (e) {
      throw AuthException('Apple sign-in failed: $e');
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      
      // Update last login time
      if (userCredential.user != null) {
        await _userService.updateLastLogin(userCredential.user!.uid);
        await _setHasLoggedInOnce(true);
      }

      return userCredential;
    } catch (e) {
      throw AuthException('Email sign-in failed: $e');
    }
  }

  /// Create account with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email, 
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      
      if (userCredential.user != null) {
        // Create user profile
        await _createOrUpdateUserProfile(
          userCredential.user!, 
          AuthProvider.email,
          firstName: firstName,
          lastName: lastName,
        );
        
        // Send email verification
        await userCredential.user!.sendEmailVerification();
        
        await _setHasLoggedInOnce(true);
      }

      return userCredential;
    } catch (e) {
      throw AuthException('Account creation failed: $e');
    }
  }

  /// Sign out from all providers
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      // Sign out from Firebase
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw AuthException('No user signed in');

      // Delete user profile from Firestore
      await _userService.deleteUser(user.uid);
      
      // Delete Firebase Auth account
      await user.delete();
      
      // Clear local preferences
      await _clearLocalPreferences();
    } catch (e) {
      throw AuthException('Account deletion failed: $e');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw AuthException('Password reset failed: $e');
    }
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    // Biometric authentication is not available on web platform
    if (kIsWeb) {
      return false;
    }
    
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    // Biometric authentication is not available on web platform
    if (kIsWeb) {
      return [];
    }
    
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Enable biometric authentication
  Future<bool> enableBiometricAuth() async {
    try {
      if (!hasLoggedInOnce) {
        throw AuthException('Must log in with credentials at least once before enabling biometrics');
      }

      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw AuthException('Biometric authentication is not available on this device');
      }

      // Test biometric authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Enable biometric authentication for ProjectFlow AI',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        await _prefs.setBool(_biometricEnabledKey, true);
        return true;
      }

      return false;
    } catch (e) {
      throw AuthException('Failed to enable biometric authentication: $e');
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometricAuth() async {
    await _prefs.setBool(_biometricEnabledKey, false);
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics({String? reason}) async {
    try {
      if (!isBiometricEnabled) {
        throw AuthException('Biometric authentication is not enabled');
      }

      return await _localAuth.authenticate(
        localizedReason: reason ?? 'Authenticate to access ProjectFlow AI',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      throw AuthException('Biometric authentication failed: $e');
    }
  }

  /// Create or update user profile after authentication
  Future<void> _createOrUpdateUserProfile(
    User firebaseUser, 
    AuthProvider provider, {
    AuthorizationCredentialAppleID? appleCredential,
    String? firstName,
    String? lastName,
  }) async {
    try {
      // Check if user profile already exists
      final existingUser = await _userService.getUserById(firebaseUser.uid);
      
      if (existingUser != null) {
        // Update existing user's last login
        await _userService.updateLastLogin(firebaseUser.uid);
        return;
      }

      // Extract names from different providers
      String userFirstName = firstName ?? '';
      String userLastName = lastName ?? '';
      String displayName = firebaseUser.displayName ?? '';

      if (provider == AuthProvider.apple && appleCredential != null) {
        userFirstName = appleCredential.givenName ?? '';
        userLastName = appleCredential.familyName ?? '';
        displayName = '$userFirstName $userLastName'.trim();
      } else if (provider == AuthProvider.google && firebaseUser.displayName != null) {
        final nameParts = firebaseUser.displayName!.split(' ');
        userFirstName = nameParts.isNotEmpty ? nameParts.first : '';
        userLastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        displayName = firebaseUser.displayName!;
      }

      // Create new user profile
      final newUser = AppUser.createNew(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        firstName: userFirstName,
        lastName: userLastName,
        photoUrl: firebaseUser.photoURL,
        role: UserRole.member,
      ).copyWith(
        displayName: displayName.isEmpty ? '$userFirstName $userLastName'.trim() : displayName,
        isEmailVerified: firebaseUser.emailVerified,
        authProvider: provider.name,
      );

      await _userService.createUser(newUser);
    } catch (e) {
      throw AuthException('Failed to create user profile: $e');
    }
  }

  /// Set whether user has logged in at least once
  Future<void> _setHasLoggedInOnce(bool value) async {
    await _prefs.setBool(_hasLoggedInOnceKey, value);
  }

  /// Clear all local preferences
  Future<void> _clearLocalPreferences() async {
    await _prefs.remove(_biometricEnabledKey);
    await _prefs.remove(_hasLoggedInOnceKey);
  }

  /// Generate a cryptographically secure nonce
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Generate SHA256 hash of input string
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Authentication provider enum
enum AuthProvider {
  email,
  google,
  apple,
}

/// Custom exception for authentication operations
class AuthException implements Exception {
  final String message;
  
  const AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}