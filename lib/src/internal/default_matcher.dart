import '../core/dropify_entry.dart';

/// Matches entries whose labels contain the query, case-insensitively.
///
/// Whitespace is intentionally preserved; queries are not trimmed.
bool defaultDropifyMatcher<T>(DropifyEntry<T> entry, String query) {
  return entry.label.toLowerCase().contains(query.toLowerCase());
}
