const fs = require('fs');
const path = require('path');

// Load the path aliases configuration
const aliasConfig = JSON.parse(fs.readFileSync('../pathAliases.json', 'utf-8'));

// Function to resolve an alias to its actual path
function resolvePath(alias) {
  for (const [key, value] of Object.entries(aliasConfig)) {
    const regex = new RegExp(`^${key.replace('*', '.*')}$`);
    if (regex.test(alias)) {
      return path.join(__dirname, value, alias.replace(key.replace('*', ''), ''));
    }
  }
  throw new Error(`Alias not found: ${alias}`);
}

// Example usage
const alias = [
    '@deploymentScript/externalScript.bicep',
    '@storageAccount/storage.bicep',
    '@blobService/blob-service.bicep'
]
const resolvedPath = resolvePath(alias);
console.log(`Resolved path: ${resolvedPath}`);