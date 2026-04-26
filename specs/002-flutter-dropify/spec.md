# Feature Specification: Dropify Flutter Universal Dropdown Package

**Feature Branch**: `002-flutter-dropify`  
**Created**: 2026-04-26  
**Status**: Draft  
**Input**: User description: "Dropify Flutter - Universal Dropdown Package for Flutter (v0.1.0). Dropify is a pub.dev Flutter package that provides a universal dropdown API built as three layered abstractions: RawDropify unstyled core; specialized raw widgets for static, async, and paginated data; themed widgets with a Material 3 default look driven by DropifyThemeData. Actors are package consumers integrating the package and end users interacting with dropdowns. Core capabilities include static, async, and paginated dropdowns; single, multi, and confirmable multi selection; integrated validation; theme resolution; search; keyboard and accessibility support. Non-functional expectations include semver stability, widget tests, zero analysis/format issues, pub.dev health, and stable semantic keys. Out of scope for v0.1.0: bottom-sheet or modal presentation, Cupertino theme variant, section headers or dividers, and drag-to-reorder selected chips."

## Clarifications

### Session 2026-04-26

- Q: What cancellation guarantee should async dropdown fetchers provide? → A: Async fetchers receive a cancel token; Dropify cancels the prior token before each new fetch and ignores any late stale result.
- Q: Which built-in visible labels and messages must be configurable for localization? → A: All built-in visible labels and messages are configurable, with sensible English defaults.
- Q: What lifetime should the async per-query cache use by default? → A: Cache lasts for the dropdown instance lifetime and is cleared on dispose or reset.
- Q: What pagination state contract should v0.1.0 recommend for cancellation and search? → A: Recommended paginated state includes search text and a cancel token; consumers cancel on search and dispose.
- Q: How should duplicate identity keys be interpreted? → A: Duplicate identity keys represent the same logical option; consumers provide distinct keys when duplicates must be independent.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Integrate a Static Dropdown (Priority: P1)

A package consumer can add a static dropdown backed by an in-memory list, choose single-select or multi-select behavior, and let an end user search, select, clear, and validate entries without custom dropdown infrastructure.

**Why this priority**: Static dropdowns are the smallest complete slice of package value and establish the shared interaction model for all other variants.

**Independent Test**: Can be fully tested by integrating the static raw and themed variants into a sample screen, opening the dropdown, searching entries, selecting enabled entries, attempting disabled entries, clearing selection, and submitting validation.

**Acceptance Scenarios**:

1. **Given** a package consumer provides an in-memory list of entries, **When** an end user opens the dropdown, **Then** all enabled entries are selectable and disabled entries appear inactive and cannot be selected.
2. **Given** the dropdown is searchable, **When** an end user types text in the search field, **Then** the visible entries update using a case-insensitive contains match unless the package consumer supplied a custom matcher.
3. **Given** a dropdown has more than 50 entries, **When** an end user opens and scrolls the list, **Then** scrolling remains smooth and only visible rows need to be presented at a time.
4. **Given** the dropdown is inside a form with a required value, **When** an end user submits without selecting an entry, **Then** the anchor displays the validation message and the form remains invalid.

---

### User Story 2 - Handle Async Search and Retry (Priority: P2)

A package consumer can add an async dropdown that fetches results for each search query while end users see clear loading, empty, error, retry, and refreshing states.

**Why this priority**: Async search is a core differentiator for remote or large datasets and carries the highest risk for poor user experience if loading and stale responses are not handled predictably.

**Independent Test**: Can be fully tested with a controlled async data source that returns successful results, empty results, delayed responses, stale responses, and recoverable errors.

**Acceptance Scenarios**:

1. **Given** the async dropdown is configured to load when opened, **When** an end user opens it for the first time, **Then** the panel shows loading progress and then either matching data, an empty state, or an error state.
2. **Given** an end user types multiple search queries quickly, **When** older requests complete after newer requests, **Then** only the newest query result is shown.
3. **Given** results are visible and an end user changes the query, **When** refreshed results are being fetched, **Then** stale results remain visible with a refreshing state until the new outcome is ready.
4. **Given** a fetch fails, **When** the end user chooses retry, **Then** the dropdown attempts the same query again without requiring the app to restart.

---

### User Story 3 - Consume Paginated Results (Priority: P3)

A package consumer can connect a paginated dropdown to caller-owned paging state so end users can search, scroll for additional pages, recover from page errors, and recognize when no more items are available.

