import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tomatoguard/features/detect/data/disease_classifier.dart';
import 'package:tomatoguard/features/detect/result_page.dart';
import 'package:tomatoguard/features/history/data/scan_record.dart';
import 'package:tomatoguard/features/history/scan_history_store.dart';
import 'package:tomatoguard/shared/widgets/page_heading.dart';

enum _HistoryFilter { all, healthy, diseased, uncertain }

class ManagePage extends StatefulWidget {
  const ManagePage({required this.store, super.key});

  final ScanHistoryStore store;

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  _HistoryFilter _filter = _HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: widget.store,
        builder: (context, child) {
          final records = _filteredRecords(widget.store.records);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 12, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: PageHeading(
                        title: 'Scan history',
                        subtitle: widget.store.records.isEmpty
                            ? 'Review and manage your previous results.'
                            : '${widget.store.records.length} saved '
                                  '${widget.store.records.length == 1 ? 'scan' : 'scans'}',
                      ),
                    ),
                    if (widget.store.records.isNotEmpty)
                      IconButton(
                        tooltip: 'Clear history',
                        onPressed: _confirmClear,
                        icon: const Icon(Icons.delete_sweep_outlined),
                      ),
                  ],
                ),
              ),
              if (widget.store.records.isNotEmpty) ...[
                const SizedBox(height: 20),
                SizedBox(
                  height: 42,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _filter == _HistoryFilter.all,
                        onSelected: () =>
                            setState(() => _filter = _HistoryFilter.all),
                      ),
                      _FilterChip(
                        label: 'Healthy',
                        selected: _filter == _HistoryFilter.healthy,
                        onSelected: () =>
                            setState(() => _filter = _HistoryFilter.healthy),
                      ),
                      _FilterChip(
                        label: 'Diseased',
                        selected: _filter == _HistoryFilter.diseased,
                        onSelected: () =>
                            setState(() => _filter = _HistoryFilter.diseased),
                      ),
                      _FilterChip(
                        label: 'Uncertain',
                        selected: _filter == _HistoryFilter.uncertain,
                        onSelected: () =>
                            setState(() => _filter = _HistoryFilter.uncertain),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Expanded(child: _body(records)),
            ],
          );
        },
      ),
    );
  }

  Widget _body(List<ScanRecord> records) {
    if (widget.store.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.store.error != null && widget.store.records.isEmpty) {
      return _HistoryMessage(
        icon: Icons.cloud_off_rounded,
        title: 'History unavailable',
        message: widget.store.error!,
        actionLabel: 'Try again',
        onAction: widget.store.initialize,
      );
    }
    if (widget.store.records.isEmpty) {
      return const _HistoryMessage(
        icon: Icons.history_rounded,
        title: 'No scans yet',
        message:
            'Your saved tomato leaf scans will appear here after your first detection.',
      );
    }
    if (records.isEmpty) {
      return const _HistoryMessage(
        icon: Icons.filter_alt_off_outlined,
        title: 'No matching scans',
        message: 'Try a different history filter.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      itemCount: records.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = records[index];
        return _HistoryCard(
          record: record,
          onTap: () => _openRecord(record),
          onDelete: () => _confirmDelete(record),
        );
      },
    );
  }

  List<ScanRecord> _filteredRecords(List<ScanRecord> records) {
    return switch (_filter) {
      _HistoryFilter.all => records,
      _HistoryFilter.healthy =>
        records
            .where((record) => record.status == DetectionStatus.healthy)
            .toList(),
      _HistoryFilter.diseased =>
        records
            .where((record) => record.status == DetectionStatus.diseased)
            .toList(),
      _HistoryFilter.uncertain =>
        records
            .where(
              (record) =>
                  record.status == DetectionStatus.uncertain ||
                  record.status == DetectionStatus.noLeaf,
            )
            .toList(),
    };
  }

  Future<void> _openRecord(ScanRecord record) async {
    if (!await File(record.imagePath).exists() || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The saved scan image is missing.')),
        );
      }
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ResultPage(
          image: XFile(record.imagePath),
          result: record.toClassificationResult(),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ScanRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this scan?'),
        content: const Text(
          'The result and its saved image will be removed permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.store.delete(record);
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear scan history?'),
        content: const Text(
          'All saved results and scan images will be removed permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.store.clear();
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.record,
    required this.onTap,
    required this.onDelete,
  });

  final ScanRecord record;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = switch (record.status) {
      DetectionStatus.healthy => colors.primary,
      DetectionStatus.diseased => colors.error,
      DetectionStatus.uncertain => colors.tertiary,
      DetectionStatus.noLeaf => colors.onSurfaceVariant,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(record.imagePath),
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 84,
                    height: 84,
                    color: colors.surfaceContainerHighest,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(record.confidence * 100).toStringAsFixed(1)}% confidence',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatDate(record.scannedAt),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete scan',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final sameDay =
        now.year == date.year && now.month == date.month && now.day == date.day;
    final yesterday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));
    final wasYesterday =
        yesterday.year == date.year &&
        yesterday.month == date.month &&
        yesterday.day == date.day;
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final time = '$hour:$minute ${date.hour >= 12 ? 'PM' : 'AM'}';
    if (sameDay) return 'Today, $time';
    if (wasYesterday) return 'Yesterday, $time';
    return '${date.day}/${date.month}/${date.year}, $time';
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 46, color: colors.onSecondaryContainer),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.5, color: colors.onSurfaceVariant),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 18),
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
