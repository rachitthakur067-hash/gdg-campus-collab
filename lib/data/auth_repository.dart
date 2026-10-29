import '../models/app_user.dart';

/// Screens only know this interface. Your teammate will write
/// FirebaseAuthRepository implementing it; you change one line in
/// auth_provider.dart to switch.
abstract class AuthRepository {
  Future<AppUser> signIn(String email, String password);
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });
  Future<void> signOut();
}

class MockAuthRepository implements AuthRepository {
  final List<AppUser> _users = [
    const AppUser(
        id: 'u1',
        name: 'Riya Sharma',
        email: 'student@demo.com',
        role: UserRole.student,
        skills: ['Flutter', 'UI design']),
    const AppUser(
        id: 'u2',
        name: 'Priya Mehta',
        email: 'client@demo.com',
        role: UserRole.client),
    const AppUser(
        id: 'u3',
        name: 'Dr. Rao',
        email: 'mentor@demo.com',
        role: UserRole.mentor,
        skills: ['AI', 'Research']),
  ];

  @override
  Future<AppUser> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _users.firstWhere(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () => throw Exception(
          'No account found for that email. Try student@demo.com'),
    );
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final user = AppUser(
      id: 'u${_users.length + 1}',
      name: name.trim(),
      email: email.trim(),
      role: role,
    );
    _users.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {}
}
