# Tasks: Dropify Flutter Universal Dropdown Package

**Input**: Design documents from `/Users/fady/Documents/Projects/dropify_flutter/specs/002-flutter-dropify/`
**Prerequisites**: `/Users/fady/Documents/Projects/dropify_flutter/specs/002-flutter-dropify/plan.md`, `/Users/fady/Documents/Projects/dropify_flutter/specs/002-flutter-dropify/spec.md`, `/Users/fady/Documents/Projects/dropify_flutter/specs/002-flutter-dropify/research.md`, `/Users/fady/Documents/Projects/dropify_flutter/specs/002-flutter-dropify/data-model.md`, `/Users/fady/Documents/Projects/dropify_flutter/specs/002-flutter-dropify/contracts/`

**Tests**: Mandatory for this feature. Write failing tests before implementation for every widget, behavior, visual state, async transition, pagination state, form behavior, keyboard path, semantic path, and public API contract.

**Organization**: Tasks are grouped by user story so each story can be implemented and tested independently after shared setup and foundation are complete.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it touches different files and does not depend on another incomplete task
- **[Story]**: User story label, required only for user story phases
- Every task includes an absolute file path

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish package directories, test structure, and baseline project configuration.

- [X] T001 Create the planned package source directories under `/Users/fady/Documents/Projects/dropify_flutter/lib/src/`
- [X] T002 Create the planned test directories under `/Users/fady/Documents/Projects/dropify_flutter/test/`
- [X] T003 Create the planned example page directories under `/Users/fady/Documents/Projects/dropify_flutter/example/lib/pages/`
- [X] T004 Verify package dependencies and dev dependencies match the implementation plan in `/Users/fady/Documents/Projects/dropify_flutter/pubspec.yaml`
- [ ] T005 [P] Create shared widget test harness helpers in `/Users/fady/Documents/Projects/dropify_flutter/test/helpers/dropify_test_app.dart`
- [ ] T006 [P] Create shared data, fetcher, paging, and semantics fixtures in `/Users/fady/Documents/Projects/dropify_flutter/test/helpers/dropify_fixtures.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core primitives, internal helpers, exports, and test scaffolding that block every user story.

**Critical**: No user story work can begin until this phase is complete.

- [ ] T007 [P] Add failing cancel token tests in `/Users/fady/Documents/Projects/dropify_flutter/test/core/dropify_cancel_token_test.dart`
- [ ] T008 [P] Add failing entry, value, and selection identity tests in `/Users/fady/Documents/Projects/dropify_flutter/test/core/dropify_selection_test.dart`
- [ ] T009 [P] Add failing controller state transition tests in `/Users/fady/Documents/Projects/dropify_flutter/test/core/dropify_controller_test.dart`
- [ ] T010 [P] Add failing paging state tests in `/Users/fady/Documents/Projects/dropify_flutter/test/core/dropify_paging_state_test.dart`
- [ ] T011 [P] Add failing debouncer and default matcher tests in `/Users/fady/Documents/Projects/dropify_flutter/test/internal/dropify_internal_test.dart`
- [ ] T012 [P] Add failing public export contract tests in `/Users/fady/Documents/Projects/dropify_flutter/test/public_api_test.dart`
- [X] T013 [P] Implement `DropifyCancelToken` and `DropifyCancelledException` in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/core/dropify_cancel_token.dart`
- [X] T014 Implement `DropifyEntry`, `DropifySelectionMode`, `DropifyValue`, and selection identity helpers in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/core/dropify_entry.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/core/dropify_selection.dart`, and `/Users/fady/Documents/Projects/dropify_flutter/lib/src/core/dropify_value.dart`
- [X] T015 Implement `DropifyController` open, close, clear, single value, multi value, and toggle behavior in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/core/dropify_controller.dart`
- [X] T016 Implement `DropifyPagingState` as a caller-owned paging helper with search and cancel token support in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/core/dropify_paging_state.dart`
- [X] T017 [P] Implement the private debouncer in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_debouncer.dart`
- [X] T018 [P] Implement the private default static matcher in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_default_matcher.dart`
- [X] T019 Export all foundational public APIs and paging dependency types through `/Users/fady/Documents/Projects/dropify_flutter/lib/dropify_flutter.dart`

**Checkpoint**: Foundation ready; user story implementation can begin.

---

## Phase 3: User Story 1 - Integrate a Static Dropdown (Priority: P1) MVP

**Goal**: Consumers can add raw and themed static dropdowns backed by in-memory entries, with search, disabled entries, clear, smooth large-list rendering, and validation.

**Independent Test**: Integrate static raw and themed variants into a sample screen, open the dropdown, search entries, select enabled entries, attempt disabled entries, clear selection, and submit validation.

### Tests for User Story 1 (write before implementation)

- [ ] T020 [P] [US1] Add failing RawDropify open, close, outside tap, Escape, and callback tests in `/Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_dropify_test.dart`
- [ ] T021 [P] [US1] Add failing RawDropify single-select, live multi-select, clear, and disabled-entry tests in `/Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_dropify_selection_test.dart`
- [ ] T022 [P] [US1] Add failing RawDropify validation and form reset tests in `/Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_dropify_form_test.dart`
- [ ] T023 [P] [US1] Add failing RawStaticDropify search, custom matcher, consumer-owned search text control, empty state, and large-list builder tests in `/Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_static_dropify_test.dart`
- [ ] T024 [P] [US1] Add failing static dropdown golden tests for anchor, panel, disabled entry, and validation error states in `/Users/fady/Documents/Projects/dropify_flutter/test/goldens/dropify_static_golden_test.dart`

### Implementation for User Story 1

- [X] T025 [P] [US1] Implement private anchor behavior, clear affordance, error slot, and semantic key wiring in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_anchor.dart`
- [X] T026 [P] [US1] Implement private panel layout, constrained overlay surface, and visible-row list behavior in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_panel.dart`
- [X] T027 [P] [US1] Implement private search field with fixed panel positioning and clear action in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_search_field.dart`
- [ ] T028 [P] [US1] Implement private focus scope and keyboard routing for static dropdown flows in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_focus_scope.dart`
- [X] T029 [US1] Implement `RawDropify` with FormField integration, controller attachment, selection identity, validation, search slot, and panel builder in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/core/raw_dropify.dart`
- [X] T030 [US1] Implement `RawStaticDropify` with entry filtering, consumer-owned search text control, disabled row handling, empty state, multi constructors, and large-list builder threshold in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_static_dropify.dart`
- [X] T031 [US1] Implement the minimal `DropifyThemeData.fromMaterial` defaults needed by static themed widgets in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/theme/dropify_theme_data.dart`
- [X] T032 [US1] Implement `DropifyTheme` inherited theme lookup for static themed widgets in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/theme/dropify_theme.dart`
- [X] T033 [US1] Implement `DropifyDropdown` as the Material 3 themed static wrapper with single and multi constructors in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/dropify_dropdown.dart`
- [X] T034 [US1] Export static raw and themed widget APIs through `/Users/fady/Documents/Projects/dropify_flutter/lib/dropify_flutter.dart`
- [X] T035 [US1] Add static dropdown demos covering raw, themed, search, disabled entries, clear, validation, and large lists in `/Users/fady/Documents/Projects/dropify_flutter/example/lib/pages/static_dropdown_page.dart`
- [X] T036 [US1] Wire the static dropdown demo into the example app navigation in `/Users/fady/Documents/Projects/dropify_flutter/example/lib/main.dart`

