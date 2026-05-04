import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsis;
import 'package:senior_care/models/user_entity.dart';

import 'package:senior_care/core/services/email_service.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EmailService _emailService = EmailService();
  final dynamic _googleSignIn = gsis.GoogleSignIn.instance;

  
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
            gender: data['gender'] ?? '',
            age: data['age']?.toString(),
            dob: data['dob'],
            phone: data['phone'],
            address: data['address'],
            alarmTone: data['alarmTone'],
            vibrationEnabled: data['vibrationEnabled'] ?? true,
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

  
  Future<UserEntity?> signUp(
    String name,
    String email,
    String password,
    String role,
    String gender, [
    String? profession,
  ]) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        final user = UserEntity(
          id: credential.user!.uid,
          email: email,
          name: name,
          role: role,
          gender: gender,
          profession: profession,
        );

        final docData = <String, dynamic>{
          'name': name,
          'email': email,
          'role': role,
          'gender': gender,
          'createdAt': FieldValue.serverTimestamp(),
        };

        if (profession != null && profession.isNotEmpty) {
          docData['profession'] = profession;
        }

        docData['vibrationEnabled'] = true;

        await _firestore.collection('users').doc(user.id).set(docData);

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

  
  Future<void> updateUserProfile({
    String? name,
    String? gender,
    String? age,
    String? dob,
    String? phone,
    String? address,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (gender != null) updates['gender'] = gender;
      if (age != null) updates['age'] = age;
      if (dob != null) updates['dob'] = dob;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }
    }
  }

  
  Future<UserEntity?> signInWithGoogle([String? role]) async {
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

        String finalRole = role ?? '';
        String name = userCredential.user!.displayName ?? '';
        String email = userCredential.user!.email ?? '';

        if (!doc.exists) {
          // New User - Create document with optional role
          await _firestore.collection('users').doc(userId).set({
            'name': name,
            'email': email,
            'role': role ?? '', // Role might be picked later
            'createdAt': FieldValue.serverTimestamp(),
          });
          finalRole = role ?? '';
        } else {
          // Existing User
          final data = doc.data() as Map<String, dynamic>;
          finalRole = data['role'] ?? '';
          name = data['name'] ?? name;
          email = data['email'] ?? email;
        }

        final user = UserEntity(
          id: userId,
          email: email,
          name: name,
          role: finalRole,
          gender: doc.exists
              ? (doc.data() as Map<String, dynamic>)['gender'] ?? ''
              : '',
          age: doc.exists
              ? (doc.data() as Map<String, dynamic>)['age']?.toString()
              : null,
          dob: doc.exists ? (doc.data() as Map<String, dynamic>)['dob'] : null,
          phone: doc.exists
              ? (doc.data() as Map<String, dynamic>)['phone']
              : null,
          address: doc.exists
              ? (doc.data() as Map<String, dynamic>)['address']
              : null,
          alarmTone: doc.exists
              ? (doc.data() as Map<String, dynamic>)['alarmTone']
              : null,
          vibrationEnabled: doc.exists
              ? (doc.data() as Map<String, dynamic>)['vibrationEnabled'] ?? true
              : true,
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

  
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final role = data['role'] ?? '';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', role);

        return UserEntity(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          name: data['name'] ?? '',
          role: role,
          gender: data['gender'] ?? '',
          age: data['age']?.toString(),
          dob: data['dob'],
          phone: data['phone'],
          address: data['address'],
          alarmTone: data['alarmTone'],
          vibrationEnabled: data['vibrationEnabled'] ?? true,
        );
      }
    }
    return null;
  }

  
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Reset email failed: $e');
      return false;
    }
  }

  // New method for Change Password where we HAVE the current password
  
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

  
  Future<void> updateUserRole(String role) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({'role': role});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userRole', role);
    }
  }
}
