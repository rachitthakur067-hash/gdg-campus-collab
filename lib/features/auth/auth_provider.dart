import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../models/app_user.dart';

/// To use the real backend later, change MockAuthRepository() to
/// FirebaseAuthRepository(). Nothing else changes.
final authRepoProvider =
    Provider<AuthRepository>((ref) => MockAuthRepository());

/// Holds the logged-in user. null means logged out.
class AuthNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  Future<void> signIn(String email, String password) async {
    state = await ref.read(authRepoProvider).signIn(email, password);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = await ref.read(authRepoProvider).register(
        name: name, email: email, password: password, role: role);
  }

  Future<void> signOut() async {
    await ref.read(authRepoProvider).signOut();
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);
