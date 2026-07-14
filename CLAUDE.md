# CLAUDE.md

Guidance for working in `azure-landing-zone-starter`.

## What this is

Portfolio / starter Terraform stack for an Azure landing zone: hub/spoke VNets, NSGs, storage lifecycle, Log Analytics, metric alert, GitHub Actions plan/apply. Public MIT repo under `jeremylongshore`.

## Commands

```bash
terraform fmt -recursive
terraform init -backend=false
terraform validate
terraform plan    # needs subscription_id + Azure auth
terraform apply
terraform destroy
```

## Layout

- Root: `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`, `versions.tf`
- Modules: `modules/network`, `modules/storage`, `modules/monitoring`
- Ops: `runbook.md`
- CI: `.github/workflows/ci.yml` (always), `terraform.yml` (plan/apply when secrets present)

## Rules

- Keep resources free-tier friendly. No ExpressRoute, VPN Gateway, Bastion, or Firewall unless explicitly requested.
- Spoke VNet is the documented on-prem stand-in — do not "fix" it to a real gateway without cost discussion.
- Never commit `*.tfvars` or state files (see `.gitignore`).
- Prefer code changes for alert thresholds over portal click-ops.
- azurerm 4.x requires `subscription_id` on the provider (or `ARM_SUBSCRIPTION_ID`).

## Author

Jeremy Longshore <jeremy@jeremylongshore.com>
