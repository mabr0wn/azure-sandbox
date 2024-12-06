from azure.mgmt.network import NetworkManagementClient
from azure.identity import DefaultAzureCredential
import ipaddress

# Authenticate and initialize client
credential = DefaultAzureCredential()
client = NetworkManagementClient(credential, "<subscription_id>")

# Get subnet information
vnet_name = "<vnet_name>"
subnet_name = "<subnet_name>"
resource_group_name = "<resource_group>"
subnet = client.subnets.get(resource_group_name, vnet_name, subnet_name)

# Extract CIDR and used IPs
cidr = subnet.address_prefix
allocated_ips = [nic.ip_configuration.private_ip_address for nic in client.network_interfaces.list_all()]

# Create a set of all IPs in the CIDR range
network = ipaddress.IPv4Network(cidr, strict=False)
all_ips = set(str(ip) for ip in network.hosts())  # `hosts()` excludes network and broadcast

# Remove allocated IPs from the set
available_ips = all_ips - set(allocated_ips)

# Output the available IPs
print(f"Available IPs: {available_ips}")
