# AKS Private Deployment Guide

## Installing the Deployment Template

To install the deployment template, follow these steps:

```bash
export ACR_ROLE=$(az role definition list --name 'AcrPull' | jq -r .[].id)
az deployment sub create --location eastus --template-file main.bicep --parameter aks.bicepparam
```

## Overview of Deployed Resources

### Resource Group
- **Resource Group Creation**: The deployment will create a resource group.
- **Scoped Deployments**: Deployments within the resource group are managed via modules scoped to the resource group.

### Virtual Network (VNet)
- **VNet with Subnets**: The deployment configures a VNet with the following subnets:
  - **AKS**: Subnet designated for Azure Kubernetes Service.
  - **ILB**: Subnet for Internal Load Balancer.
  - **Azure Firewall**: Subnet for Azure Firewall.
  - **Azure Bastion**: Subnet for Azure Bastion.
  - **Management**: Subnet for management purposes.
- **Integrated Subnets**: Subnets are created as part of the VNet configuration, not as separate entities.

### Azure Bastion
- **Azure Bastion Deployment**: Deploys Azure Bastion to enable secure and seamless RDP/SSH connectivity to the Jump Box or AKS nodes.

### Azure Firewall
- **Firewall Deployment**: Deploys Azure Firewall with predefined rules for securing Azure Kubernetes Service (AKS) traffic.

### Private AKS Cluster
- **AKS Cluster**: Deploys a private AKS cluster with a single system pool.
- **Egress Traffic**: Configures egress traffic to route through Azure Firewall.

### User Defined Route (UDR)
- **UDR Configuration**: Creates a User Defined Route (UDR) on the AKS subnet to route traffic to the Azure Firewall.
- **Azure Firewall Internal IP**: The internal IP of the Azure Firewall is hardcoded as the first IP of the Azure Firewall subnet.

### Jump Box
- **Jump Box Deployment**: Deploys a Jump Box with Ubuntu 18.04 LTS for administrative access.

### Azure Container Registry (ACR)
- **ACR Deployment**: Deploys an Azure Container Registry with a Private Endpoint.
- **Private DNS Integration**: Configures private DNS for the Azure Container Registry.

This detailed guide covers the setup and deployment of a private AKS environment with necessary networking, security, and access configurations.