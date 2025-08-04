import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/user_service.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return AuthService(prefs: prefs);
});

/// Provider for authentication state changes
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for current Firebase user
final currentFirebaseUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for checking if user has logged in at least once
final hasLoggedInOnceProvider = Provider<bool>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.hasLoggedInOnce;
});

/// Provider for checking if biometric auth is enabled
final isBiometricEnabledProvider = Provider<bool>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.isBiometricEnabled;
});

/// Provider for checking biometric availability
final biometricAvailabilityProvider = FutureProvider<bool>((ref) async {
  final authService = ref.read(authServiceProvider);
  return await authService.isBiometricAvailable();
});

/// Provider for available biometric types
final availableBiometricsProvider = FutureProvider<List<BiometricType>>((ref) async {
  final authService = ref.read(authServiceProvider);
  return await authService.getAvailableBiometrics();
});

/// Notifier for authentication operations
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(this._authService, this._ref) : super(const AsyncValue.data(null));

  final AuthService _authService;
  final Ref _ref;

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    state = const AsyncValue.loading();
    
    try {
      final userCredential = await _authService.signInWithGoogle();
      state = const AsyncValue.data(null);
      
      // Invalidate related providers
      _ref.invalidate(hasLoggedInOnceProvider);
      _ref.invalidate(authStateProvider);
      
      return userCredential;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    state = const AsyncValue.loading();
    
    try {
      final userCredential = await _authService.signInWithApple();
      state = const AsyncValue.data(null);
      
      // Invalidate related providers
      _ref.invalidate(hasLoggedInOnceProvider);
      _ref.invalidate(authStateProvider);
      
      return userCredential;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final userCredential = await _authService.signInWithEmailAndPassword(email, password);
      state = const AsyncValue.data(null);
      
      // Invalidate related providers
      _ref.invalidate(hasLoggedInOnceProvider);
      _ref.invalidate(authStateProvider);
      
      return userCredential;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Create account with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email, 
    String password,
    String firstName,
    String lastName,
  ) async {
    state = const AsyncValue.loading();
    
    try {
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email, password, firstName, lastName,
      );
      state = const AsyncValue.data(null);
      
      // Invalidate related providers
      _ref.invalidate(hasLoggedInOnceProvider);
      _ref.invalidate(authStateProvider);
      
      return userCredential;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
      
      // Invalidate all auth-related providers
      _ref.invalidate(authStateProvider);
      _ref.invalidate(hasLoggedInOnceProvider);
      _ref.invalidate(isBiometricEnabledProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    
    try {
      await _authService.deleteAccount();
      state = const AsyncValue.data(null);
      
      // Invalidate all related providers
      _ref.invalidate(authStateProvider);
      _ref.invalidate(hasLoggedInOnceProvider);
      _ref.invalidate(isBiometricEnabledProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    
    try {
      await _authService.resetPassword(email);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Enable biometric authentication
  Future<bool> enableBiometricAuth() async {
    state = const AsyncValue.loading();
    
    try {
      final success = await _authService.enableBiometricAuth();
      state = const AsyncValue.data(null);
      
      // Invalidate biometric providers
      _ref.invalidate(isBiometricEnabledProvider);
      
      return success;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometricAuth() async {
    state = const AsyncValue.loading();
    
    try {
      await _authService.disableBiometricAuth();
      state = const AsyncValue.data(null);
      
      // Invalidate biometric providers
      _ref.invalidate(isBiometricEnabledProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics({String? reason}) async {
    try {
      return await _authService.authenticateWithBiometrics(reason: reason);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for authentication operations
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService, ref);
});

/// Provider for current user profile
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final userService = ref.read(userServiceProvider);
  return userService.watchCurrentUser();
});

/// Provider for UserService
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

/// Provider for user display information
final userDisplayInfoProvider = Provider<UserDisplayInfo?>((ref) {
  final firebaseUser = ref.watch(currentFirebaseUserProvider);
  final appUser = ref.watch(currentUserProvider);
  
  if (firebaseUser == null) return null;
  
  return appUser.when(
    data: (user) => UserDisplayInfo(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: user?.displayName ?? firebaseUser.displayName,
      photoURL: user?.photoUrl ?? firebaseUser.photoURL,
      firstName: user?.firstName,
      lastName: user?.lastName,
      isEmailVerified: firebaseUser.emailVerified,
    ),
    loading: () => UserDisplayInfo(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
    ),
    error: (_, __) => UserDisplayInfo(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
    ),
  );
});

/// User display information model
class UserDisplayInfo {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? firstName;
  final String? lastName;
  final bool isEmailVerified;

  const UserDisplayInfo({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.firstName,
    this.lastName,
    required this.isEmailVerified,
  });

  String get formattedName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName ?? email?.split('@').first ?? 'User';
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName!.isNotEmpty ? firstName![0] : ''}${lastName!.isNotEmpty ? lastName![0] : ''}'.toUpperCase();
    }
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    if (email != null && email!.isNotEmpty) {
      return email![0].toUpperCase();
    }
    return 'U';
  }
}