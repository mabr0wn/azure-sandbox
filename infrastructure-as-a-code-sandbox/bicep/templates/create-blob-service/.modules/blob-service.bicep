// -----
// TYPES
// -----
param blobname string
type corsRuleType = {
  @sys.description('A list of headers allowed to be part of the cross-origin request.')
  allowedHeaders: string[]

  @sys.description('A list of HTTP methods that are allowed to be executed by the origin.')
  allowedMethods: ('CONNECT' | 'DELETE' | 'GET' | 'HEAD' | 'MERGE' | 'OPTIONS' | 'PATCH' | 'POST' | 'PUT' | 'TRACE')[]

  @sys.description('A list of origin domains that will be allowed via CORS, or `*` to allow all domains.')
  allowedOrigins: string[]

  @sys.description('A list of response headers to expose to CORS clients.')
  exposedHeaders: string[]

  @sys.description('The number of seconds that the client/ browser should cache a preflight response.')
  maxAgeInSeconds: int
}

@minValue(0)
@maxValue(365)
@metadata({
  example: 7
})
@sys.description('The number of days to retain deleted blobs. When set to 0, soft delete is disabled.')
param blobSoftDeleteDays int = 7

@minValue(0)
@maxValue(365)
@metadata({
  example: 7
})
@sys.description('The number of days to retain deleted containers. When set to 0, soft delete is disabled.')
param containerSoftDeleteDays int = 7

@sys.description('Configures any CORS rules to apply to blob requests.')
param cors corsRuleType[] = []

@sys.description('Configure blob services for the Storage Account.')
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: blobname
  properties: {
    cors: {
      corsRules: cors ?? []
    }
    deleteRetentionPolicy: {
      enabled: blobSoftDeleteDays > 0

      #disable-next-line BCP329
      days: blobSoftDeleteDays > 0 ? blobSoftDeleteDays : null
    }
    containerDeleteRetentionPolicy: {
      enabled: containerSoftDeleteDays > 0

      #disable-next-line BCP329
      days: containerSoftDeleteDays > 0 ? containerSoftDeleteDays : null
    }
  }
}
