import '../core/dropify_entry.dart';

/// Default case-insensitive contains matcher for static entries.
bool defaultDropifyMatcher<T>(DropifyEntry<T> entry, String query) {
  final normalized = query.toLowerCase().trim();
  if (normalized.isEmpty) {
    return true;
  }
  return entry.effectiveSearchText.toLowerCase().contains(normalized);
}
