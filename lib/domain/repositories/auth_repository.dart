import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(
    String email,
    String password, {
    String? selectedRole,
  });
  Future<UserEntity?> signUp(
    String name,
    String email,
    String password,
    String role,
    String gender, [
    String? profession,
  ]);
  Future<void> updateUserProfile({String? name, String? gender});
  Future<UserEntity?> signInWithGoogle([String? role]);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<bool> sendPasswordResetOtp(String email);
  Future<bool> verifyOtp(String email, String otp);
  Future<bool> updatePassword(String email, String newPassword);
  Future<bool> changePassword(String currentPassword, String newPassword);
  Future<void> updateUserRole(String role);
}
