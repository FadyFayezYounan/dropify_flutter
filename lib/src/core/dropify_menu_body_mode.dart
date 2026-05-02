/// Controls how non-empty Dropify menu row bodies are rendered.
///
/// Static and async dropdowns use [automatic] by default. This API does not
/// apply to paginated dropdowns because their row body is caller-owned paging
/// state.
enum DropifyMenuBodyMode {
  /// Chooses the row body renderer from Dropify's default rules.
  ///
  /// Static dropdowns use an eager column for filtered counts up to 50 rows and
  /// a lazy indexed list above that threshold. Async dropdowns use lazy indexed
  /// lists for loaded rows.
  automatic,

  /// Builds every currently visible row eagerly in a column.
  eagerColumn,

  /// Builds currently visible rows with lazy indexed list rendering.
  lazyIndexed,
}
