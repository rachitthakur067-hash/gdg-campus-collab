import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../models/activity.dart';
import 'activity_providers.dart';

/// Notification feed: important project updates for the logged-in user.
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);
    final read = ref.watch(readIdsProvider).value ?? <String>{};
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => ref.read(activityActionsProvider).markRead(
                  (feed.value ?? <ActivityEvent>[]).map((e) => e.id).toList()),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(feedProvider),
            child: const Text('Could not load activity. Tap to retry.'),
          ),
        ),
        data: (list) => list.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('You are all caught up. Updates will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mute)),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.refresh(feedProvider.future),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final e = list[i];
                    final isRead = read.contains(e.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          ref.read(activityActionsProvider).markRead([e.id]);
                          context.push('/project/${e.projectId}');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6, right: 10),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isRead
                                      ? AppColors.line
                                      : AppColors.teal,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.message,
                                        style: TextStyle(
                                            fontWeight: isRead
                                                ? FontWeight.w500
                                                : FontWeight.w800)),
                                    const SizedBox(height: 2),
                                    Text(
                                        '${e.projectTitle} · ${DateFormat('d MMM, h:mm a').format(e.createdAt)}',
                                        style: const TextStyle(
                                            color: AppColors.mute,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
