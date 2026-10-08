# route-table-route submodule

This submodule deploys a route as a child resource of a route table.

## Usage

This submodule is intended for internal use by the parent `route-table` module. The parent module handles cardinality via `for_each`.

## Notes

This submodule follows AVM composition guidelines:
- Primary resource is named `this` (TFRMNFR2)
- No `count` or `for_each` on the primary resource; cardinality is the parent's responsibility (TFRMNFR1)
- Exposes `resource_types`, `retry`, and `timeouts` variables (TFFR6, TFFR7)
