import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsis;
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/services/email_service.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EmailService _emailService = EmailService();
  final dynamic _googleSignIn = gsis.GoogleSignIn.instance;

  @override
  Future<UserEntity?> login(
    String email,
    String password, {
    String? selectedRole,
  }) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          final String userRole = data['role'] ?? '';

          if (selectedRole == 'admin' && userRole != 'admin') {
            await _firebaseAuth.signOut();
            return null;
          }

          final user = UserEntity(
            id: credential.user!.uid,
            email: email,
            name: data['name'] ?? '',
            role: userRole,
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userId', user.id);
          await prefs.setString('userRole', user.role);

          return user;
        } else {
          await _firebaseAuth.signOut();
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserEntity?> signUp(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        final user = UserEntity(
          id: credential.user!.uid,
          email: email,
          name: name,
          role: role,
        );

        await _firestore.collection('users').doc(user.id).set({
          'name': name,
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', user.id);
        await prefs.setString('userRole', user.role);

        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserEntity?> signInWithGoogle(String role) async {
    try {
      // 1. Initialize for v7+ (Uses Google Identity Services)
      await _googleSignIn.initialize(
        serverClientId: 'your-web-client-id.googleusercontent.com',
      );

      // 2. Clear and Authenticate
      await _googleSignIn.signOut();
      final gsis.GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();
      if (googleUser == null) return null;

      // 3. Get Tokens from Authentication (REQUIRED for Firebase)
      final dynamic googleAuth = await googleUser.authentication;

      // 4. Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // 5. Sign in to Firebase
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      if (userCredential.user != null) {
        final userId = userCredential.user!.uid;
        final doc = await _firestore.collection('users').doc(userId).get();

        String finalRole = role;
        String name = userCredential.user!.displayName ?? '';
        String email = userCredential.user!.email ?? '';

        if (!doc.exists) {
          // New User - Create document
          await _firestore.collection('users').doc(userId).set({
            'name': name,
            'email': email,
            'role': role,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Existing User
          final data = doc.data() as Map<String, dynamic>;
          finalRole = data['role'] ?? role;
          name = data['name'] ?? name;
          email = data['email'] ?? email;
        }

        final user = UserEntity(
          id: userId,
          email: email,
          name: name,
          role: finalRole,
        );

        // Persist session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', user.id);
        await prefs.setString('userRole', user.role);

        return user;
      }
      return null;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        return UserEntity(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          name: data['name'] ?? '',
          role: data['role'] ?? '',
        );
      }
    }
    return null;
  }

  @override
  Future<bool> sendPasswordResetOtp(String email) async {
    try {
      final String otp = (100000 + Random().nextInt(900000)).toString();

      // Store OTP in Firestore using 'otp_resets' as requested
      await _firestore.collection('otp_resets').doc(email).set({
        'otp': otp,
        'email': email,
        'expires': DateTime.now().add(const Duration(minutes: 5)),
        'used': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send via SMTP using your existing service
      return await _emailService.sendOtpEmail(email, otp);
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  @override
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final doc = await _firestore.collection('otp_resets').doc(email).get();

      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      if (data['used'] == true ||
          DateTime.now().isAfter((data['expires'] as Timestamp).toDate())) {
        return false;
      }

      if (data['otp'] != otp) return false;

      // Mark as used
      await _firestore.collection('otp_resets').doc(email).update({
        'used': true,
      });
      return true;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  @override
  Future<bool> updatePassword(String email, String newPassword) async {
    try {
      // ✅ ONLY option without current password: Email reset
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent to $email');
      return true;
    } catch (e) {
      print('Reset email failed: $e');
      return false;
    }
  }

  // New method for Change Password where we HAVE the current password
  @override
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      // Re-authenticate to prevent 'requires-recent-login'
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }
}
