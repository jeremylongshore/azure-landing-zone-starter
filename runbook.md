# Runbook: Storage Availability Alert

**Alert:** `alert-<project>-<env>-storage-availability`  
**Resource:** Azure Storage Account (landing zone starter)  
**Severity:** 2 (warning / high — service degraded or unreachable)  
**Defined in:** `modules/monitoring/main.tf`  
**Fires when:** `Microsoft.Storage/storageAccounts` metric **Availability** average **&lt; 100** over a **5-minute** window.

---

## 1. Confirm the alert is real

1. Open Azure Portal → **Monitor** → **Alerts** → select the fired alert.
2. Note **fired time**, **resource ID**, and **monitor condition** (Fired vs Resolved).
3. Check [Azure Status](https://azure.status.microsoft/en-us/status) for the deployment region (`eastus` by default).
4. If the region is degraded, treat as platform incident — skip local config churn until Microsoft recovers.

```bash
# CLI confirm (replace names)
az monitor metrics list \
  --resource "/subscriptions/<sub>/resourceGroups/rg-alz-dev/providers/Microsoft.Storage/storageAccounts/<sa-name>" \
  --metric Availability \
  --interval PT5M \
  --aggregation Average
```

---

## 2. Triage sequence

| Step | Check | Command / action |
|------|--------|------------------|
| 1 | Account exists and is not deleted | Portal → Storage account, or `az storage account show -g rg-alz-dev -n <sa>` |
| 2 | Account provisioning state | Look for `Succeeded` vs failed/updating |
| 3 | Soft-delete / accidental wipe | Blob soft-delete retention is **7 days** (`modules/storage/main.tf`). Recover deleted blobs/containers from Portal → **Data protection** / undelete |
| 4 | Network blocks | This starter leaves public network access on (no private endpoint). If you added firewall rules later, confirm client IPs / VNet rules allow health probes and your apps |
| 5 | Diagnostic logs | Log Analytics workspace `log-alz-dev` — query StorageRead/Write/Delete via diagnostic setting `diag-storage-blob` |
| 6 | Capacity / throttling | Metrics: Transactions, SuccessE2ELatency, UsedCapacity. Sustained 503/timeouts may present as availability dips |

### Useful KQL (Log Analytics)

```kusto
// Adjust TimeGenerated window to the alert window
StorageBlobLogs
| where TimeGenerated > ago(1h)
| where StatusCode >= 500 or StatusText !in ("Success", "SASSuccess")
| summarize count() by StatusCode, StatusText, bin(TimeGenerated, 5m)
| order by TimeGenerated desc
```

> Note: Log table names can vary by diagnostic category wiring. If `StorageBlobLogs` is empty, use **Metrics** explorer first.

---

## 3. Mitigations

| Cause | Action |
|-------|--------|
| Regional Azure outage | Wait / failover to secondary region (not in this starter — document RTO with stakeholders) |
| Accidental delete | Restore from soft-delete / blob versions within 7 days |
| Lifecycle policy deleted hot data | Review `azurerm_storage_management_policy` rules; cool@30d / archive@60d / delete@90d on `app-data/` prefix |
| Misconfigured firewall (post-hoc) | Open required paths or switch to private endpoint + PE DNS (out of scope for free-tier starter) |
| Client-side only failures | Availability is a platform metric — if metric is 100% but app fails, debug app auth/SDK, not storage health |

Do **not** immediately destroy/recreate the storage account — that loses the soft-delete window and state alignment with Terraform.

---

## 4. Escalation

| Level | When | Who |
|-------|------|-----|
| L1 | First response, confirm metric + status page | On-call / engineer who acknowledged the alert |
| L2 | Confirmed storage degradation, data risk, or &gt;15 min open | Platform owner / Azure subscription admin |
| L3 | Regional outage or Microsoft-side defect | Open Azure Support request (severity per business impact) |

Internal placeholders (fill for real ops):

- On-call rotation: _TBD_
- Platform owner: _TBD_
- Support contract / ticket portal: Azure Portal → Help + support

---

## 5. Silence / change the alert via code

Threshold and window are code-owned. Change them with a PR, not a portal click-ops permanent edit.

- File: `modules/monitoring/main.tf` → `azurerm_monitor_metric_alert.storage_availability`
- Lower noise: raise window to `PT15M` or threshold tolerance
- Route email: set `alert_email` in `terraform.tfvars` and re-apply

```bash
terraform plan
terraform apply
```

After mitigation, confirm alert **Resolved** in Monitor. File a short note: time-to-detect, time-to-mitigate, root cause, follow-up PR if any.

---

## 6. Related resources

| Resource | Terraform |
|----------|-----------|
| Storage account + soft-delete + versioning | `modules/storage/main.tf` |
| Lifecycle policy | `azurerm_storage_management_policy.lifecycle` |
| Log Analytics + diagnostic setting | `modules/monitoring/main.tf` |
| Action group | `azurerm_monitor_action_group.ops` |
