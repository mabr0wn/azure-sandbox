# pip install azure-identity azure-mgmt-compute pyyaml
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
import os, json, sys, yaml

# Defaults (used if no config file or env override)
SUB_ID = os.environ.get("AZ_SUBSCRIPTION_ID")
REGIONS = ["eastus", "eastus2", "centralus", "southcentralus"]
SKUS = ["Standard_D4s_v5", "Standard_D8s_v5"]

# Try to load regions/SKUs from config/targets.yml if present
config_file = os.path.join(os.path.dirname(__file__), "..", "config", "targets.yml")

if os.path.exists(config_file):
    with open(config_file, "r") as f:
        cfg = yaml.safe_load(f)
    SUB_ID = cfg.get("subscription_id", SUB_ID)
    REGIONS = cfg.get("regions", REGIONS)
    SKUS = cfg.get("skus", SKUS)

cred = DefaultAzureCredential()
cmp = ComputeManagementClient(cred, SUB_ID)

report = []
problems = []

for region in REGIONS:
    for sku in SKUS:
        found = False
        restricted = None
        for s in cmp.resource_skus.list():
            if s.resource_type == "virtualMachines" and s.name == sku:
                if region in [loc.lower() for loc in s.locations or []]:
                    found = True
                    # any restrictions for this region?
                    restr = [
                        r for r in (s.restrictions or [])
                        if region in [l.lower() for l in (r.locations or [])]
                    ]
                    restricted = restr if restr else []
                    break
        entry = {
            "region": region,
            "sku": sku,
            "available": found and not restricted,
            "restricted": bool(restricted),
        }
        report.append(entry)
        if not found or restricted:
            problems.append(entry)

print(json.dumps({"results": report}, indent=2))
