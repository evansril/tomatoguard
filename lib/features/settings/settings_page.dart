import 'package:flutter/material.dart';
import 'package:tomatoguard/features/settings/diagnosis_disclaimer_page.dart';
import 'package:tomatoguard/features/settings/help_support_page.dart';
import 'package:tomatoguard/shared/widgets/page_heading.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          const PageHeading(
            title: 'Settings',
            subtitle: 'Preferences, support, and app information.',
          ),
          const SizedBox(height: 28),
          const _Section(
            title: 'Preferences',
            children: [
              ListTile(
                leading: _SettingsIcon(icon: Icons.language_rounded),
                title: Text('Language'),
                subtitle: Text('English'),
                trailing: _ValueBadge(label: 'EN'),
              ),
              Divider(height: 1, indent: 72),
              ListTile(
                leading: _SettingsIcon(icon: Icons.brightness_6_outlined),
                title: Text('Appearance'),
                subtitle: Text('Uses your device theme'),
                trailing: Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Information',
            children: [
              ListTile(
                onTap: () => _open(context, const DiagnosisDisclaimerPage()),
                leading: const _SettingsIcon(
                  icon: Icons.health_and_safety_outlined,
                ),
                title: const Text('Diagnosis disclaimer'),
                subtitle: const Text('Understand how results should be used'),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
              const Divider(height: 1, indent: 72),
              ListTile(
                onTap: () => _open(context, const HelpSupportPage()),
                leading: const _SettingsIcon(icon: Icons.support_agent_rounded),
                title: const Text('Help & Support'),
                subtitle: const Text('Contact the TomatoGuard team'),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _Section(
            title: 'About',
            children: [
              ListTile(
                leading: _SettingsIcon(icon: Icons.info_outline_rounded),
                title: Text('TomatoGuard'),
                subtitle: Text('Version 1.0.0'),
                
              ),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              'Made to help tomato growers act early',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, Widget page) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => page));
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Card(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: colors.onPrimaryContainer, size: 22),
    );
  }
}

class _ValueBadge extends StatelessWidget {
  const _ValueBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.onSecondaryContainer,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