**Checkpoint**: User Story 1 is independently functional and testable as the MVP.

---

## Phase 4: User Story 2 - Handle Async Search and Retry (Priority: P2)

**Goal**: Consumers can add async dropdowns with debounced search, cancellation, stale-result protection, per-instance cache, loading, empty, error, retry, and refreshing states.

**Independent Test**: Use a controlled async data source that returns successful results, empty results, delayed responses, stale responses, and recoverable errors.

### Tests for User Story 2 (write before implementation)

- [ ] T037 [P] [US2] Add failing async load-on-open, loading, data, empty, error, and retry tests in `/Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_async_dropify_test.dart`
- [ ] T038 [P] [US2] Add failing async debounce, adjustable debounce duration, consumer-owned search text control, cancellation token, stale response, refreshing, cache reset, and dispose tests in `/Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_async_dropify_async_safety_test.dart`
- [ ] T039 [P] [US2] Add failing async semantics tests for loading, empty, error, retry, and live status updates in `/Users/fady/Documents/Projects/dropify_flutter/test/accessibility/dropify_async_semantics_test.dart`
- [ ] T040 [P] [US2] Add failing async dropdown golden tests for loading, refreshing, empty, error, and retry states in `/Users/fady/Documents/Projects/dropify_flutter/test/goldens/dropify_async_golden_test.dart`

