# SOLUTION: connect on-prem-2 and hub with a VNet-to-VNet connection

## Pre-requisites
In order to apply this solution you have to deploy `hub` and `on-premise-2` playgrounds.

## Solution
In order to make this connection, you have to create 2 connections one from on-prem to cloud and another from cloud to onprem

### Step 1: connection onprem-to-cloud
Open `on-prem-2-gateway`, go to Connections and add the following object
* Connection Name: `onprem2-to-cloud`
* Type: VNet-to-VNet
* First virtual Network Gateway:  `on-prem-2-gateway`
* Second virtual Network Gateway: `lab-gateway`
* Shared Key: `password.123`
* IKE: IKEv2

### Step 2: connection cloud-to-onprem
Open `lab-gateway`, go to Connections and add the following object
* Connection Name: `cloud-to-onprem2`
* Type: VNet-to-VNet
* First virtual Network Gateway:  `lab-gateway`
* Second virtual Network Gateway: `on-prem-gateway`
* Shared Key: `password.123`
* IKE: IKEv2

after a couple of minutes you will have the following connections:

| Name | Status | Connection Type | Peer |
|---|---|---|---|
|cloud-to-onprem2 | connected  |VNet-toVNet| lab-gateway |
|onprem2-to-cloud | connected |VNet-toVNet| lab-gateway |

## Test solution
Via bastion go to W10onprem (192.168.1.4) and from there open RDP to hub-vm-01 (10.12.1.4).
Ddthe same in the opposite direction