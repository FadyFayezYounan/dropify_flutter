import 'package:flutter/material.dart';

/// A sticky search field rendered at the top of the dropdown panel.
class DropifySearchField extends StatelessWidget {
  const DropifySearchField({
    super.key,
    required this.controller,
    this.hintText,
  });

  final TextEditingController controller;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const Key('dropify.search.field'),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText ?? 'Search...',
            isDense: true,
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: Semantics(
              key: const Key('dropify.search.clear'),
              child: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        controller.clear();
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
