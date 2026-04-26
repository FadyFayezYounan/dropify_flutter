import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

class AccessibilityThemePage extends StatelessWidget {
  const AccessibilityThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DropifyTheme(
      data: DropifyThemeData(
        entrySelectedIcon: Icons.star,
        panelMaxHeight: 260,
        entrySelectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          DropifyDropdown<String>(
            entries: [
              DropifyEntry(value: 'compact', label: 'Compact'),
              DropifyEntry(value: 'comfortable', label: 'Comfortable'),
            ],
            label: 'Density',
            hintText: 'Choose density',
            searchable: true,
            showClearButton: true,
          ),
        ],
      ),
    );
  }
}
