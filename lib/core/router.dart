import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/home_shell.dart';
import '../features/marketplace/apply_screen.dart';
import '../features/marketplace/create_project_screen.dart';
import '../features/marketplace/project_detail_screen.dart';
import '../features/teams/create_team_screen.dart';
import '../features/teams/team_profile_screen.dart';
import '../features/teams/teams_screen.dart';
import '../features/workspace/review_screen.dart';
import '../features/workspace/workspace_screen.dart';
import '../models/app_user.dart';

/// Redirects by login state: logged out -> /login, logged in -> /home.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ValueNotifier<AppUser?>(ref.read(authProvider));
  ref.listen<AppUser?>(authProvider, (previous, next) => auth.value = next);
  ref.onDispose(auth.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: auth,
    redirect: (context, state) {
      final user = auth.value;
      final onAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (user == null) return onAuthPage ? null : '/login';
      if (onAuthPage) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeShell()),
      GoRoute(
        path: '/create-project',
        builder: (context, state) => const CreateProjectScreen(),
      ),
      GoRoute(
        path: '/project/:id',
        builder: (context, state) =>
            ProjectDetailScreen(projectId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'apply',
            builder: (context, state) =>
                ApplyScreen(projectId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(path: '/teams', builder: (context, state) => const TeamsScreen()),
      GoRoute(
        path: '/create-team',
        builder: (context, state) => const CreateTeamScreen(),
      ),
      GoRoute(
        path: '/team/:id',
        builder: (context, state) =>
            TeamProfileScreen(teamId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/workspace/:id',
        builder: (context, state) =>
            WorkspaceScreen(projectId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'review',
            builder: (context, state) =>
                ReviewScreen(projectId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});
