import '../core/dropify_entry.dart';

/// The default search matcher for static dropdowns.
///
/// Returns true when [query] is empty, or when the lowercase query is
/// contained within the entry's effective search text. The effective text
/// resolves as `entry.searchableText ?? entry.label ?? entry.value.toString()`.
bool defaultMatcher<T>(DropifyEntry<T> entry, String query) {
  if (query.isEmpty) {
    return true;
  }
  final hay = (entry.searchableText ?? entry.label ?? entry.value.toString())
      .toLowerCase();
  return hay.contains(query.toLowerCase().trim());
}
