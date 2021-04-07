param prefix string
param clusterName string
param vnetPrefix string

module Network 'modules/000-network.bicep' = {
  name: 'webinar-vnet'
  params: {
    prefix: prefix
    vnetPrefix: '10.0.0.0/16'
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        addressPrefix: '10.0.0.0/26'
      }
      {
        name: 'AksSubnet'
        addressPrefix: '10.0.4.0/22'
      }
    ]
  }
}

module Firewall 'modules/010-firewall.bicep' = {
  name: 'AzureFirewall'
  dependsOn: [
    Network
  ]

  params: {
    prefix: prefix
    subnetId: '${Network.outputs.vnetId}/subnets/AzureFirewallSubnet'
  }
}