### Implementation for User Story 2

- [X] T041 [US2] Implement `DropifyAsyncFetcher`, `DropifyAsyncState`, and async state transition model in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_async_dropify.dart`
- [X] T042 [US2] Implement `RawAsyncDropify` load-on-open, configurable debounced search, consumer-owned search text control, cancellation, stale-result protection, retry, cache, reset, and dispose behavior in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_async_dropify.dart`
- [X] T043 [US2] Integrate async loading, refreshing, empty, error, retry, and live status slots with shared panel semantics in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_async_dropify.dart`
- [X] T044 [US2] Extend `DropifyThemeData` with async state-slot builders and visible copy defaults in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/theme/dropify_theme_data.dart`
- [X] T045 [US2] Implement `DropifyAsyncDropdown` as the Material 3 themed async wrapper with single and multi constructors in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/dropify_async_dropdown.dart`
- [X] T046 [US2] Export async raw and themed widget APIs through `/Users/fady/Documents/Projects/dropify_flutter/lib/dropify_flutter.dart`
- [X] T047 [US2] Add fake async API scenarios for success, empty, delayed, stale, and error responses in `/Users/fady/Documents/Projects/dropify_flutter/example/lib/fake_api.dart`
- [X] T048 [US2] Add raw and themed async dropdown demos covering search, loading, empty, error, retry, refresh, and cache behavior in `/Users/fady/Documents/Projects/dropify_flutter/example/lib/pages/async_dropdown_page.dart`
- [X] T049 [US2] Wire the async dropdown demo into the example app navigation in `/Users/fady/Documents/Projects/dropify_flutter/example/lib/main.dart`

**Checkpoint**: User Story 2 is independently functional and remains compatible with User Story 1.

---

## Phase 5: User Story 3 - Consume Paginated Results (Priority: P3)

**Goal**: Consumers can connect caller-owned paging state to paginated dropdowns with search reset notification, next-page requests, retry footers, empty states, and no-more-items states.

**Independent Test**: Use a paging fixture that covers first-page loading, new-page loading, first-page error, new-page error, empty results, and end-of-list states.

### Tests for User Story 3 (write before implementation)

- [ ] T050 [P] [US3] Add failing paginated first-page loading, first-page error, empty, and initial fetch tests in `/Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_paginated_dropify_first_page_test.dart`
- [ ] T051 [P] [US3] Add failing paginated scroll threshold, new-page loading, new-page error retry, and no-more-items footer tests in `/Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_paginated_dropify_footer_test.dart`
- [ ] T052 [P] [US3] Add failing paginated search change, consumer-owned search text control, caller cancellation, and old-query isolation tests in `/Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_paginated_dropify_search_test.dart`
- [ ] T053 [P] [US3] Add failing paginated semantics tests for footer progress, retry, no-items, and no-more-items states in `/Users/fady/Documents/Projects/dropify_flutter/test/accessibility/dropify_paginated_semantics_test.dart`
- [ ] T054 [P] [US3] Add failing paginated dropdown golden tests for first-page, new-page, retry, no-items, and no-more-items states in `/Users/fady/Documents/Projects/dropify_flutter/test/goldens/dropify_paginated_golden_test.dart`

### Implementation for User Story 3

- [X] T055 [US3] Implement `RawPaginatedDropify` as a pure consumer of `PagingState<PageKey, T>` and `fetchNextPage` in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_paginated_dropify.dart`
- [X] T056 [US3] Implement paginated first-page progress, first-page error, empty, and initial open fetch behavior in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_paginated_dropify.dart`
- [X] T057 [US3] Implement paginated scroll threshold, new-page progress, new-page error retry, no-more-items footer, and retained existing items in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_paginated_dropify.dart`
- [X] T058 [US3] Implement debounced paginated search notification and consumer-owned search text control without mutating caller paging state in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_paginated_dropify.dart`
- [X] T059 [US3] Extend `DropifyThemeData` with paginated footer builders and visible copy defaults in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/theme/dropify_theme_data.dart`
- [X] T060 [US3] Implement `DropifyPaginatedDropdown` as the Material 3 themed paginated wrapper with single and multi constructors in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/dropify_paginated_dropdown.dart`
- [X] T061 [US3] Export paginated raw and themed widget APIs through `/Users/fady/Documents/Projects/dropify_flutter/lib/dropify_flutter.dart`
- [X] T062 [US3] Add paginated fake API and paging owner examples using `DropifyPagingState` in `/Users/fady/Documents/Projects/dropify_flutter/example/lib/fake_api.dart`
- [X] T063 [US3] Add raw and themed paginated dropdown demos covering first page, next page, search reset, retry, empty, and no-more-items states in `/Users/fady/Documents/Projects/dropify_flutter/example/lib/pages/paginated_dropdown_page.dart`
- [X] T064 [US3] Wire the paginated dropdown demo into the example app navigation in `/Users/fady/Documents/Projects/dropify_flutter/example/lib/main.dart`

**Checkpoint**: User Story 3 is independently functional and remains compatible with User Stories 1 and 2.

---

## Phase 6: User Story 4 - Support Selection Modes and Forms (Priority: P4)

**Goal**: Consumers can choose single, live multi, or confirmable multi selection with consistent value identity, validation, staged apply, cancellation, and form reset behavior across variants.

**Independent Test**: Exercise the same option set in each selection mode and verify emitted values, panel close behavior, staged changes, cancellation, reset, and validation output.

### Tests for User Story 4 (write before implementation)

- [ ] T065 [P] [US4] Add failing cross-variant single selection and close behavior tests in `/Users/fady/Documents/Projects/dropify_flutter/test/widgets/dropify_selection_modes_test.dart`
- [ ] T066 [P] [US4] Add failing cross-variant live multi selection and emitted set tests in `/Users/fady/Documents/Projects/dropify_flutter/test/widgets/dropify_multi_selection_test.dart`
- [ ] T067 [P] [US4] Add failing confirmable multi apply, cancel, Escape, outside tap, and close discard tests in `/Users/fady/Documents/Projects/dropify_flutter/test/widgets/dropify_confirmable_multi_test.dart`
- [ ] T068 [P] [US4] Add failing cross-variant identity, duplicate key, clear, validation, and form reset tests in `/Users/fady/Documents/Projects/dropify_flutter/test/widgets/dropify_form_identity_test.dart`

### Implementation for User Story 4

- [X] T069 [US4] Harden shared selection identity, duplicate key, single, multi, and clear behavior in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/core/dropify_selection.dart`
- [X] T070 [US4] Add confirmable multi staged state, Apply, Cancel, Escape, outside tap, and programmatic close discard behavior to `/Users/fady/Documents/Projects/dropify_flutter/lib/src/core/raw_dropify.dart`
- [X] T071 [US4] Add confirmable multi footer rendering and keyboard focus order to `/Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_panel.dart`
- [X] T072 [US4] Extend validation, autovalidation, error text builder, and form reset behavior for all selection modes in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/core/raw_dropify.dart`
- [X] T073 [US4] Expose single, multi, and confirmable constructors consistently in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_static_dropify.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_async_dropify.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_paginated_dropify.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/dropify_dropdown.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/dropify_async_dropdown.dart`, and `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/dropify_paginated_dropdown.dart`
- [ ] T074 [US4] Add selection mode and form demos for all variants in `/Users/fady/Documents/Projects/dropify_flutter/example/lib/pages/selection_forms_page.dart`
- [ ] T075 [US4] Wire the selection and forms demo into the example app navigation in `/Users/fady/Documents/Projects/dropify_flutter/example/lib/main.dart`

