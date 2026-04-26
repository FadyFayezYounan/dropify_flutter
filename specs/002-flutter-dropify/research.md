# Phase 0 Research: Dropify Flutter Universal Dropdown Package

## Decision: Use a three-layer dropdown architecture

**Rationale**: `RawDropify` centralizes anchor, overlay, search, controller attachment, selection, validation, identity, focus, and theme lookup while delegating list rendering to a `panelBuilder`. Static, async, and paginated raw widgets then adapt each data model without duplicating the core interaction model. The themed widgets stay thin and only add Material 3 defaults.

**Alternatives considered**: A single monolithic dropdown widget would make static, async, and paginated behavior harder to test independently. Fully separate widgets for each data source would duplicate selection, form, keyboard, and theme logic and violate the single consistent API principle.

## Decision: Build overlay behavior on Flutter `RawMenuAnchor`

**Rationale**: The initial plan and local Flutter reference files point to `RawMenuAnchor` as the best low-level primitive for unstyled anchored overlays. It gives dismissal, focus traversal integration, scroll-aware menu behavior, and a `MenuController` foundation without forcing Material styling.

**Alternatives considered**: `MenuAnchor` was rejected for Layer 1 because it is Material-oriented. A custom `OverlayEntry` stack was rejected because it would reimplement behavior Flutter already provides and raise accessibility and focus risk.

## Decision: Use `DropifyController<T>` plus internal form integration

**Rationale**: A controller gives consumers explicit open/close/clear/selection control while the internal `FormField<DropifyValue<T>>` keeps validation available on every raw and themed variant. This avoids a separate `DropifyFormField` branch in the public API and keeps form reset behavior tied to the same selection state.

**Alternatives considered**: A standalone `DropifyFormField` was rejected for v0.1.0 because it would fragment validation. Stateless value-only widgets were rejected because open/close, reset, staged multi-select, and external clearing need a stable coordination point.

## Decision: Use value-based identity with optional `keyOf` and `equals`

**Rationale**: Selection behavior must be consistent for single, live multi, confirmable multi, validation, clearing, and display state. Default Dart equality is sufficient for common values; `keyOf` gives stable logical identity for remote records; `equals` covers custom value comparison.

**Alternatives considered**: Index-based identity was rejected because search, filtering, pagination, and async refreshes reorder or replace rows. Requiring every value to implement custom equality was rejected because it makes simple integrations heavier than necessary.

## Decision: Use `DropifyCancelToken` for async search cancellation

**Rationale**: Async fetchers receive a simple package-owned token. Dropify cancels the previous token before each replacement fetch, ignores late results, and cancels on disposal. This is lightweight, package-neutral, and easy to bridge to network libraries such as Dio without adding a production dependency.

**Alternatives considered**: Depending on a network-specific cancel token was rejected because the package should not impose HTTP client choices. Relying only on sequence numbers was rejected because it can ignore stale results but cannot notify caller-owned work to stop.

## Decision: Cache async query results per dropdown instance by default

**Rationale**: Instance-lifetime caching reduces repeated fetches while preserving predictable ownership. The cache is cleared on dispose or reset, and `cacheItems: false` opt-out keeps memory and freshness under consumer control.

**Alternatives considered**: Global caching was rejected because freshness, tenancy, and invalidation belong to host applications. No default caching was rejected because repeated open and same-query retry flows would be unnecessarily expensive for common async dropdowns.

## Decision: Consume `infinite_scroll_pagination` 5.1.1 `PagingState` directly

**Rationale**: Local dependency source confirms 5.1.1 exposes `PagingState<PageKeyType, ItemType>`, `PagingStateBase`, `Defaulted`, `Omit`, `PagedListView`, and `PagedChildBuilderDelegate` APIs that support the planned caller-owned state design. Dropify can be a pure consumer of `state` and `fetchNextPage`, while `DropifyPagingState` adds recommended `search` and `cancelToken` fields.

**Alternatives considered**: Owning a `PagingController` inside Dropify was rejected because it would duplicate the caller's source of truth and complicate search reset, filters, and cancellation. Hand-rolled pagination rendering was rejected because the existing dependency already provides tested paging list behavior.

## Decision: Resolve theme tokens through instance, `DropifyTheme`, host extension, then Material defaults

**Rationale**: This precedence supports local customization, subtree-level package theming, app-wide registration in `ThemeData.extensions`, and sensible Material 3 defaults. It matches the constitution and keeps themed widgets predictable in host apps.

**Alternatives considered**: Only reading `ThemeData` was rejected because package-specific tokens are needed. Only reading `DropifyTheme` was rejected because many Flutter apps centralize tokens through `ThemeData.extensions`.

## Decision: Make all built-in visible copy configurable

**Rationale**: Search hints, apply/cancel buttons, empty/error/loading messages, retry labels, footer text, and validation-adjacent package text need consumer-configurable defaults for localization and app voice. English defaults keep minimal examples concise.

**Alternatives considered**: Hard-coded English strings were rejected because they block localization. Requiring a localization delegate was rejected for v0.1.0 because the package can support copy injection without imposing an app-level localization structure.

## Decision: Use widget, accessibility, async, pagination, and selected golden tests as release gates

**Rationale**: Dropdown behavior is interaction-heavy, stateful, and visual. Test-first widget coverage protects public behavior, `fake_async` covers debounce, `Completer`-driven tests cover stale async order, semantics tests cover accessibility, and goldens cover themed visual regressions.

**Alternatives considered**: Deferring goldens entirely was rejected because default themed surfaces can regress visually. Broad end-to-end-only testing was rejected because failures would be harder to localize across layered abstractions.
