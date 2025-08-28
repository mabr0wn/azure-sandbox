// Define parameters for the Automation Account and Runbook
param location string = resourceGroup().location
param automationAccountName string
param runbookName string
param runbookType string  // Other options: 'Python2', 'Python3', 'Graph', PowerShell etc.
param runbookDescription string
param runbookContent string

resource automationAccount 'Microsoft.Automation/automationAccounts@2020-01-13-preview' = {
  name: automationAccountName
  location: location
  properties: {}
}

resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2020-01-13-preview' = {
  parent: automationAccount
  name: runbookName
  location: location
  properties: {
    runbookType: runbookType
    description: runbookDescription
    logVerbose: true
    logProgress: true
    publishContentLink: null
    draft: {
      inEdit: false
    }
  }
}

resource runbookScript 'Microsoft.Automation/automationAccounts/runbooks/content@2020-01-13-preview' = {
  parent: runbook
  name: runbookName
  properties: {
    script: runbookContent
  }
}

output automationAccountId string = automationAccount.id
output runbookId string = runbook.id
