using './main.bicep'

param workspaceName = 'skynet-workspace'
param workspaceId = '/subscriptions/d3c58f05-ba94-4319-ba03-af2cde1d8529/resourceGroups/sandbox-rg/providers/Microsoft.OperationalInsights/workspaces/skynet-workspace'
param kvname = 'kv-skynet'
param name = 'skynet-audit-logs'
param hsmName = 'hsm-skynet' // 👈 Add this line
