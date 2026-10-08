# network-security-group-security-rule submodule

This submodule deploys a network security rule as a child resource of a network security group.

## Usage

This submodule is intended for internal use by the parent `network-security-group` module. The parent module handles cardinality via `for_each`.

## Notes

This submodule follows AVM composition guidelines:
- Primary resource is named `this` (TFRMNFR2)
- No `count` or `for_each` on the primary resource; cardinality is the parent's responsibility (TFRMNFR1)
- Exposes `resource_types`, `retry`, and `timeouts` variables (TFFR6, TFFR7)
