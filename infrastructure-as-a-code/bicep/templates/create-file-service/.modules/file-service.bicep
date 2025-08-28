// Parameters
@sys.description('The name of the File service.')
param name string

@metadata({
  example: [
    {
      name: 'SHARE_NAME'
      shareQuota: 5
      metadata: {}
    }
  ]
})
@sys.description('An array of file shares to create on the Storage Account.')
param shares object[] = []

@minValue(0)
@maxValue(365)
@metadata({
  example: 7
})
@sys.description('The number of days to retain deleted shares. When set to 0, soft delete is disabled.')
param shareSoftDeleteDays int = 7

@sys.description('Configure file services for the Storage Account.')
resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  name: name
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: shareSoftDeleteDays > 0

      #disable-next-line BCP329
      days: shareSoftDeleteDays > 0 ? shareSoftDeleteDays : null
    }
  }
}

@sys.description('Create or update file shares for the Storage Account.')
resource storageShares 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = [for item in shares: if (!empty(shares)) {
  parent: fileServices
  name: item.name
  properties: {
    metadata: contains(item, 'metadata') ? item.metadata : {}
    shareQuota: contains(item, 'shareQuota') ? item.shareQuota : 5120
  }
}]
