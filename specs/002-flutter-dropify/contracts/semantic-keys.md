# Semantic Keys Contract

Stable semantic keys are part of the public testing contract for v0.1.0. They must remain stable within a semver minor version after release.

## Key Format

Keys use a package prefix and widget role:

```text
dropify.<scope>.<role>[.<qualifier>]
```

When a consumer supplies a widget `key`, Dropify-owned internal keys remain stable and do not derive from localized visible text.

## Required Keys

| Scope | Role | Key |
|-------|------|-----|
| core | anchor | `dropify.anchor` |
| core | clear button | `dropify.anchor.clear` |
| core | panel | `dropify.panel` |
| core | search field | `dropify.search.field` |
| core | search clear | `dropify.search.clear` |
| core | item | `dropify.item` plus stable identity suffix when available |
| core | item selected icon | `dropify.item.selectedIcon` |
| core | validation error | `dropify.validation.error` |
| multi | footer | `dropify.multi.footer` |
| multi | apply button | `dropify.multi.apply` |
| multi | cancel button | `dropify.multi.cancel` |
| async | loading | `dropify.async.loading` |
| async | refreshing | `dropify.async.refreshing` |
| async | empty | `dropify.async.empty` |
| async | error | `dropify.async.error` |
| async | retry | `dropify.async.retry` |
| paginated | first-page progress | `dropify.paging.firstPageProgress` |
| paginated | new-page progress | `dropify.paging.newPageProgress` |
| paginated | first-page error | `dropify.paging.firstPageError` |
| paginated | new-page error | `dropify.paging.newPageError` |
| paginated | no items | `dropify.paging.noItems` |
| paginated | no more items | `dropify.paging.noMoreItems` |
| paginated | retry | `dropify.paging.retry` |

## Item Identity Suffix

When `keyOf` is available, item keys may append a sanitized identity suffix:

```text
dropify.item.<identity>
```

Rules:

- The suffix must not depend on localized labels.
- The suffix must be stable for equivalent identity keys.
- If no stable identity is available, tests should locate items by semantics and list position rather than generated visible text keys.

## Semantics Requirements

- Keys do not replace semantic labels; both are required.
- Localized labels must not change stable keys.
- Disabled and selected states must be exposed through semantics, not only through visual styling.
