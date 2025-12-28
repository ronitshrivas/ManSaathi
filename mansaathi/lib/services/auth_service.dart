import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import '../core/constants/app_constants.dart';

/// Authentication Service - Handles Firebase Auth
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==================== ANONYMOUS AUTH ====================

  /// Sign in anonymously (Guest mode)
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      debugPrint('✅ Anonymous sign-in successful: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e) {
      debugPrint('❌ Anonymous sign-in error: $e');
      rethrow;
    }
  }

  // ==================== EMAIL/PASSWORD AUTH ====================

  /// Sign up with email and password
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      debugPrint('✅ Email sign-up successful: ${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Email sign-up error: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Email sign-up error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      debugPrint('✅ Email sign-in successful: ${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Email sign-in error: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Email sign-in error: $e');
      rethrow;
    }
  }

  // ==================== PHONE AUTH ====================

  String? _verificationId;
  int? _resendToken;

  /// Send OTP to phone number
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(User user)? onAutoVerified,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        // Auto-verification (instant)
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            debugPrint('✅ Phone auto-verified: ${userCredential.user?.uid}');
            if (onAutoVerified != null && userCredential.user != null) {
              onAutoVerified(userCredential.user!);
            }
          } catch (e) {
            debugPrint('❌ Auto-verification error: $e');
            onError('Auto-verification failed: $e');
          }
        },

        // Verification failed
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Phone verification failed: ${e.code}');
          onError(_handleAuthException(e));
        },

        // Code sent successfully
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('✅ OTP sent successfully');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },

        // Code timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⏱️ OTP auto-retrieval timeout');
          _verificationId = verificationId;
        },

        forceResendingToken: _resendToken,
      );
    } catch (e) {
      debugPrint('❌ Send OTP error: $e');
      onError('Failed to send OTP: $e');
    }
  }

  /// Verify OTP and sign in
  Future<User?> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint(
        '✅ Phone verification successful: ${userCredential.user?.uid}',
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ OTP verification error: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ OTP verification error: $e');
      rethrow;
    }
  }

  // ==================== PASSWORD RESET ====================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      debugPrint('✅ Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password reset error: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Password reset error: $e');
      rethrow;
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      debugPrint('✅ Password updated successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password update error: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Password update error: $e');
      rethrow;
    }
  }

  // ==================== SIGN OUT ====================

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('✅ User signed out successfully');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      rethrow;
    }
  }

  // ==================== ACCOUNT DELETION ====================

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      debugPrint('✅ Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Account deletion error: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Account deletion error: $e');
      rethrow;
    }
  }

  // ==================== RE-AUTHENTICATION ====================

  /// Re-authenticate with email/password (required for sensitive operations)
  Future<void> reauthenticateWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );

      await _auth.currentUser?.reauthenticateWithCredential(credential);
      debugPrint('✅ Re-authentication successful');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Re-authentication error: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Re-authentication error: $e');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Generate anonymous display name
  String generateAnonymousName() {
    final random = Random();
    final prefix =
        AppConstants.anonymousNamePrefixes[random.nextInt(
          AppConstants.anonymousNamePrefixes.length,
        )];
    final suffix =
        AppConstants.anonymousNameSuffixes[random.nextInt(
          AppConstants.anonymousNameSuffixes.length,
        )];

    return '$prefix $suffix';
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'अवैध ईमेल ठेगाना। (Invalid email address)';
      case 'user-disabled':
        return 'यो खाता निष्क्रिय गरिएको छ। (This account has been disabled)';
      case 'user-not-found':
        return 'यो ईमेल संग कुनै खाता फेला परेन। (No account found with this email)';
      case 'wrong-password':
        return 'गलत पासवर्ड। (Wrong password)';
      case 'email-already-in-use':
        return 'यो ईमेल पहिले नै प्रयोगमा छ। (This email is already in use)';
      case 'operation-not-allowed':
        return 'यो सेवा उपलब्ध छैन। (This service is not available)';
      case 'weak-password':
        return 'पासवर्ड धेरै कमजोर छ। (Password is too weak)';
      case 'invalid-verification-code':
        return 'गलत OTP कोड। (Invalid OTP code)';
      case 'invalid-verification-id':
        return 'प्रमाणीकरण असफल भयो। पुन: प्रयास गर्नुहोस्। (Verification failed. Please try again)';
      case 'too-many-requests':
        return 'धेरै प्रयास भयो। केही समय पछि पुन: प्रयास गर्नुहोस्। (Too many attempts. Try again later)';
      case 'requires-recent-login':
        return 'कृपया पुन: लगइन गर्नुहोस्। (Please login again)';
      case 'network-request-failed':
        return 'इन्टरनेट जडान छैन। (No internet connection)';
      default:
        return 'त्रुटि भयो: ${e.message ?? e.code}';
    }
  }

  /// Check if email is valid
  bool isEmailValid(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email.trim());
  }

  /// Check if password is strong enough
  bool isPasswordStrong(String password) {
    return password.length >= AppConstants.minPasswordLength;
  }

  /// Format phone number for Nepal
  String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Add +977 if not present (Nepal country code)
    if (!cleaned.startsWith('977')) {
      cleaned = '977$cleaned';
    }

    // Add + prefix
    if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }

    return cleaned;
  }
}
