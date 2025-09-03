# 📄 `scripts/azure-capacity/README.md`

# Azure Capacity Scout

Lightweight checks to detect **Azure VM SKU restrictions** and **quota risk** per region,
plus a daily GitHub Actions job that emails a **CSV + JSON** report.

## What it does
- Queries Azure **Resource SKUs** for your subscription to see if a VM size (SKU)
  is **restricted** in a region (capacity/zone/subscription).
- Converts results to **CSV** and emails them (via O365 SMTP by default).
- Publishes artifacts from the run (JSON, CSV, summary).

> Note: Azure does **not** publish region utilization (e.g., “East US 2 = 85% full”).
> This toolkit surfaces the **practical signal**: *can you deploy this SKU in this region now?*

---

## Repo layout (this folder)

```

scripts/azure-capacity/
├─ bin/
│  ├─ check-sku.sh        # check one SKU in one region
│  └─ scan-region.sh      # list restricted SKUs for a region
├─ py/
│  ├─ capacity\_scout.py   # Python: scan SKUs/regions -> JSON (+ optional Slack)
│  └─ quota\_guard.ps1     # PowerShell: simple quota buffer check (optional)
├─ config/
│  └─ targets.yml         # regions/SKUs to monitor (optional; for your script variant)
├─ reports/               # generated output (gitignored)
└─ README.md

```

---

## Prereqs
- Azure CLI authenticated: `az login`
- Python 3.11+ with:
```

pip install -r requirements.txt

```
(needs `azure-identity`, `azure-mgmt-compute`, `requests`)
- Set env var for local runs:
```

export AZ\_SUBSCRIPTION\_ID="<your-subscription-guid>"

````

---

## Quick start (local)

**Check a single SKU/region**
```bash
SKU="Standard_D4s_v5" REGION="eastus2" ./scripts/azure-capacity/bin/check-sku.sh
````

**See what’s restricted in a region**

```bash
REGION="southeastasia" ./scripts/azure-capacity/bin/scan-region.sh
```

**Run the Python scout to JSON**

```bash
python scripts/azure-capacity/py/capacity_scout.py > scripts/azure-capacity/reports/last.json
```

**Make CSV from JSON**

```bash
jq -r '["region","sku","available","restricted"], (.results[] | [.region,.sku,.available,.restricted]) | @csv' \
  scripts/azure-capacity/reports/last.json > scripts/azure-capacity/reports/last.csv
```

---

## GitHub Actions (daily email)

Workflow file lives at: `.github/workflows/azure-capacity.yml`

### Required secrets

* `AZURE_CREDENTIALS` – JSON from `az ad sp create-for-rbac --sdk-auth`
* `AZ_SUBSCRIPTION_ID`
* **Email (O365 SMTP):**

  * `O365_USERNAME` (e.g., `azure-capacity-bot@yourorg.com`)
  * `O365_PASSWORD` (mailbox password or app password)
  * `O365_FROM` (same address as username, or display name address)
  * `REPORT_TO` (comma-separated recipients)

> If SMTP AUTH is disabled in your tenant, enable for the bot mailbox or switch to
> Microsoft Graph (app-only `Mail.Send`) in a future iteration.

---

## Interpreting results

* `available=true, restricted=false` → ✅ You can deploy this SKU in that region.
* `restricted=true` or absent SKU → ⚠️ Treat as **capacity/zone/subscription** constraint.
* Use **fallback regions** or **alternate SKUs** in IaC when restrictions appear.

---

## Troubleshooting

* **Empty results / auth errors**: ensure `AZ_SUBSCRIPTION_ID` is set and the Action logs in with correct `AZURE_CREDENTIALS`.
* **Email fails**: verify SMTP AUTH is enabled for the sender mailbox (`smtp.office365.com:587`, STARTTLS).
* **jq not found**: the GitHub runner `ubuntu-latest` includes `jq`; for local macOS, `brew install jq`.

---

````yml

---

# ⚙️ `.github/workflows/azure-capacity.yml`


name: azure-capacity
on:
  schedule: [ { cron: "0 12 * * *" } ]  # daily UTC
  workflow_dispatch: {}

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - run: pip install -r requirements.txt

      - name: Azure login
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Capacity scout (JSON)
        env:
          AZ_SUBSCRIPTION_ID: ${{ secrets.AZ_SUBSCRIPTION_ID }}
        run: |
          mkdir -p scripts/azure-capacity/reports
          python scripts/azure-capacity/py/capacity_scout.py > scripts/azure-capacity/reports/last.json

      - name: Build CSV from JSON
        run: |
          jq -r '
            ["region","sku","available","restricted"],
            (.results[] | [.region,.sku,.available,.restricted])
            | @csv
          ' scripts/azure-capacity/reports/last.json \
          > scripts/azure-capacity/reports/last.csv

      - name: Build plain-text summary for email body
        id: summary_out
        run: |
          {
            echo "Azure Capacity Report"
            echo
            jq -r '
              .results
              | (["Region","SKU","Available","Restricted"]),
                (.[] | [.region,.sku, (if .available then "yes" else "no" end), (if .restricted then "yes" else "no" end)])
              | @tsv
            ' scripts/azure-capacity/reports/last.json | column -t -s$'\t'
          } > scripts/azure-capacity/reports/summary.txt
          echo 'summary<<EOF' >> "$GITHUB_OUTPUT"
          cat scripts/azure-capacity/reports/summary.txt >> "$GITHUB_OUTPUT"
          echo 'EOF' >> "$GITHUB_OUTPUT"

      - name: Email report (O365 SMTP)
        if: always()
        uses: dawidd6/action-send-mail@v3
        with:
          server_address: smtp.office365.com
          server_port: 587
          secure: starttls
          username: ${{ secrets.O365_USERNAME }}
          password: ${{ secrets.O365_PASSWORD }}
          subject: "Azure Capacity Report - ${{ github.repository }} - Run #${{ github.run_number }}"
          to: ${{ secrets.REPORT_TO }}
          from: Azure Capacity Bot <${{ secrets.O365_FROM }}>
          body: ${{ steps.summary_out.outputs.summary }}
          attachments: |
            scripts/azure-capacity/reports/last.json
            scripts/azure-capacity/reports/last.csv

      - name: Upload report artifacts
        uses: actions/upload-artifact@v4
        with:
          name: capacity-report
          path: |
            scripts/azure-capacity/reports/last.json
            scripts/azure-capacity/reports/last.csv
            scripts/azure-capacity/reports/summary.txt
````

That’s solid 👍 — right now your `.gitignore` is telling Git:

* Don’t track generated **reports** (JSON/CSV summaries).
* Don’t track your **real `targets.yml`** (so each engineer/runner can keep their own without polluting the repo).

---

### To make this extra clean for anyone using the repo

Add a `scripts/azure-capacity/config/targets.example.yml` **into Git** so the structure is visible:

```yaml
# scripts/azure-capacity/config/targets.example.yml
subscription_id: "00000000-1111-2222-3333-444444444444"

regions:
  - eastus
  - eastus2
  - centralus

skus:
  - Standard_D4s_v5
  - Standard_E4s_v5
```

> Copy `targets.example.yml` to `targets.yml` and edit it with your subscription ID, preferred regions, and SKUs.

---

