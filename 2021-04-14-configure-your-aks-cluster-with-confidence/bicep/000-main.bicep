param prefix string
param clusterName string
param vnetPrefix string

module network '010-virtual-network.bicep' = {
  name: '${prefix}-vnet'
  params: {
    prefix: prefix
    location: resourceGroup().location
    vnetPrefix:  vnetPrefix
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        addressPrefix: '10.0.0.0/26'
      }
      {
        name: 'AksSubnet'
        addressPrefix: '10.0.4.0/22'
      }
      {
        name: 'JumpboxSubnet'
        addressPrefix: '10.0.255.240/28'
      }
    ]
  }
}