**Checkpoint**: User Story 4 is independently functional across static, async, and paginated variants.

---

## Phase 7: User Story 5 - Theme and Operate Accessibly (Priority: P5)

**Goal**: Consumers get Material 3 defaults, package-wide and instance theme overrides, keyboard operation, assistive technology semantics, configurable visible copy, stable semantic keys, and localized labels.

**Independent Test**: Apply global and instance-level theme overrides, navigate with keyboard, inspect semantic labels and live status announcements, and verify localized copy does not alter stable keys.

### Tests for User Story 5 (write before implementation)

- [ ] T076 [P] [US5] Add failing theme resolution, copyWith, lerp, host extension, package theme, and instance override tests in `/Users/fady/Documents/Projects/dropify_flutter/test/theme/dropify_theme_data_test.dart`
- [ ] T077 [P] [US5] Add failing themed widget override and Material 3 adaptation tests in `/Users/fady/Documents/Projects/dropify_flutter/test/widgets/dropify_themed_widgets_test.dart`
- [ ] T078 [P] [US5] Add failing keyboard navigation tests for arrows, Enter, Space, Escape, printable search routing, Tab, and footer buttons in `/Users/fady/Documents/Projects/dropify_flutter/test/accessibility/dropify_keyboard_test.dart`
- [ ] T079 [P] [US5] Add failing semantics and stable key tests for anchors, items, selected state, disabled state, errors, status slots, and localized copy in `/Users/fady/Documents/Projects/dropify_flutter/test/accessibility/dropify_semantic_keys_test.dart`
- [ ] T080 [P] [US5] Add failing themed visual golden tests for default, hover, focus, selected, disabled, error, dark mode, and confirmable multi Apply/Cancel/staged footer states in `/Users/fady/Documents/Projects/dropify_flutter/test/goldens/dropify_theme_golden_test.dart`

