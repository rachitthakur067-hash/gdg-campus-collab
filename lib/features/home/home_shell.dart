import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../activity/activity_providers.dart';
import '../activity/feed_screen.dart';
import '../applications/applicants_screen.dart';
import '../applications/my_applications_screen.dart';
import '../auth/auth_provider.dart';
import '../marketplace/marketplace_screen.dart';
import '../profile/profile_screen.dart';
import '../shared/placeholder_screen.dart';
import '../workspace/workspace_list_screen.dart';

class _TabDef {
  const _TabDef(this.label, this.icon, this.page);
  final String label;
  final IconData icon;
  final Widget page;
}

/// Each role gets its own bottom tabs.
List<_TabDef> _tabsFor(UserRole role) {
  const profile = _TabDef('Profile', Icons.person_outline, ProfileScreen());
  const feed = _TabDef('Feed', Icons.notifications_none, FeedScreen());
  switch (role) {
    case UserRole.student:
      return [
        const _TabDef('Browse', Icons.search, MarketplaceScreen()),
        const _TabDef('Applied', Icons.send_outlined, MyApplicationsScreen()),
        const _TabDef('Workspace', Icons.checklist, WorkspaceListScreen()),
        feed,
        profile,
      ];
    case UserRole.client:
      return [
        const _TabDef('Listings', Icons.list_alt, MarketplaceScreen()),
        const _TabDef('Applicants', Icons.groups_outlined, ApplicantsScreen()),
        const _TabDef('Workspace', Icons.checklist, WorkspaceListScreen()),
        feed,
        profile,
      ];
    case UserRole.mentor:
    case UserRole.alumni:
      return [
        const _TabDef('Projects', Icons.folder_outlined, MarketplaceScreen()),
        const _TabDef(
            'Reviews',
            Icons.rate_review_outlined,
            PlaceholderScreen(
                title: 'Reviews',
                hint: 'Mentor reviews are planned as future work.')),
        feed,
        profile,
      ];
  }
}

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox.shrink();
    final unread = ref.watch(unreadCountProvider);
    final tabs = _tabsFor(user.role);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [for (final t in tabs) t.page],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final t in tabs)
            NavigationDestination(
              icon: t.label == 'Feed' && unread > 0
                  ? Badge.count(count: unread, child: Icon(t.icon))
                  : Icon(t.icon),
              label: t.label,
            ),
        ],
      ),
    );
  }
}
