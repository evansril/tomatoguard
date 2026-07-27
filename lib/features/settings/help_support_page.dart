import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const _phone = '0546183123';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  size: 52,
                  color: colors.onPrimary,
                ),
                const SizedBox(height: 14),
                Text(
                  'How can we help?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Contact the TomatoGuard team for app support, questions, or feedback.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onPrimary.withValues(alpha: 0.82),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ContactCard(
            name: 'Pissan Evans',
            role: 'TomatoGuard Support',
            initials: 'PE',
            email: 'kwadzopissan@gmail.com',
            onEmail: () => _email(context, 'kwadzopissan@gmail.com'),
          ),
          const SizedBox(height: 14),
          _ContactCard(
            name: 'Osei Joshua',
            role: 'TomatoGuard Support',
            initials: 'OJ',
            email: 'scativa419@gmail.com',
            onEmail: () => _email(context, 'scativa419@gmail.com'),
          ),
          const SizedBox(height: 24),
          Text(
            'PHONE SUPPORT',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.phone_rounded,
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Support line',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 4),
                        Text(_phone),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () => _call(context),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(72, 44),
                    ),
                    child: const Text('Call'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: colors.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    color: colors.onTertiaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'When reporting a problem, include your phone model, a '
                      'short description, and a screenshot if possible.',
                      style: TextStyle(
                        color: colors.onTertiaryContainer,
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

  Future<void> _email(BuildContext context, String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'TomatoGuard Support'},
    );
    final opened = await launchUrl(uri);
    if (!context.mounted) return;
    if (!opened) {
      await _copy(context, email, 'Email address copied');
    }
  }

  Future<void> _call(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: _phone);
    final opened = await launchUrl(uri);
    if (!context.mounted) return;
    if (!opened) {
      await _copy(context, _phone, 'Phone number copied');
    }
  }

  Future<void> _copy(BuildContext context, String value, String message) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.name,
    required this.role,
    required this.initials,
    required this.email,
    required this.onEmail,
  });

  final String name;
  final String role;
  final String initials;
  final String email;
  final VoidCallback onEmail;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
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
                        name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        role,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: onEmail,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email_outlined, size: 20, color: colors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        email,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: colors.outline,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