### Implementation for User Story 5

- [X] T081 [US5] Complete `DropifyThemeData` token groups, `fromMaterial`, `copyWith`, `lerp`, state-slot builders, and visible copy defaults in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/theme/dropify_theme_data.dart`
- [X] T082 [US5] Complete `DropifyTheme` resolution order across instance values, package theme, host extension, and Material defaults in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/theme/dropify_theme.dart`
- [X] T083 [US5] Apply theme tokens to all themed widgets and shared surfaces in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/dropify_dropdown.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/dropify_async_dropdown.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/dropify_paginated_dropdown.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_anchor.dart`, and `/Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_panel.dart`
- [ ] T084 [US5] Implement stable semantic keys from the semantic-keys contract in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_anchor.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_panel.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_search_field.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_async_dropify.dart`, and `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_paginated_dropify.dart`
- [ ] T085 [US5] Implement accessibility semantics and live status announcements in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_anchor.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_panel.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_async_dropify.dart`, and `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_paginated_dropify.dart`
- [ ] T086 [US5] Complete keyboard operation for all variants and selection modes in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_focus_scope.dart`
- [ ] T087 [US5] Expose configurable visible copy across all raw and themed widget constructors in `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_static_dropify.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_async_dropify.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_paginated_dropify.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/dropify_dropdown.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/dropify_async_dropdown.dart`, and `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/dropify_paginated_dropdown.dart`
- [ ] T088 [US5] Add theme, keyboard, accessibility, and localization demos in `/Users/fady/Documents/Projects/dropify_flutter/example/lib/pages/accessibility_theme_page.dart`
- [ ] T089 [US5] Wire the accessibility and theme demo into the example app navigation in `/Users/fady/Documents/Projects/dropify_flutter/example/lib/main.dart`

**Checkpoint**: User Story 5 is independently functional and verifies the public theming and accessibility contracts.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Documentation, package readiness, full verification, and release quality gates.

