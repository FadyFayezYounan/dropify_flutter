import 'package:flutter/widgets.dart';

/// Manages keyboard traversal within a dropdown panel by providing a
/// dedicated [FocusNode] that stays scoped inside the overlay.
///
/// The parent [RawDropify] gives this node to [DropdownPanelState.focusScope]
/// so that panel builders can attach it to the list surface for arrow-key
/// navigation.
class DropifyFocusScope {
  DropifyFocusScope();

  /// Shared focus node for arrow-key list traversal.
  final FocusNode node = FocusNode(debugLabel: 'dropify.focusScope');

  void dispose() {
    node.dispose();
  }
}
