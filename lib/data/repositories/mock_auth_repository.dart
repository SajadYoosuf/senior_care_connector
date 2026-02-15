import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserEntity?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    if (email == 'test@example.com' && password == 'password') {
      return const UserEntity(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
        role: 'caregiver',
      );
    }
    return null;
  }

  @override
  Future<UserEntity?> signUp(
    String name,
    String email,
    String password,
    String role,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    return UserEntity(id: '2', email: email, name: name, role: role);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return null; // Simulate no user logged in initially
  }
}