- [ ] T090 [P] Document public API usage, static integration, async integration, paginated integration, selection modes, theming, accessibility, semantic keys, and localization in `/Users/fady/Documents/Projects/dropify_flutter/README.md`
- [ ] T091 [P] Add dartdoc comments for all public exports and constructor parameters in `/Users/fady/Documents/Projects/dropify_flutter/lib/dropify_flutter.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/core/raw_dropify.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_static_dropify.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_async_dropify.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/raw_paginated_dropify.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/dropify_dropdown.dart`, `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/dropify_async_dropdown.dart`, and `/Users/fady/Documents/Projects/dropify_flutter/lib/src/widgets/dropify_paginated_dropdown.dart`
- [ ] T092 [P] Update the example app README with all six variant demos and verification instructions in `/Users/fady/Documents/Projects/dropify_flutter/example/README.md`
- [ ] T093 [P] Add example widget tests for static, async, paginated, selection, theme, and accessibility pages in `/Users/fady/Documents/Projects/dropify_flutter/example/test/dropify_example_test.dart`
- [ ] T094 Audit public exports against the API contract and remove unintended exports in `/Users/fady/Documents/Projects/dropify_flutter/lib/dropify_flutter.dart`
- [ ] T095 Audit long labels, narrow panels, constrained overlays, visible-row large-list behavior, and overflow behavior with focused widget tests in `/Users/fady/Documents/Projects/dropify_flutter/test/widgets/dropify_layout_test.dart`
- [X] T096 Run `dart format --set-exit-if-changed .` and fix formatting issues in `/Users/fady/Documents/Projects/dropify_flutter/`
- [X] T097 Run `dart analyze` and fix analyzer issues in `/Users/fady/Documents/Projects/dropify_flutter/`
- [X] T098 Run `flutter test` and fix package test failures in `/Users/fady/Documents/Projects/dropify_flutter/`
- [X] T099 Run `flutter test` and fix example test failures in `/Users/fady/Documents/Projects/dropify_flutter/example/`
- [X] T100 Run `flutter build web` and fix example compilation issues in `/Users/fady/Documents/Projects/dropify_flutter/example/`
- [ ] T101 Validate the documented quickstart in a clean minimal Flutter app and fix documentation or API issues in `/Users/fady/Documents/Projects/dropify_flutter/README.md`, `/Users/fady/Documents/Projects/dropify_flutter/example/README.md`, and `/Users/fady/Documents/Projects/dropify_flutter/lib/dropify_flutter.dart`
- [ ] T102 Verify the example app compiles or has documented CI/manual verification evidence for Android, iOS, web, macOS, Windows, and Linux supported targets, and fix platform-specific issues in `/Users/fady/Documents/Projects/dropify_flutter/example/`
- [ ] T103 Run `flutter pub publish --dry-run` and fix package health issues in `/Users/fady/Documents/Projects/dropify_flutter/`
- [ ] T104 Verify pub.dev scoring expectations meet constitution targets, including 130+ total points and 100% Health and Maintenance where package scoring is available, and fix release-blocking issues in `/Users/fady/Documents/Projects/dropify_flutter/`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion; blocks all user stories.
- **User Stories (Phase 3+)**: Depend on Foundational completion.
- **Polish (Phase 8)**: Depends on the desired user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Starts after Foundational; no dependency on other stories; suggested MVP.
- **User Story 2 (P2)**: Starts after Foundational; reuses shared core and theme primitives, but remains independently testable with controlled async fixtures.
- **User Story 3 (P3)**: Starts after Foundational; reuses shared core and theme primitives, but remains independently testable with paging fixtures.
- **User Story 4 (P4)**: Starts after static, async, and paginated wrappers exist enough to verify cross-variant consistency.
- **User Story 5 (P5)**: Starts after shared widget surfaces exist enough to apply theme, semantics, keyboard, and copy contracts across variants.

### Within Each User Story

- Write tests first and confirm they fail before implementation.
- Implement support types and internal helpers before public widgets.
- Implement raw widgets before themed wrappers.
- Export public APIs after implementation files exist.
- Update example app demos after package behavior is implemented.

---

## Parallel Opportunities

- Setup tasks T005 and T006 can run in parallel after directory tasks are complete.
- Foundational test tasks T007 through T012 can run in parallel.
- Foundational implementation tasks T013, T017, and T018 can run in parallel after their tests are written.
- User Story 1 test tasks T020 through T024 can run in parallel.
- User Story 1 internal helper implementation tasks T025 through T028 can run in parallel.
- User Story 2 test tasks T037 through T040 can run in parallel.
- User Story 3 test tasks T050 through T054 can run in parallel.
- User Story 4 test tasks T065 through T068 can run in parallel.
- User Story 5 test tasks T076 through T080 can run in parallel.
- Polish documentation and example test tasks T090 through T093 can run in parallel.

---

## Parallel Example: User Story 1

```bash
# Tests can be assigned together:
Task: "T020 [US1] Add RawDropify open and close tests in /Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_dropify_test.dart"
Task: "T021 [US1] Add RawDropify selection tests in /Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_dropify_selection_test.dart"
Task: "T023 [US1] Add RawStaticDropify search tests in /Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_static_dropify_test.dart"
Task: "T024 [US1] Add static golden tests in /Users/fady/Documents/Projects/dropify_flutter/test/goldens/dropify_static_golden_test.dart"

# Internal helpers can be assigned after tests are in place:
Task: "T025 [US1] Implement anchor internals in /Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_anchor.dart"
Task: "T026 [US1] Implement panel internals in /Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_panel.dart"
Task: "T027 [US1] Implement search field internals in /Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_search_field.dart"
Task: "T028 [US1] Implement focus scope internals in /Users/fady/Documents/Projects/dropify_flutter/lib/src/internal/_dropify_focus_scope.dart"
```

## Parallel Example: User Story 2

