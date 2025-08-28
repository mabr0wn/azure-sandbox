const fs = require('fs');
const resolveAliases = require('../../../resolveAliases');

// Example Bicep template with aliases
const bicepTemplate = `
module deploymentScriptModule '${resolveAliases('@deploymentScript/externalScript.bicep')}' = {
  name: 'deploymentScriptModule'
  scope: resourceGroup()
 params: {
    location: location
    scriptContentParam: scriptContent
  }
}
`;

// Write the generated Bicep file
fs.writeFileSync('generated.bicep', bicepTemplate);
console.log('Generated Bicep file with resolved paths.');