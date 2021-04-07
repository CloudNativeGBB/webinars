param prefix string
param subnetId string

resource FirewallPublicIp 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: '${prefix}AzureFirewallPublicIP'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: '${prefix}-firewall'
    }
  }
}

resource Firewall 'Microsoft.Network/azureFirewalls@2020-08-01' = {
  name: 'AzureFirewall'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: 'primary'
        properties: {
          publicIPAddress: {
            id: FirewallPublicIp.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
      
  }
}

output privateIpAddress string = Firewall.properties.hubIPAddresses.privateIPAddress