**Why this priority**: Pagination supports large datasets while keeping data ownership and fetching policy with the host application.

**Independent Test**: Can be fully tested with a paging state fixture that covers first page loading, new page loading, first page error, new page error, empty results, and end-of-list states.

**Acceptance Scenarios**:

1. **Given** no page has loaded, **When** the panel opens, **Then** the first-page loading state is visible until data, empty state, or first-page error appears.
2. **Given** the first page contains items, **When** the end user scrolls near the end, **Then** the caller-provided next-page action is requested and the new-page loading footer is shown.
3. **Given** loading a later page fails, **When** the end user taps retry, **Then** only the failed page request is retried and previously loaded items remain available.
4. **Given** the end user changes search text, **When** the package consumer resets the paging state for that search, **Then** the dropdown displays results for the new search and does not mix old-query items into the panel.
5. **Given** paginated requests are in flight, **When** the consumer changes search text or disposes the dropdown owner, **Then** the consumer-owned paging state cancels the obsolete request and prevents stale page data from appearing.

---

### User Story 4 - Support Selection Modes and Forms (Priority: P4)

A package consumer can choose single selection, live multi-selection, or confirmable multi-selection while preserving predictable value identity and form behavior.

**Why this priority**: Selection and validation are shared behaviors that must remain consistent across all data models.

**Independent Test**: Can be fully tested by exercising the same option set in each selection mode and verifying emitted values, panel close behavior, staged changes, cancellation, reset, and validation output.

**Acceptance Scenarios**:

1. **Given** a single-select dropdown is open, **When** an end user selects an enabled entry, **Then** the selected value is emitted and the panel closes.
2. **Given** a live multi-select dropdown is open, **When** an end user toggles entries, **Then** each toggle immediately emits the current selected set and the panel remains available for further changes.
3. **Given** a confirmable multi-select dropdown has staged changes, **When** the end user applies the selection, **Then** the staged set is committed; **When** the user cancels or presses Escape, **Then** the staged set is discarded.
4. **Given** entries are represented by equivalent values, **When** the consumer supplies value identity rules, **Then** selection matching, toggling, clearing, and validation use those rules consistently.

---

### User Story 5 - Theme and Operate Accessibly (Priority: P5)

A package consumer can rely on default visual styling that adapts to the host app while end users can operate the dropdown with touch, pointer, keyboard, and assistive technologies.

**Why this priority**: The package must feel native in real applications and remain usable beyond pointer-only interaction.

**Independent Test**: Can be fully tested by applying global and instance-level theme overrides, navigating with the keyboard, and inspecting semantic labels and live status announcements.

**Acceptance Scenarios**:

1. **Given** a host app has a visual theme, **When** a themed dropdown is used without custom styling, **Then** the anchor, panel, search field, entries, and state slots align with the host app's Material design defaults.
2. **Given** both package-wide and instance-specific style choices exist, **When** the dropdown resolves its visual tokens, **Then** instance choices take precedence over package-wide choices, followed by host app defaults.
3. **Given** the panel is open, **When** an end user uses Arrow keys, Enter, Space, Escape, or printable characters, **Then** focus, selection, dismissal, and search behave as expected without pointer input.
4. **Given** async state changes or selectable entries appear, **When** assistive technology reads the dropdown, **Then** anchors, entries, selected states, disabled states, retry actions, and loading or error states are announced meaningfully.
5. **Given** a host app provides localized copy, **When** a dropdown shows search hints, actions, empty states, error states, pagination footers, or validation-adjacent package messages, **Then** those visible labels and messages use the consumer-provided copy.

### Edge Cases

