import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef DropifyMenuScrollBuilder =
    Widget Function(BuildContext context, ScrollController controller);

class DropifyMenuScrollShell extends StatefulWidget {
  const DropifyMenuScrollShell({super.key, required this.builder});

  final DropifyMenuScrollBuilder builder;

  @override
  State<DropifyMenuScrollShell> createState() => _DropifyMenuScrollShellState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<DropifyMenuScrollBuilder>.has('builder', builder),
    );
  }
}

class _DropifyMenuScrollShellState extends State<DropifyMenuScrollShell> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
        overscroll: false,
        physics: const ClampingScrollPhysics(),
      ),
      child: PrimaryScrollController(
        controller: _controller,
        child: Scrollbar(
          controller: _controller,
          thumbVisibility: true,
          child: widget.builder(context, _controller),
        ),
      ),
    );
  }
}
