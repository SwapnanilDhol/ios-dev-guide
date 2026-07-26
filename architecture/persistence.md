# Persistence

Principles for Core Data (or similar) host apps. Domain inventories stay in the **app** `Docs/` — this page is the reusable split.

## Principles

1. **Provider** = app-facing async CRUD over mapped domain models.
2. **Service** = UserDefaults / lightweight prefs (not Core Data).
3. **Coordinator** = cross-cutting orchestration; may hold a shared provider and pass it to child VMs — avoid constructing providers at every call site.
4. Keep aggregation / SQL-style queries on the stack manager (or dedicated extensions), not duplicated ad hoc in every feature.
5. One mapping direction per file under a `Proxy/` (or equivalent) folder — no catch-all `Entity+.swift` files.

## Typical layout

```text
Persistence/
  CoreDataManager.swift          # stack, contexts
  CoreDataManager+Entity.swift   # entity CRUD / fetches
  CoreDataManager+Aggregation.swift
  Proxy/
    DomainModel.swift
    DomainModel+Managed.swift    # Managed → Domain
    Managed+DomainModel.swift    # Domain → Managed
Service/
  EntityProvider.swift           # async API used by VMs
```

## Conventions

- Modules and providers call into Persistence — views never talk to Core Data.
- Prefer concrete providers; use test subclasses in `MockProviders.swift` instead of `*Providing` protocols.
- Schema / migration guards belong in unit tests next to the model.

## Checklist

- [ ] Views / VMs use providers, not `NSManagedObjectContext` directly
- [ ] Prefs vs CRUD split is clear (Service vs Provider)
- [ ] Shared provider injected from coordinators where features share data
- [ ] Proxy mapping is one direction per file
- [ ] Aggregation helpers are not copy-pasted across features