- Empty entry list shows a clear no-items state and does not allow selection.
- Duplicate or equivalent values use the consumer-provided identity rules when available; otherwise the package's default value equality is applied consistently. Duplicate identity keys represent the same logical option; consumers provide distinct keys when visually duplicate entries must be selected independently.
- Disabled entries remain visible but cannot receive selection, toggling, or keyboard activation.
- Clearing selection resets the current value and updates validation state.
- Form reset restores the initial selection for all selection modes and clears validation error text according to form behavior.
- Rapid search input in async and paginated variants never displays stale query results as current data.
- Cancelled or disposed async work does not produce visible state changes after the dropdown is no longer active.
- Retry actions remain available for first-page, new-page, and async fetch errors.
- Cached async query results are not reused after the dropdown instance is disposed or reset.
- Long labels, dense option sets, constrained panels, and narrow screens do not cause layout overflow.
- Screen readers receive meaningful state changes without repeated or misleading announcements.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The package MUST expose six consumer-facing dropdown variants: raw and themed forms for static, async, and paginated data.
- **FR-002**: Static dropdown variants MUST accept in-memory entries and support client-side search with a case-insensitive contains matcher by default and a configurable matcher when provided.
- **FR-003**: Static dropdown variants MUST support single selection, live multi-selection, disabled entries, clear selection, and smooth presentation for lists larger than 50 entries.
- **FR-004**: Async dropdown variants MUST fetch results for a search query, support a default 300 ms search debounce, and allow package consumers to adjust the debounce duration.
- **FR-005**: Async dropdown variants MUST pass a cancellation token to each fetch, cancel the prior token before each replacement fetch, and ignore any late stale result that completes after cancellation.
- **FR-006**: Async dropdown variants MUST present distinct idle, loading, data, empty, error, and refreshing states, including stale visible data during refresh.
- **FR-007**: Async dropdown variants MUST support optional per-query result caching, enabled by default, that lasts for the dropdown instance lifetime and is cleared on dispose or reset.
- **FR-008**: Paginated dropdown variants MUST consume caller-owned paging state and caller-provided next-page behavior rather than owning the application's paging policy.
- **FR-009**: Paginated dropdown variants MUST display footer states for first-page progress, new-page progress, first-page error with retry, new-page error with retry, no items found, and no more items.
- **FR-010**: Paginated dropdown variants MUST notify the package consumer when search text changes so the consumer can reset paging, cancel obsolete page requests, and fetch results for the new query.
- **FR-011**: Paginated dropdown variants MUST provide or document a recommended paging state shape that includes active search text and a cancellation token for cancel-on-search and cancel-on-dispose behavior.
- **FR-012**: Single-select mode MUST emit either one selected value or no value, and selecting an enabled item MUST close the panel.
- **FR-013**: Live multi-select mode MUST emit the complete selected value set immediately after each enabled item is toggled.
- **FR-014**: Confirmable multi-select mode MUST stage selection changes until Apply is chosen and MUST discard staged changes when Cancel or Escape is used.
- **FR-015**: All selection modes MUST support consumer-provided value identity rules for matching, toggling, clearing, validation, and displayed selected state. Duplicate identity keys MUST represent the same logical option; consumers MUST provide distinct keys when visually duplicate entries must be selected independently.
- **FR-016**: Validation MUST be available directly through the raw core dropdown behavior and MUST work inside any host form, including validator callbacks, automatic validation modes, error text display on the anchor, and form reset.
- **FR-017**: Search MUST be optionally available with configurable hint text, debounce behavior, and consumer-owned search text control.
- **FR-018**: Search fields MUST remain fixed at the top of the open panel when search is enabled.
- **FR-019**: Theming MUST provide package-wide and instance-level styling for anchor, panel, search field, entries, and state-slot presentation.
- **FR-020**: Theme resolution MUST follow this precedence: instance setting, then package theme, then host theme extension, then host material defaults.
- **FR-021**: Themed dropdown variants MUST adapt to the host application's Material 3 visual language by default.
- **FR-022**: Keyboard interaction MUST support Arrow-key item navigation, Enter and Space activation, Escape dismissal, and printable-character routing into the search field when visible.
- **FR-023**: Accessibility semantics MUST identify anchors, entries, selected state, disabled state, footer actions, and async status changes, including live status announcements where appropriate.
- **FR-024**: The package MUST provide stable semantic keys for integration and journey tests across all variants.
- **FR-025**: The public package contract MUST avoid breaking changes within a semver minor version.
- **FR-026**: The example application MUST demonstrate all six dropdown variants and include selection, search, error, retry, validation, theming, and accessibility-relevant states.
- **FR-027**: All built-in visible labels and messages MUST be consumer-configurable and MUST provide sensible English defaults.

### Functional Requirement Acceptance Coverage

- **FR-001 - FR-003** are covered by User Story 1 acceptance scenarios and static dropdown edge cases.
- **FR-004 - FR-007** are covered by User Story 2 acceptance scenarios and async stale-response, cancellation, retry, and error edge cases.
- **FR-008 - FR-011** are covered by User Story 3 acceptance scenarios and paginated loading, empty, retry, cancellation, and search-reset edge cases.
- **FR-012 - FR-016** are covered by User Story 4 acceptance scenarios and form reset, clear, disabled entry, and value identity edge cases.
- **FR-017 - FR-023** are covered by User Story 5 acceptance scenarios and keyboard, search, theming, localization, and screen-reader edge cases.
- **FR-024 - FR-027** are covered by the Constitution Alignment, example application, and package quality success criteria.

