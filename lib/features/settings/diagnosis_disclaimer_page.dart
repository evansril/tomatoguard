import 'package:flutter/material.dart';

class DiagnosisDisclaimerPage extends StatelessWidget {
  const DiagnosisDisclaimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnosis disclaimer')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primaryContainer, colors.tertiaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.78),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    size: 36,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Use results as guidance',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'TomatoGuard provides an image-based estimate to help you '
                  'notice possible plant-health problems early.',
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _NoticeItem(
            number: '1',
            title: 'Not a confirmed diagnosis',
            body:
                'A prediction can be affected by lighting, image quality, leaf '
                'age, pests, nutrient deficiencies, and conditions the model '
                'was not trained to recognize.',
          ),
          const _NoticeItem(
            number: '2',
            title: 'Check the whole plant',
            body:
                'Inspect other leaves, stems, fruit, nearby plants, soil '
                'moisture, and recent weather before deciding what to do.',
          ),
          const _NoticeItem(
            number: '3',
            title: 'Get local advice',
            body:
                'If symptoms are severe, spreading quickly, or uncertain, '
                'contact a qualified agricultural extension officer or plant specialist.',
          ),
          const _NoticeItem(
            number: '4',
            title: 'Treat responsibly',
            body:
                'Do not apply pesticides or fungicides solely because of an '
                'app result. Use locally approved products and always follow the label.',
          ),
          const SizedBox(height: 10),
          Card(
            color: colors.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: colors.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'TomatoGuard and its developers are not responsible for '
                      'crop loss or treatment decisions made solely from an app prediction.',
                      style: TextStyle(
                        color: colors.onErrorContainer,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeItem extends StatelessWidget {
  const _NoticeItem({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(
                color: colors.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(color: colors.onSurfaceVariant, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
