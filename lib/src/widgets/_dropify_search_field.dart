import 'package:flutter/material.dart';

import '../core/dropify_controller.dart';
import '../theme/dropify_theme_data.dart';
import 'dropify_keys.dart';

class DropifySearchField<T> extends StatefulWidget {
  const DropifySearchField({
    super.key,
    required this.controller,
    required this.theme,
    this.hintText,
  });

  final DropifyController<T> controller;
  final DropifyThemeData theme;
  final String? hintText;

  @override
  State<DropifySearchField<T>> createState() => _DropifySearchFieldState<T>();
}

class _DropifySearchFieldState<T> extends State<DropifySearchField<T>> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.query);
    widget.controller.addListener(_syncFromController);
  }

  @override
  void didUpdateWidget(DropifySearchField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncFromController);
      widget.controller.addListener(_syncFromController);
      _syncFromController();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromController);
    _textController.dispose();
    super.dispose();
  }

  void _syncFromController() {
    if (_textController.text == widget.controller.query) {
      return;
    }
    _textController.value = TextEditingValue(
      text: widget.controller.query,
      selection: TextSelection.collapsed(
        offset: widget.controller.query.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: DropifyKeys.searchField,
      controller: _textController,
      autofocus: true,
      decoration: widget.theme.searchDecoration.copyWith(
        hintText: widget.hintText ?? widget.theme.searchHintText,
      ),
      onChanged: widget.controller.setQuery,
    );
  }
}
