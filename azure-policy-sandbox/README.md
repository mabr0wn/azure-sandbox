# Azure Policies README

## Table of Contents

1. [Introduction](#introduction)
2. [Why Use Azure Policies?](#why-use-azure-policies)
3. [Key Concepts](#key-concepts)
    - [Policy Definition](#policy-definition)
    - [Policy Assignment](#policy-assignment)
    - [Policy Parameters](#policy-parameters)
    - [Initiatives](#initiatives)
    - [Policy Effects](#policy-effects)
4. [Getting Started](#getting-started)
    - [Creating a Policy Definition](#creating-a-policy-definition)
    - [Assigning a Policy](#assigning-a-policy)
    - [Creating and Assigning Initiatives](#creating-and-assigning-initiatives)
5. [Common Policy Scenarios](#common-policy-scenarios)
    - [Allowed Resource Types](#allowed-resource-types)
    - [Enforce Tagging](#enforce-tagging)
    - [Location Restrictions](#location-restrictions)
6. [Monitoring and Compliance](#monitoring-and-compliance)
    - [Compliance Dashboard](#compliance-dashboard)
    - [Policy Insights](#policy-insights)
7. [Best Practices](#best-practices)
8. [Resources](#resources)
9. [Troubleshooting](#troubleshooting)

## Introduction

Azure Policy is a service in Azure that you use to create, assign, and manage policies. These policies enforce rules and effects over your resources so that those resources stay compliant with your corporate standards and service level agreements. Azure Policy does this by evaluating your resources for non-compliance with assigned policies. For example, you can use Azure Policy to enforce that all resources in your environment are tagged properly.

## Why Use Azure Policies?

- **Governance**: Ensure that your resources comply with your organization's standards and requirements.
- **Compliance**: Automatically check and enforce compliance with regulatory requirements.
- **Security**: Enforce security configurations and standards across your Azure environment.
- **Consistency**: Ensure that resources are consistently configured across multiple subscriptions and resource groups.
- **Cost Management**: Enforce policies that help manage costs, such as preventing the creation of expensive resource types.

## Key Concepts

### Policy Definition

A policy definition expresses what to evaluate and what action to take. For example, a policy can prevent the deployment of a storage account if it does not use HTTPS.

### Policy Assignment

A policy assignment is a policy definition that has been assigned to take place within a specific scope. This scope could range from a management group to a subscription, a resource group, or a single resource.

### Policy Parameters

Policy parameters are used to simplify the policy definition by allowing you to pass different values for the conditions in the policy. This helps you reuse policy definitions across different scenarios.

### Initiatives

An initiative is a collection of policy definitions that are tailored toward achieving a singular overarching goal. Initiatives simplify managing and assigning policy definitions by grouping a set of policies as one single item.

### Policy Effects

Policy effects are actions that are taken when the policy rule is matched. The main types of effects are:

- **Deny**: Blocks a non-compliant resource from being created or updated.
- **Audit**: Creates a warning event in the activity log when a non-compliant resource is created or updated.
- **Append**: Adds additional fields to the resource during creation or update.
- **Modify**: Modifies existing resources to make them compliant.
- **DeployIfNotExists**: Deploys a resource if it does not already exist.

## Getting Started

### Creating a Policy Definition

1. Go to the Azure Portal.
2. Navigate to "Policy" in the left-hand menu.
3. Click on "Definitions" under "Authoring".
4. Click on "+ Policy definition".
5. Fill out the required fields and define the policy rule in JSON format.

Example Policy Definition:
```json
{
  "properties": {
    "displayName": "Require Tag and its Value",
    "policyType": "Custom",
    "mode": "Indexed",
    "description": "Ensures that all resources have a specific tag and its value.",
    "parameters": {
      "tagName": {
        "type": "String",
        "metadata": {
          "displayName": "Tag Name",
          "description": "Name of the tag, such as 'environment'."
        }
      },
      "tagValue": {
        "type": "String",
        "metadata": {
          "displayName": "Tag Value",
          "description": "Value of the tag, such as 'production'."
        }
      }
    },
    "policyRule": {
      "if": {
        "field": "[concat('tags[', parameters('tagName'), ']')]",
        "exists": "false"
      },
      "then": {
        "effect": "Deny"
      }
    }
  }
}
```

### Assigning a Policy

1. Navigate to "Assignments" under "Authoring" in the Policy section.
2. Click on "+ Assign policy".
3. Select the scope (management group, subscription, or resource group).
4. Choose the policy definition.
5. Set the necessary parameters and assign the policy.

### Creating and Assigning Initiatives

1. Navigate to "Definitions" under "Authoring" in the Policy section.
2. Click on "+ Initiative definition".
3. Fill out the required fields and add the desired policy definitions to the initiative.
4. Assign the initiative in the same way as a single policy.

## Common Policy Scenarios

### Allowed Resource Types

Prevent the creation of unauthorized resource types.
```json
{
  "if": {
    "not": {
      "field": "type",
      "in": "[parameters('allowedResourceTypes')]"
    }
  },
  "then": {
    "effect": "Deny"
  }
}
```

### Enforce Tagging

Ensure that resources have specific tags.
```json
{
  "if": {
    "field": "[concat('tags[', parameters('tagName'), ']')]",
    "exists": "false"
  },
  "then": {
    "effect": "Deny"
  }
}
```

### Location Restrictions

Restrict resources to specific regions.
```json
{
  "if": {
    "not": {
      "field": "location",
      "in": "[parameters('allowedLocations')]"
    }
  },
  "then": {
    "effect": "Deny"
  }
}
```

## Monitoring and Compliance

### Compliance Dashboard

The compliance dashboard provides an overview of the compliance state of your resources against assigned policies and initiatives.

1. Navigate to "Policy" in the Azure Portal.
2. Click on "Compliance" to view the compliance state.

### Policy Insights

Policy insights provide detailed information about policy evaluation results, including non-compliance events and reasons.

1. Navigate to "Policy" in the Azure Portal.
2. Click on "Policy Insights" to view detailed reports.

## Best Practices

- **Start with Built-In Policies**: Use built-in policy definitions provided by Azure as a starting point.
- **Test Policies in Non-Production Environments**: Validate policies in a non-production environment before applying them broadly.
- **Use Initiatives for Grouping Policies**: Group related policies into initiatives for easier management.
- **Monitor Compliance Regularly**: Regularly review the compliance dashboard and policy insights to identify and address non-compliant resources.
- **Automate Remediation**: Use the "DeployIfNotExists" and "Modify" effects to automatically remediate non-compliant resources.

## Resources

- [Azure Policy Documentation](https://docs.microsoft.com/en-us/azure/governance/policy/)
- [Azure Policy Samples](https://github.com/Azure/azure-policy)
- [Azure Policy Reference](https://docs.microsoft.com/en-us/azure/governance/policy/samples/)
- [Azure Policy Best Practices](https://docs.microsoft.com/en-us/azure/governance/policy/best-practices/)

## Troubleshooting

### Common Issues

- **Policy Definition Errors**: Ensure the JSON syntax of your policy definition is correct.
- **Scope Issues**: Verify that the policy assignment scope includes the resources you intend to manage.
- **Non-Compliance**: Review the compliance details to understand why resources are non-compliant.

### Debugging Tips

- **Use Azure Monitor**: Leverage Azure Monitor to track policy evaluations and compliance events.
- **Check Activity Logs**: Review activity logs for policy assignment and evaluation actions.
- **Consult Documentation**: Refer to the Azure Policy documentation for troubleshooting guidance.

---

Feel free to reach out with any questions or feedback. Happy policy enforcement with Azure Policies!