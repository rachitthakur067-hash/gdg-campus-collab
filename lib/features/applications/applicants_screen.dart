import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import 'applicant_card.dart';
import 'application_providers.dart';

/// Client tab: every proposal received, across all listings.
class ApplicantsScreen extends ConsumerWidget {
  const ApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(clientApplicationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: apps.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(clientApplicationsProvider),
            child: const Text('Could not load applicants. Tap to retry.'),
          ),
        ),
        data: (list) => list.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                      'No applications yet. Publish a project and teams will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mute)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: list.length,
                itemBuilder: (_, i) => ApplicantCard(application: list[i]),
              ),
      ),
    );
  }
}
