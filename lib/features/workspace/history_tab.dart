import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/activity.dart';
import '../../models/review.dart';
import '../activity/activity_providers.dart';

/// Project history: a timeline of everything that happened, plus reviews.
class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(projectHistoryProvider(projectId));
    final reviews =
        ref.watch(projectReviewsProvider(projectId)).value ?? <Review>[];

    return history.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(projectHistoryProvider),
          child: const Text('Could not load history. Tap to retry.'),
        ),
      ),
      data: (events) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Text('Timeline',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          if (events.isEmpty)
            const Text('Nothing has happened yet.',
                style: TextStyle(color: AppColors.mute))
          else
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.only(left: 16),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.line, width: 2)),
              ),
              child: Column(
                children: [for (final e in events) _TimelineItem(event: e)],
              ),
            ),
          if (reviews.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Reviews',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            for (final r in reviews) _ReviewCard(review: r),
          ],
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.event});

  final ActivityEvent event;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.message,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(DateFormat('d MMM yyyy, h:mm a').format(event.createdAt),
                    style: const TextStyle(color: AppColors.mute, fontSize: 12)),
              ],
            ),
          ),
        ),
        Positioned(
          left: -22,
          top: 4,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
                color: AppColors.teal, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final r = review;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: Text('${r.fromName} → ${r.toLabel}',
                    style: const TextStyle(fontWeight: FontWeight.w700))),
            StatusChip(r.fromRole,
                tone: r.fromRole == 'Client' ? ChipTone.warn : ChipTone.good),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            for (var i = 1; i <= 5; i++)
              Icon(i <= r.rating ? Icons.star : Icons.star_border,
                  size: 18, color: const Color(0xFFE0A526)),
          ]),
          if (r.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(r.comment),
          ],
        ],
      ),
    );
  }
}
