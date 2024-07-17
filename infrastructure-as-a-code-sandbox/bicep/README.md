# Azure Bicep README

## Table of Contents

1. [Introduction](#introduction)
2. [Why Use Azure Bicep?](#why-use-azure-bicep)
3. [Prerequisites](#prerequisites)
4. [Installation](#installation)
5. [Getting Started](#getting-started)
6. [Bicep Language Basics](#bicep-language-basics)
    - [Modules](#modules)
    - [Parameters](#parameters)
    - [Variables](#variables)
    - [Resources](#resources)
    - [Outputs](#outputs)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)
9. [Resources](#resources)

## Introduction

Azure Bicep is a domain-specific language (DSL) for deploying Azure resources declaratively. It aims to simplify the experience of creating complex Azure Resource Manager (ARM) templates. Bicep provides a more readable, concise syntax compared to traditional JSON ARM templates.

## Why Use Azure Bicep?

- **Simplified Syntax**: Bicep reduces the complexity of JSON syntax, making it easier to write and understand.
- **Modularization**: Supports reusable modules for better organization and maintainability.
- **Tooling Integration**: Seamlessly integrates with Azure CLI, Visual Studio Code, and other development tools.
- **Declarative Approach**: Enables infrastructure-as-code practices, allowing for version control and automation.
- **Directly Compiles to ARM Templates**: Ensures compatibility with existing ARM templates and Azure services.

## Prerequisites

Before you start using Azure Bicep, ensure you have the following:

- An Azure subscription
- Azure CLI installed
- Visual Studio Code installed
- Bicep extension for Visual Studio Code installed

## Installation

### Azure CLI

To install the latest version of the Azure CLI, follow the instructions [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

### Bicep CLI

Install the Bicep CLI using Azure CLI with the following command:

```sh
az bicep install
```

Verify the installation:

```sh
az bicep version
```

### Visual Studio Code Extension

Install the Bicep extension for Visual Studio Code from the [Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep).

## Getting Started

Create a new Bicep file with the `.bicep` extension and define your Azure resources. Here is a simple example of deploying a storage account:

```bicep
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'mystorageaccount'
  location: 'eastus'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
```

To deploy this Bicep file, use the Azure CLI:

```sh
az deployment group create --resource-group <resource-group-name> --template-file <path-to-bicep-file>
```

## Bicep Language Basics

### Modules

Modules allow you to break down complex deployments into smaller, reusable components.

```bicep
module vnet 'vnet.bicep' = {
  name: 'virtualNetwork'
  params: {
    vnetName: 'myVNet'
    addressPrefix: '10.0.0.0/16'
  }
}
```

### Parameters

Parameters allow you to pass values into your Bicep file.

```bicep
param location string = 'eastus'
param storageSku string = 'Standard_LRS'
```

### Variables

Variables store values that can be reused throughout your Bicep file.

```bicep
var storageName = 'mystorageaccount'
```

### Resources

Resources define the Azure services you want to deploy.

```bicep
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageName
  location: location
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
}
```

### Outputs

Outputs allow you to return values after deployment.

```bicep
output storageAccountName string = storageAccount.name
```

## Best Practices

- **Use Descriptive Names**: Name your resources, variables, and parameters descriptively.
- **Modularize**: Break down complex deployments into modules.
- **Version Control**: Store your Bicep files in a version control system like Git.
- **Parameterize**: Use parameters to make your Bicep files more flexible and reusable.
- **Validate**: Always validate your Bicep files using `az bicep build` to catch errors early.

## Troubleshooting

### Common Errors

- **Syntax Errors**: Ensure your Bicep file syntax is correct.
- **Missing Parameters**: Ensure all required parameters are provided during deployment.
- **Resource Naming Conflicts**: Ensure resource names are unique within the scope of your deployment.

### Debugging Tips

- **Use Outputs**: Utilize outputs to debug and verify the values of your resources.
- **Verbose Logging**: Use the `--verbose` flag with Azure CLI commands to get more detailed output.

## Resources

- [Azure Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Bicep GitHub Repository](https://github.com/Azure/bicep)
- [Azure Bicep Examples](https://github.com/Azure/bicep/tree/main/docs/examples)
- [Bicep Visual Studio Code Extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep)
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)

---

Feel free to reach out with any questions or feedback. Happy coding with Azure Bicep!