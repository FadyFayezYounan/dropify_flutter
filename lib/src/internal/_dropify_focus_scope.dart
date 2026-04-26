import 'package:flutter/widgets.dart';

class DropifyFocusScope extends StatelessWidget {
  const DropifyFocusScope({
    super.key,
    required this.focusNode,
    required this.child,
  });

  final FocusNode focusNode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: FocusScopeNode(debugLabel: 'Dropify panel scope'),
      child: Focus(focusNode: focusNode, child: child),
    );
  }
}
