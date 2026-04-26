import 'package:flutter/material.dart';

import 'pages/async_dropdown_page.dart';
import 'pages/paginated_dropdown_page.dart';
import 'pages/static_dropdown_page.dart';

void main() {
  runApp(const DropifyExampleApp());
}

class DropifyExampleApp extends StatelessWidget {
  const DropifyExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dropify Flutter',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const DropifyExampleHome(),
    );
  }
}

class DropifyExampleHome extends StatelessWidget {
  const DropifyExampleHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dropify Flutter'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Static'),
              Tab(text: 'Async'),
              Tab(text: 'Paged'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StaticDropdownPage(),
            AsyncDropdownPage(),
            PaginatedDropdownPage(),
          ],
        ),
      ),
    );
  }
}
