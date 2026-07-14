# Architecture: azure-landing-zone-starter

> Free-tier-friendly Azure landing zone starter in Terraform — hub/spoke networking, NSGs, storage lifecycle, Log Analytics, metric alerts, and GitHub Actions plan/apply.

**Author:** Jeremy Longshore
**Date:** 2026-07-14
**Status:** Draft

## System Context

<!-- Where does this system fit in the broader ecosystem? -->

## Component Design

| Component | Responsibility |
|-----------|---------------|
| <!-- component --> | <!-- what it does --> |

## Data Flow

```
[Input] → [Processing] → [Output]
```

<!-- Describe the primary data flow through the system -->

## Integration Points

| Endpoint/Service | Method | Purpose |
|-----------------|--------|---------|
| <!-- endpoint --> | <!-- GET/POST/etc --> | <!-- purpose --> |

## Security Model

- **Authentication:** <!-- method -->
- **Authorization:** <!-- method -->
- **Data Classification:** <!-- PII, confidential, public -->
- **Secrets Management:** <!-- env vars, vault, etc -->

## Error Handling

| Error | Code | Message | Recovery |
|-------|------|---------|----------|
| <!-- error --> | <!-- code --> | <!-- message --> | <!-- recovery --> |

## Performance

| Operation | Target | Max |
|-----------|--------|-----|
| <!-- operation --> | <!-- target latency --> | <!-- max latency --> |

## Infrastructure

- **Hosting:** <!-- cloud provider, service -->
- **CI/CD:** GitHub Actions
- **Monitoring:** <!-- tool -->
- **Logging:** <!-- tool -->


## Implementation (as shipped)

- **Hub VNet** `10.0.0.0/16`: `snet-app` (10.0.1.0/24), `snet-data` (10.0.2.0/24)
- **Spoke VNet** `10.10.0.0/16`: on-prem connectivity stand-in via VNet peering
- **NSGs** restrict spoke→app (80/443), app→data (5432/1433); deny Internet to private tiers
- **Storage** Standard LRS, versioning + 7-day soft-delete, lifecycle cool/archive/delete
- **Monitoring** Log Analytics + diagnostic setting on blob service + Availability metric alert
- **CI** fmt/validate always; plan/apply when Azure OIDC secrets are configured
