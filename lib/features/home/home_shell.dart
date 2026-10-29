import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../auth/auth_provider.dart';
import '../marketplace/marketplace_screen.dart';
import '../profile/profile_screen.dart';
import '../shared/placeholder_screen.dart';

class _TabDef {
  const _TabDef(this.label, this.icon, this.page);
  final String label;
  final IconData icon;
  final Widget page;
}

/// Each role gets its own bottom tabs. Replace the placeholders as you
/// build each phase.
List<_TabDef> _tabsFor(UserRole role) {
  const profile = _TabDef('Profile', Icons.person_outline, ProfileScreen());
  switch (role) {
    case UserRole.student:
      return [
        const _TabDef('Browse', Icons.search, MarketplaceScreen()),
        const _TabDef(
            'Applied',
            Icons.send_outlined,
            PlaceholderScreen(
                title: 'My applications',
                hint: 'Phase 3: application statuses appear here.')),
        const _TabDef(
            'Workspace',
            Icons.checklist,
            PlaceholderScreen(
                title: 'Workspace',
                hint: 'Phase 5: tasks, milestones and discussion.')),
        profile,
      ];
    case UserRole.client:
      return [
        const _TabDef('Listings', Icons.list_alt, MarketplaceScreen()),
        const _TabDef(
            'Applicants',
            Icons.groups_outlined,
            PlaceholderScreen(
                title: 'Applicants',
                hint: 'Phase 3: shortlist, accept or decline teams.')),
        const _TabDef(
            'Feed',
            Icons.notifications_none,
            PlaceholderScreen(
                title: 'Activity', hint: 'Phase 6: notification feed.')),
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
                hint: 'Phase 5: review milestones with a checklist.')),
        const _TabDef(
            'Feed',
            Icons.notifications_none,
            PlaceholderScreen(
                title: 'Activity', hint: 'Phase 6: notification feed.')),
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
            NavigationDestination(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }
}
