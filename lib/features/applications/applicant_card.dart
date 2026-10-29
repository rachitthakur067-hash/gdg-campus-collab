import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/application.dart';
import 'application_providers.dart';

ChipTone applicationTone(ApplicationStatus s) => switch (s) {
      ApplicationStatus.pending => ChipTone.neutral,
      ApplicationStatus.shortlisted => ChipTone.warn,
      ApplicationStatus.accepted => ChipTone.good,
      ApplicationStatus.declined => ChipTone.bad,
    };

/// Used by the client to review a proposal and change its status.
class ApplicantCard extends ConsumerWidget {
  const ApplicantCard({super.key, required this.application, this.showProject = true});

  final Application application;
  final bool showProject;

  Future<void> _set(
      BuildContext context, WidgetRef ref, ApplicationStatus status) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(applicationActionsProvider).setStatus(application, status);
    messenger.showSnackBar(SnackBar(
      content: Text(status == ApplicationStatus.accepted
          ? '${application.displayName} accepted. Project is now in progress.'
          : '${application.displayName} marked ${status.label.toLowerCase()}.'),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = application;
    final canShortlist = a.status == ApplicationStatus.pending;
    final canAccept = a.status == ApplicationStatus.pending ||
        a.status == ApplicationStatus.shortlisted;
    final canDecline = a.status != ApplicationStatus.declined &&
        a.status != ApplicationStatus.accepted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(a.displayName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
              ),
              StatusChip(a.status.label, tone: applicationTone(a.status)),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            [
              if (showProject) a.projectTitle,
              if (a.teamName.isNotEmpty) 'Lead: ${a.applicantName}',
              DateFormat('d MMM').format(a.createdAt),
            ].join(' · '),
            style: const TextStyle(color: AppColors.mute, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(a.proposal),
          if (canAccept || canDecline) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (canShortlist)
                  OutlinedButton(
                    onPressed: () =>
                        _set(context, ref, ApplicationStatus.shortlisted),
                    child: const Text('Shortlist'),
                  ),
                if (canAccept)
                  FilledButton(
                    style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 40)),
                    onPressed: () =>
                        _set(context, ref, ApplicationStatus.accepted),
                    child: const Text('Accept'),
                  ),
                if (canDecline)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red),
                    onPressed: () =>
                        _set(context, ref, ApplicationStatus.declined),
                    child: const Text('Decline'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
