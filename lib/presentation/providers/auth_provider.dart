import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  UserEntity? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Future<void> toggleOnlineStatus() async {
    _isOnline = !_isOnline;
    notifyListeners();

    if (_user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.id)
            .update({'isOnline': _isOnline});

        // Refresh local user state
        _user = UserEntity(
          id: _user!.id,
          email: _user!.email,
          name: _user!.name,
          role: _user!.role,
          gender: _user!.gender,
          isOnline: _isOnline,
          latitude: _user!.latitude,
          longitude: _user!.longitude,
          points: _user!.points,
          completedTasks: _user!.completedTasks,
          badge: _user!.badge,
        );
      } catch (e) {
        debugPrint('Error updating online status: $e');
      }
    }
  }

  Future<void> updateLocation() async {
    if (!_isOnline || _user == null) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.id)
          .update({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'lastLocationUpdate': FieldValue.serverTimestamp(),
          });

      _user = UserEntity(
        id: _user!.id,
        email: _user!.email,
        name: _user!.name,
        role: _user!.role,
        gender: _user!.gender,
        isOnline: _isOnline,
        latitude: position.latitude,
        longitude: position.longitude,
        points: _user!.points,
        completedTasks: _user!.completedTasks,
        badge: _user!.badge,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  AuthProvider(this._authRepository);

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _user = user;
      }
    } catch (e) {
      debugPrint('Error loading current user: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // --- Visibility States ---
  bool _isLoginPasswordVisible = false;
  bool get isLoginPasswordVisible => _isLoginPasswordVisible;

  bool _isSignUpPasswordVisible = false;
  bool get isSignUpPasswordVisible => _isSignUpPasswordVisible;

  bool _isSignUpConfirmPasswordVisible = false;
  bool get isSignUpConfirmPasswordVisible => _isSignUpConfirmPasswordVisible;

  bool _isResetPasswordVisible = false;
  bool get isResetPasswordVisible => _isResetPasswordVisible;

  bool _isResetConfirmPasswordVisible = false;
  bool get isResetConfirmPasswordVisible => _isResetConfirmPasswordVisible;

  void toggleLoginPasswordVisibility() {
    _isLoginPasswordVisible = !_isLoginPasswordVisible;
    notifyListeners();
  }

  void toggleSignUpPasswordVisibility() {
    _isSignUpPasswordVisible = !_isSignUpPasswordVisible;
    notifyListeners();
  }

  void toggleSignUpConfirmPasswordVisibility() {
    _isSignUpConfirmPasswordVisible = !_isSignUpConfirmPasswordVisible;
    notifyListeners();
  }

  void toggleResetPasswordVisibility() {
    _isResetPasswordVisible = !_isResetPasswordVisible;
    notifyListeners();
  }

  void toggleResetConfirmPasswordVisibility() {
    _isResetConfirmPasswordVisible = !_isResetConfirmPasswordVisible;
    notifyListeners();
  }

  // --- Login Controllers ---
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  // --- Sign Up Controllers ---
  final signUpNameController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final signUpConfirmPasswordController = TextEditingController();
  String _signUpGender = 'Male';
  String get signUpGender => _signUpGender;
  final signUpFormKey = GlobalKey<FormState>();

  void setSignUpGender(String gender) {
    _signUpGender = gender;
    notifyListeners();
  }

  // --- Forgot Password Controllers ---
  final forgotEmailController = TextEditingController();
  final forgotFormKey = GlobalKey<FormState>();

  // --- OTP Verification Controllers ---
  final otpControllers = List.generate(6, (index) => TextEditingController());
  final otpFocusNodes = List.generate(6, (index) => FocusNode());

  // --- Reset Password Controllers ---
  final resetCurrentPasswordController = TextEditingController();
  final resetPasswordController = TextEditingController();
  final resetConfirmPasswordController = TextEditingController();
  final resetFormKey = GlobalKey<FormState>();

  bool _isResetCurrentPasswordVisible = false;
  bool get isResetCurrentPasswordVisible => _isResetCurrentPasswordVisible;

  void toggleResetCurrentPasswordVisibility() {
    _isResetCurrentPasswordVisible = !_isResetCurrentPasswordVisible;
    notifyListeners();
  }

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signUpNameController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    signUpConfirmPasswordController.dispose();
    forgotEmailController.dispose();
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var n in otpFocusNodes) {
      n.dispose();
    }
    resetPasswordController.dispose();
    resetConfirmPasswordController.dispose();
    super.dispose();
  }

  void clearControllers() {
    loginEmailController.clear();
    loginPasswordController.clear();
    signUpNameController.clear();
    signUpEmailController.clear();
    signUpPasswordController.clear();
    signUpConfirmPasswordController.clear();
    forgotEmailController.clear();
    for (var c in otpControllers) {
      c.clear();
    }
    resetPasswordController.clear();
    resetConfirmPasswordController.clear();
  }

  Future<bool> login(String? selectedRole) async {
    if (!loginFormKey.currentState!.validate()) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.login(
        loginEmailController.text.trim(),
        loginPasswordController.text.trim(),
        selectedRole: selectedRole,
      );
      if (user != null) {
        _user = user;
        _isLoading = false;
        clearControllers();
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String role) async {
    if (!signUpFormKey.currentState!.validate()) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.signUp(
        signUpNameController.text.trim(),
        signUpEmailController.text.trim(),
        signUpPasswordController.text.trim(),
        role,
        _signUpGender,
      );
      if (user != null) {
        _user = user;
        _isLoading = false;
        clearControllers();
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Sign up failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendOtp() async {
    if (!forgotFormKey.currentState!.validate()) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authRepository.sendPasswordResetOtp(
        forgotEmailController.text.trim(),
      );
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String email) async {
    String otp = otpControllers.map((c) => c.text).join();
    if (otp.length != 6) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isValid = await _authRepository.verifyOtp(email, otp);
      _isLoading = false;
      notifyListeners();
      return isValid;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    if (!resetFormKey.currentState!.validate()) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authRepository.updatePassword(
        email,
        resetPasswordController.text.trim(),
      );
      _isLoading = false;
      if (success) {
        clearControllers();
      }
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authRepository.changePassword(
        currentPassword,
        newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authRepository.logout();
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signInWithGoogle([String? role]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.signInWithGoogle(role);
      if (user != null) {
        _user = user;
        _isLoading = false;
        clearControllers();
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Google sign in failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserRole(String role) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.updateUserRole(role);
      if (_user != null) {
        _user = UserEntity(
          id: _user!.id,
          name: _user!.name,
          email: _user!.email,
          role: role,
          gender: _user!.gender,
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserProfile({String? name, String? gender}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.updateUserProfile(name: name, gender: gender);
      if (_user != null) {
        _user = UserEntity(
          id: _user!.id,
          name: name ?? _user!.name,
          email: _user!.email,
          role: _user!.role,
          gender: gender ?? _user!.gender,
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update profile';
      notifyListeners();
      return false;
    }
  }
}
