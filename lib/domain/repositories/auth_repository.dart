import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> signUp(
    String name,
    String email,
    String password,
    String role,
  );
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}
