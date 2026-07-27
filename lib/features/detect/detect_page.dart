import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tomatoguard/features/detect/data/disease_classifier.dart';
import 'package:tomatoguard/features/detect/result_page.dart';
import 'package:tomatoguard/features/history/scan_history_store.dart';
import 'package:tomatoguard/shared/widgets/page_heading.dart';

class DetectPage extends StatefulWidget {
  const DetectPage({required this.historyStore, super.key});

  final ScanHistoryStore historyStore;

  @override
  State<DetectPage> createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> {
  final _picker = ImagePicker();
  final _classifier = DiseaseClassifier();

  XFile? _selectedImage;
  ClassificationResult? _result;
  bool _isAnalyzing = false;
  String? _error;

  @override
  void dispose() {
    _classifier.close();
    super.dispose();
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 2048,
      );
      if (image == null || !mounted) return;

      setState(() {
        _selectedImage = image;
        _result = null;
        _error = null;
      });
      await _analyze();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    }
  }

  Future<void> _analyze() async {
    final image = _selectedImage;
    if (image == null || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final result = await _classifier.classify(await image.readAsBytes());
      if (!mounted) return;
      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
      final saved = await widget.historyStore.add(image, result);
      if (!saved && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Result ready, but it could not be saved to history.',
            ),
          ),
        );
      }
      await _openResult();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('camera_access_denied')) {
      return 'Camera access was denied. Enable it in device settings or choose '
          'an image from the gallery.';
    }
    if (message.contains('photo_access_denied')) {
      return 'Photo access was denied. Enable it in device settings and try again.';
    }
    return 'We could not analyze this image. Please try another clear leaf photo.';
  }

  void _reset() {
    setState(() {
      _selectedImage = null;
      _result = null;
      _error = null;
    });
  }

  Future<void> _openResult() async {
    final image = _selectedImage;
    final result = _result;
    if (image == null || result == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ResultPage(image: image, result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: PageHeading(
                        title: 'Detect disease',
                        subtitle: 'Take a clear photo of a tomato leaf.',
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset('assets/final_icon.png'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _ImagePanel(image: _selectedImage, isAnalyzing: _isAnalyzing),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  _ErrorCard(message: _error!),
                ],
                if (_result != null) ...[
                  const SizedBox(height: 16),
                  _ResultCard(result: _result!, onPressed: _openResult),
                ],
                const SizedBox(height: 20),
                if (_selectedImage == null) ...[
                  FilledButton.icon(
                    onPressed: _isAnalyzing
                        ? null
                        : () => _selectImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Take a photo'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isAnalyzing
                        ? null
                        : () => _selectImage(ImageSource.gallery),
                    style: _outlinedButtonStyle(),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choose from gallery'),
                  ),
                ] else ...[
                  FilledButton.icon(
                    onPressed: _isAnalyzing ? null : _analyze,
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: Text(_isAnalyzing ? 'Analyzing…' : 'Analyze again'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isAnalyzing ? null : _reset,
                    style: _outlinedButtonStyle(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Scan another leaf'),
                  ),
                ],
                const SizedBox(height: 24),
                _TipCard(colors: colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}

class _ImagePanel extends StatelessWidget {
  const _ImagePanel({required this.image, required this.isAnalyzing});

  final XFile? image;
  final bool isAnalyzing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 310,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.outlineVariant, width: 1.5),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            Image.file(File(image!.path), fit: BoxFit.cover)
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.eco_outlined,
                    size: 44,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Add a leaf photo',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Center one leaf in good, natural light',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          if (isAnalyzing)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.52),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Inspecting leaf…',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.onPressed});

  final ClassificationResult result;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (icon, color, label) = switch (result.status) {
      DetectionStatus.healthy => (
        Icons.check_circle_rounded,
        colors.primary,
        'Healthy',
      ),
      DetectionStatus.diseased => (
        Icons.warning_amber_rounded,
        colors.error,
        'Disease detected',
      ),
      DetectionStatus.noLeaf => (
        Icons.image_not_supported_outlined,
        colors.onSurfaceVariant,
        'No leaf found',
      ),
      DetectionStatus.uncertain => (
        Icons.help_outline_rounded,
        colors.tertiary,
        'Uncertain',
      ),
    };

    return Card(
      color: colors.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      result.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(result.confidence * 100).toStringAsFixed(1)}% confidence',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'View causes and recommendations',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: colors.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colors.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline, color: colors.onTertiaryContainer),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'For the best result',
                    style: TextStyle(
                      color: colors.onTertiaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Avoid blurry photos, deep shadows, and multiple overlapping leaves.',
                    style: TextStyle(color: colors.onTertiaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
