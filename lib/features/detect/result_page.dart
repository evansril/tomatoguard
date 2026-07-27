import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tomatoguard/features/detect/data/disease_classifier.dart';
import 'package:tomatoguard/features/detect/domain/disease_guidance.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({required this.image, required this.result, super.key});

  final XFile image;
  final ClassificationResult result;

  @override
  Widget build(BuildContext context) {
    final guidance = DiseaseGuidanceCatalog.forClass(result.className);
    final presentation = _ResultPresentation.from(context, result.status);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan result')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
            sliver: SliverList.list(
              children: [
                _ResultHero(
                  image: image,
                  result: result,
                  presentation: presentation,
                ),
                const SizedBox(height: 18),
                _SummaryCard(summary: guidance.summary),
                const SizedBox(height: 18),
                _InformationSection(
                  icon: Icons.coronavirus_outlined,
                  title: 'Likely causes',
                  items: guidance.causes,
                ),
                const SizedBox(height: 18),
                _InformationSection(
                  icon: Icons.search_rounded,
                  title: 'Signs to check',
                  items: guidance.signs,
                ),
                const SizedBox(height: 18),
                _InformationSection(
                  icon: Icons.task_alt_rounded,
                  title: 'Recommended actions',
                  items: guidance.recommendations,
                  numbered: true,
                ),
                const SizedBox(height: 18),
                const _DisclaimerCard(),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Scan another leaf'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({
    required this.image,
    required this.result,
    required this.presentation,
  });

  final XFile image;
  final ClassificationResult result;
  final _ResultPresentation presentation;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.file(File(image.path), fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(presentation.icon, color: presentation.color),
                    const SizedBox(width: 8),
                    Text(
                      presentation.label.toUpperCase(),
                      style: TextStyle(
                        color: presentation.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  result.displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: result.confidence,
                          minHeight: 9,
                          color: presentation.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '${(result.confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Model confidence',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What this means',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: TextStyle(color: colors.onPrimaryContainer, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _InformationSection extends StatelessWidget {
  const _InformationSection({
    required this.icon,
    required this.title,
    required this.items,
    this.numbered = false,
  });

  final IconData icon;
  final String title;
  final List<String> items;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: colors.onSecondaryContainer),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (var index = 0; index < items.length; index++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      numbered ? '${index + 1}.' : '•',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      items[index],
                      style: const TextStyle(height: 1.45),
                    ),
                  ),
                ],
              ),
              if (index != items.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 20, color: colors.outline),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'TomatoGuard provides an image-based estimate, not a confirmed '
            'diagnosis. Local conditions and approved treatments vary. Ask a '
            'qualified agricultural specialist when disease is severe or spreading.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultPresentation {
  const _ResultPresentation({
    required this.icon,
    required this.color,
    required this.label,
  });

  factory _ResultPresentation.from(
    BuildContext context,
    DetectionStatus status,
  ) {
    final colors = Theme.of(context).colorScheme;
    return switch (status) {
      DetectionStatus.healthy => _ResultPresentation(
        icon: Icons.check_circle_rounded,
        color: colors.primary,
        label: 'Healthy',
      ),
      DetectionStatus.diseased => _ResultPresentation(
        icon: Icons.warning_amber_rounded,
        color: colors.error,
        label: 'Disease detected',
      ),
      DetectionStatus.noLeaf => _ResultPresentation(
        icon: Icons.image_not_supported_outlined,
        color: colors.onSurfaceVariant,
        label: 'No leaf found',
      ),
      DetectionStatus.uncertain => _ResultPresentation(
        icon: Icons.help_outline_rounded,
        color: colors.tertiary,
        label: 'Uncertain result',
      ),
    };
  }

  final IconData icon;
  final Color color;
  final String label;
}