### Key Entities *(include if feature involves data)*

- **Dropify Entry**: A selectable option shown in a dropdown. Key attributes include value, identity key, display label, enabled or disabled state, searchable text, and optional visual adjuncts.
- **Dropify Value**: The selected value state for a dropdown. It represents no selection, one selected value, or a set of selected values depending on selection mode.
- **Selection Mode**: The behavior policy for committing values: single, live multi, or confirmable multi.
- **Search Query**: The current text used to filter static entries, fetch async entries, or request paginated data reset.
- **Async Result State**: The visible state of an async dropdown, including idle, loading, data, empty, error, and refreshing.
- **Paging State**: Caller-owned paginated data state containing loaded items, loading status, error status, whether more items exist, active search text, and a cancellation token for obsolete page requests.
- **Theme Data**: Styling tokens that describe the dropdown anchor, panel, search field, entries, and state-slot presentation.
- **Validation State**: Form-related validity, error text, and reset state associated with the dropdown value.

## Constitution Alignment *(mandatory)*

- **Public API Stability**: The feature defines an additive v0.1.0 public package surface. Breaking changes after release are not allowed within a semver minor version; any later breaking change requires a major version, migration guidance, and deprecation coverage.
- **Single Consistent API**: Static, async, paginated, raw, themed, selection, search, validation, and theming behavior share one value-based interaction model and a single package import entry point.
- **Test-First & Golden Tests**: Each dropdown variant, selection mode, validation behavior, async state transition, pagination footer state, theme override, keyboard path, and accessibility path requires failing tests before implementation and visual regression coverage for states that can regress visually.
- **Async Safety**: Async and paginated behavior must cover debounce, cancellation, stale-response protection, retry, empty, loading, error, refreshing, disposal, and rapid search changes.
- **Theming & Accessibility**: The package must inherit host Material styling by default, compose package and instance overrides predictably, expose readable focus and hover states, support keyboard operation, and provide screen-reader semantics for anchors, entries, states, and actions.
- **Package Quality Gates**: Formatting, static analysis, widget tests, golden tests, example app compilation, documentation alignment, semantic keys, and pub.dev health and maintenance targets are required before merge.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A package consumer can integrate any one of the six dropdown variants with a single package import and fewer than 10 lines of setup code in a minimal example.
- **SC-002**: End users can open, search, select, clear, and validate a static dropdown with no perceptible delay in standard app interaction.
- **SC-003**: In controlled tests with delayed and out-of-order async responses, 100% of completed interactions display only the newest query's results as current data.
- **SC-004**: Async and paginated dropdown errors are recoverable through a visible retry action in 100% of documented error states, without restarting the host app.
- **SC-005**: Keyboard users can complete open, search, navigate, select, apply or cancel, clear, and close flows for each relevant variant without pointer input.
- **SC-006**: Form validation and reset behavior works consistently for single, live multi, and confirmable multi selection in all dropdown variants that expose those modes.
- **SC-007**: The example application demonstrates all six variants and core states without crashes, clipped controls, or layout overflow on all supported target platforms.
- **SC-008**: The package reaches the project's required release quality gates before release, including zero release-blocking quality issues and 100% passing required tests.
- **SC-009**: Package documentation enables a developer unfamiliar with Dropify to complete a working integration of a static, async, or paginated dropdown in under 15 minutes.

## Assumptions

- The package is intended for Flutter application developers and end users of those applications.
- Public class and variant names supplied in the feature description are part of the desired consumer-facing contract for v0.1.0.
- Material 3 is the default themed visual language for v0.1.0; non-Material visual variants are outside this release.
- Async data fetching and paginated data ownership remain the host application's responsibility beyond the package-provided dropdown interaction and state presentation contract.
- Search matching for static data defaults to case-insensitive contains behavior unless a consumer supplies a custom matcher.
- Async per-query caching is scoped to one dropdown instance by default.
- Retry behavior is expected for recoverable async and pagination failures; unrecoverable application-level errors may still be surfaced by the host application.
- Platform support follows the host framework's supported platform set for the package version.

## Out of Scope

- Bottom-sheet or modal dropdown presentation.
- Cupertino-specific theme variant.
- Section headers, dividers, or grouped item presentation.
- Drag-to-reorder selected chips.
