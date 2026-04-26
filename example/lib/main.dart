import 'package:flutter/material.dart';

import 'async_demo_keys.dart';
import 'pages/async_page.dart';
import 'pages/raw_page.dart';
import 'pages/static_page.dart';
import 'raw_demo_keys.dart';
import 'static_demo_keys.dart';

void main() {
  runApp(const DropifyExampleApp());
}

/// Example gallery application for dropify_flutter.
class DropifyExampleApp extends StatelessWidget {
  /// Creates the example app.
  const DropifyExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dropify',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.indigo)),
      home: const DropifyGallery(),
    );
  }
}

/// Minimal gallery shell for Phase 1.
class DropifyGallery extends StatelessWidget {
  /// Creates the gallery shell.
  const DropifyGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dropify Gallery')),
      body: ListView(
        children: <Widget>[
          ListTile(
            key: RawDemoKeys.rawNavTile,
            title: const Text('Raw static demo'),
            subtitle: const Text('RawDropify with custom anchor and body'),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => const RawPage()),
              );
            },
          ),
          ListTile(
            key: StaticDemoKeys.staticNavTile,
            title: const Text('Static dropdowns'),
            subtitle: const Text('Default single and multi DropifyDropdown'),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => const StaticPage()),
              );
            },
          ),
          ListTile(
            key: AsyncDemoKeys.asyncNavTile,
            title: const Text('Async dropdowns'),
            subtitle: const Text('Loading, search, empty, and retry states'),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => const AsyncPage()),
              );
            },
          ),
          const ListTile(title: Text('Paginated dropdowns land in Phase 4')),
          const ListTile(title: Text('Forms land in Phase 5')),
        ],
      ),
    );
  }
}
