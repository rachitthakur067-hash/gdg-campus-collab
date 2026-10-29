import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/project.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onTap});

  final Project project;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
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
                    child: Text(project.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                  StatusChip(project.status.label, tone: ChipTone.good),
                ],
              ),
              const SizedBox(height: 4),
              Text('${project.clientName} · ${project.domain}',
                  style: const TextStyle(color: AppColors.mute, fontSize: 12)),
              const SizedBox(height: 8),
              Text(project.description,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final s in project.skills) StatusChip(s)],
              ),
              const SizedBox(height: 8),
              Text('Due ${DateFormat('d MMM yyyy').format(project.deadline)}',
                  style: const TextStyle(color: AppColors.mute, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
