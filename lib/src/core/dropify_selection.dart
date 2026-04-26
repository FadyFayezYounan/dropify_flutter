/// Specifies how many items can be selected at once in a dropdown.
enum DropifySelectionMode {
  /// Only one item can be selected. Selecting a new item replaces the
  /// previous selection and closes the panel.
  single,

  /// Multiple items can be selected. Toggling an item adds or removes it
  /// from the set without closing the panel.
  multi,
}
