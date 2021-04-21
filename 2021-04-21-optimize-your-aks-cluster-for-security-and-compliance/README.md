# Webinar 2

## Additions to this template
- Subnet for Azure Firewall (Added Subnet Settings)
- Subnet for Jumpbox/Bastion Server for admin tasks
- Azure Firewall (New Module)
- Azure Firewall Network and Application Rules to allow AKS to function
- Route Table/User Defined Route to force traffic in AKS Subnet to Azure Firewall
- AKS Settings Changed:
	- Private Cluster Enabled
	- Outbound Type set to "userDefinedRouting" to remove public IP address on cluster load balancer
		- Requires a Route Table on AKS Subnet to be defined
		- Requires the Route in Route Table to direct default trafic (0.0.0.0/0) to an appliance (e.g. Azure Firewall)
- Added a Jumpbox/Basition VM in new Jumpbox Subnet
	- Since we're using "private cluster" - the AKS/K8s control plane is no longer a public internet resource and can only be reached via private networking (i.e. only Resources in our VNET can reach the control plane)