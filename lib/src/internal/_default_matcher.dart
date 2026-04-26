import '../core/dropify_entry.dart';

bool defaultDropifyMatcher<T>(DropifyEntry<T> entry, String query) {
  final normalizedQuery = query.toLowerCase().trim();
  if (normalizedQuery.isEmpty) {
    return true;
  }
  return entry.effectiveSearchText.toLowerCase().contains(normalizedQuery);
}
