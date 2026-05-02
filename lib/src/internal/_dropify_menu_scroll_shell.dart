import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

typedef DropifyMenuScrollBuilder =
    Widget Function(BuildContext context, ScrollController controller);

typedef DropifyMenuIndexedScrollBuilder =
    Widget Function(
      BuildContext context,
      ScrollController controller,
      ListController listController,
    );

class DropifyMenuScrollShell extends StatefulWidget {
  const DropifyMenuScrollShell({super.key, required this.builder})
    : indexedBuilder = null;

  const DropifyMenuScrollShell.indexed({
    super.key,
    required this.indexedBuilder,
  }) : builder = null;

  final DropifyMenuScrollBuilder? builder;
  final DropifyMenuIndexedScrollBuilder? indexedBuilder;

  @override
  State<DropifyMenuScrollShell> createState() => _DropifyMenuScrollShellState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<DropifyMenuScrollBuilder?>.has('builder', builder),
    );
    properties.add(
      ObjectFlagProperty<DropifyMenuIndexedScrollBuilder?>.has(
        'indexedBuilder',
        indexedBuilder,
      ),
    );
  }
}

class _DropifyMenuScrollShellState extends State<DropifyMenuScrollShell> {
  final ScrollController _controller = ScrollController();
  final ListController _listController = ListController();

  @override
  void dispose() {
    _listController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final builder = widget.builder;
    final child = builder != null
        ? builder(context, _controller)
        : widget.indexedBuilder!(context, _controller, _listController);

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
          child: child,
        ),
      ),
    );
  }
}
