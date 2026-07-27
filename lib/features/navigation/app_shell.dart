import 'package:flutter/material.dart';
import 'package:tomatoguard/features/detect/detect_page.dart';
import 'package:tomatoguard/features/history/data/scan_history_repository.dart';
import 'package:tomatoguard/features/history/manage_page.dart';
import 'package:tomatoguard/features/history/scan_history_store.dart';
import 'package:tomatoguard/features/settings/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 1;
  late final ScanHistoryStore _historyStore;

  @override
  void initState() {
    super.initState();
    _historyStore = ScanHistoryStore(ScanHistoryRepository())..initialize();
  }

  @override
  void dispose() {
    _historyStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ManagePage(store: _historyStore),
      DetectPage(historyStore: _historyStore),
      const SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Manage',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner_rounded),
            label: 'Detect',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
