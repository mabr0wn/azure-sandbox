# SOLUTION: configure a DNS on the cloud, so that all machines are reachable via FQDN

## Pre-requisites

In order to apply this solution you have to deploy hub playground only.

## Solution

From Azure Portal create a Private DNS zone named `cloudasset.interal`, with the following Network links:

| Name | Network name |
|---|---|
|hub | hub-lab-net |
|spoke01 | spoke-01 |
|spoke02 | spoke-02 |
|spoke03 | spoke-03 |

Enable `auto-registration` on all network. The result is:

| Link Name | Link status | Virtual Network | Auto-registration |
|---|---|---|---|
| hub | Completed | hub-lab-net | Enabled |
| spoke01 | Completed | spoke-01 | Enabled |
| spoke02 | Completed | spoke-02 | Enabled |
| spoke03 | Completed | spoke-03 | Enabled |

in order to have an additiona ALIAS for `spoke-01-vm` add the following record:

Name: vm01.spoke01[.cloudasset.internal]
Type: A
IP: `10.13.1.4`

## Test solution
Connect via RDP from hub-vm-01 machine to spoke-01 VM using the following Names:
* spoke-01-vm.cloudasset.internal
* vm01.spoke01.cloudasset.intenal