```bash
Task: "T037 [US2] Add async state tests in /Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_async_dropify_test.dart"
Task: "T038 [US2] Add async safety tests in /Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_async_dropify_async_safety_test.dart"
Task: "T039 [US2] Add async semantics tests in /Users/fady/Documents/Projects/dropify_flutter/test/accessibility/dropify_async_semantics_test.dart"
Task: "T040 [US2] Add async golden tests in /Users/fady/Documents/Projects/dropify_flutter/test/goldens/dropify_async_golden_test.dart"
```

## Parallel Example: User Story 3

```bash
Task: "T050 [US3] Add first-page tests in /Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_paginated_dropify_first_page_test.dart"
Task: "T051 [US3] Add footer tests in /Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_paginated_dropify_footer_test.dart"
Task: "T052 [US3] Add search reset tests in /Users/fady/Documents/Projects/dropify_flutter/test/widgets/raw_paginated_dropify_search_test.dart"
Task: "T053 [US3] Add paginated semantics tests in /Users/fady/Documents/Projects/dropify_flutter/test/accessibility/dropify_paginated_semantics_test.dart"
```

## Parallel Example: User Story 4

```bash
Task: "T065 [US4] Add single selection tests in /Users/fady/Documents/Projects/dropify_flutter/test/widgets/dropify_selection_modes_test.dart"
Task: "T066 [US4] Add live multi tests in /Users/fady/Documents/Projects/dropify_flutter/test/widgets/dropify_multi_selection_test.dart"
Task: "T067 [US4] Add confirmable multi tests in /Users/fady/Documents/Projects/dropify_flutter/test/widgets/dropify_confirmable_multi_test.dart"
Task: "T068 [US4] Add form identity tests in /Users/fady/Documents/Projects/dropify_flutter/test/widgets/dropify_form_identity_test.dart"
```

## Parallel Example: User Story 5

```bash
Task: "T076 [US5] Add theme data tests in /Users/fady/Documents/Projects/dropify_flutter/test/theme/dropify_theme_data_test.dart"
Task: "T078 [US5] Add keyboard tests in /Users/fady/Documents/Projects/dropify_flutter/test/accessibility/dropify_keyboard_test.dart"
Task: "T079 [US5] Add semantic key tests in /Users/fady/Documents/Projects/dropify_flutter/test/accessibility/dropify_semantic_keys_test.dart"
Task: "T080 [US5] Add theme golden tests in /Users/fady/Documents/Projects/dropify_flutter/test/goldens/dropify_theme_golden_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 Setup.
2. Complete Phase 2 Foundational tasks.
3. Complete Phase 3 User Story 1.
4. Stop and validate static raw and themed dropdown behavior independently with `flutter test` from `/Users/fady/Documents/Projects/dropify_flutter/`.
5. Demo the static dropdown page from `/Users/fady/Documents/Projects/dropify_flutter/example/lib/pages/static_dropdown_page.dart`.

### Incremental Delivery

1. Foundation ready: core primitives, internal helpers, public exports, and shared tests.
2. Add User Story 1: static dropdown MVP.
3. Add User Story 2: async search, retry, cancellation, and cache.
4. Add User Story 3: paginated caller-owned state.
5. Add User Story 4: cross-variant selection modes and form behavior.
6. Add User Story 5: complete theming, accessibility, keyboard, semantic keys, and visible copy.
7. Complete Phase 8 quality gates before release.

### Parallel Team Strategy

1. Team completes Setup and Foundational phases together.
2. After Foundational is complete, split by story where possible: one developer on US1, one on US2, one on US3.
3. Schedule US4 after core variant behavior exists because it verifies cross-variant consistency.
4. Schedule US5 across final shared surfaces because it validates theme, accessibility, and keyboard contracts across variants.

## Independent Test Criteria Summary

- **US1**: Static raw and themed dropdown can open, search, select enabled entries, ignore disabled entries, clear, validate, reset, and render large lists smoothly.
- **US2**: Async dropdown can show loading, data, empty, error, retry, refresh stale visible data, ignore stale completions, cancel obsolete work, and clear cache on reset/dispose.
- **US3**: Paginated dropdown can render all first-page and footer states, request next pages near threshold, retry failed pages, notify search resets, and avoid old-query page mixing.
- **US4**: Single, live multi, and confirmable multi modes emit or stage values correctly, apply or discard staged changes, respect identity rules, and behave correctly in forms.
- **US5**: Themed widgets resolve tokens in the required order, adapt to Material 3 defaults, operate by keyboard, expose stable semantic keys, announce state accessibly, and support localized visible copy.
