# Changelog

## [v0.1.7] - 2026-09-25

- build(deps): bump actions/github-script from 8 to 9 (#4) (adbff2b)


## [v0.1.6] - 2026-09-24

- fix(release): count orphaned tags and push the release commit and tag atomically (#15) (e550eda)
- build(deps): bump actions/upload-artifact from 4 to 7 (#5) (d47e60a)
- build(deps): bump hashicorp/setup-terraform from 3 to 4 (#3) (236e0fd)
- build(deps): bump actions/checkout from 4 to 7 (#2) (68a6cb5)
- build(deps): bump azure/login from 2 to 3 (#1) (1ad97ec)


## [v0.1.4] - 2026-09-24

- chore(deps): bump hashicorp/random from 3.9.0 to 3.9.1 (#13) (429f135)


## [v0.1.3] - 2026-09-19

- ci(deps): move GitHub actions off the node20 runtime before its removal (#12) (17bcd4a)


## [v0.1.2] - 2026-08-25

- chore(funding): add Ko-fi alongside the existing funding sources (4ca64a9)
- docs(readme): add the Ko-fi support badge (b156e09)


## [v0.1.1] - 2026-07-14

- fix(ci): avoid secrets in job-level if for terraform workflow (9278411)


All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-07-14

### Added

- Initial landing zone starter: resource group, hub/spoke VNets, NSGs, peering
- Storage account with soft-delete, versioning, and lifecycle policy
- Log Analytics workspace, storage diagnostics, availability metric alert
- GitHub Actions: CI (fmt/validate), Terraform plan/apply (OIDC + SP docs), release
- Operational runbook for storage availability alert
- Repo governance set (LICENSE MIT, SECURITY, CONTRIBUTING, 000-docs)

[0.1.0]: https://github.com/jeremylongshore/azure-landing-zone-starter/releases/tag/v0.1.0
