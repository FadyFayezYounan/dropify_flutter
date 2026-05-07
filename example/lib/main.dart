import 'package:flutter/material.dart';

import 'pages/accessibility_theme_page.dart';
import 'pages/async_dropdown_page.dart';
import 'pages/paginated_dropdown_page.dart';
import 'pages/selection_forms_page.dart';
import 'pages/static_dropdown_page.dart';

void main() {
  runApp(const DropifyExampleApp());
}

class DropifyExampleApp extends StatelessWidget {
  const DropifyExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dropify Example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DropifyExampleHome(),
    );
  }
}

class DropifyExampleHome extends StatelessWidget {
  const DropifyExampleHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dropify'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Static'),
              Tab(text: 'Async'),
              Tab(text: 'Paging'),
              Tab(text: 'Forms'),
              Tab(text: 'Theme'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StaticDropdownPage(),
            AsyncDropdownPage(),
            PaginatedDropdownPage(),
            SelectionFormsPage(),
            AccessibilityThemePage(),
          ],
        ),
      ),
    );
  }
}
