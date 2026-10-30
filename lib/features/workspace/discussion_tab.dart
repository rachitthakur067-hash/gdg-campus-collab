import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/workspace.dart';
import '../auth/auth_provider.dart';
import 'workspace_providers.dart';

class DiscussionTab extends ConsumerStatefulWidget {
  const DiscussionTab({super.key, required this.projectId, required this.role});

  final String projectId;
  final WorkspaceRole role;

  @override
  ConsumerState<DiscussionTab> createState() => _DiscussionTabState();
}

class _DiscussionTabState extends ConsumerState<DiscussionTab> {
  final _text = TextEditingController();
  bool _announce = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final user = ref.read(authProvider);
    final text = _text.text.trim();
    if (user == null || text.isEmpty) return;
    final isClient = widget.role == WorkspaceRole.client;
    await ref.read(workspaceActionsProvider).addPost(ProjectPost(
          id: 'c${DateTime.now().millisecondsSinceEpoch}',
          projectId: widget.projectId,
          authorId: user.id,
          authorName: user.name,
          authorRole: isClient ? 'Client' : 'Team',
          text: text,
          createdAt: DateTime.now(),
          isAnnouncement: isClient && _announce,
        ));
    _text.clear();
    if (mounted) setState(() => _announce = false);
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsProvider(widget.projectId));
    final canPost = widget.role != WorkspaceRole.viewer;
    final isClient = widget.role == WorkspaceRole.client;

    return Column(
      children: [
        Expanded(
          child: posts.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: TextButton(
                onPressed: () => ref.invalidate(postsProvider),
                child: const Text('Could not load messages. Tap to retry.'),
              ),
            ),
            data: (list) => list.isEmpty
                ? const Center(
                    child: Text('No messages yet. Say hello to the team.',
                        style: TextStyle(color: AppColors.mute)))
                : ListView(
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    children: [
                      for (final p in list.reversed) _PostBubble(post: p),
                    ],
                  ),
          ),
        ),
        if (canPost)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isClient)
                  Row(
                    children: [
                      Switch(
                        value: _announce,
                        onChanged: (v) => setState(() => _announce = v),
                      ),
                      const Text('Post as announcement'),
                    ],
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _text,
                        minLines: 1,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(hintText: 'Write a message'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: 'Send',
                      onPressed: _send,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PostBubble extends StatelessWidget {
  const _PostBubble({required this.post});

  final ProjectPost post;

  @override
  Widget build(BuildContext context) {
    final p = post;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.isAnnouncement ? AppColors.amberBg : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(p.authorName,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            StatusChip(p.authorRole,
                tone: p.authorRole == 'Client' ? ChipTone.warn : ChipTone.good),
            if (p.isAnnouncement) ...[
              const SizedBox(width: 6),
              const StatusChip('Announcement', tone: ChipTone.warn),
            ],
          ]),
          const SizedBox(height: 4),
          Text(p.text),
          const SizedBox(height: 4),
          Text(DateFormat('d MMM, h:mm a').format(p.createdAt),
              style: const TextStyle(color: AppColors.mute, fontSize: 11)),
        ],
      ),
    );
  }
}
