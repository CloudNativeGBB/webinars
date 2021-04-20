param prefix string
param suffix string
param applicationRuleCollections array = []
param natRuleCollections array = []
param networkRuleCollections array = []
param subnetId string

resource publicIp 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name: '${prefix}-${suffix}-fw-pip'
  location: resourceGroup().location
  tags: {}
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: '${prefix}-${suffix}-fw-pip'
    }
    ipAddress: 'string' 
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2020-07-01' = {
  name: 'string'
  location: resourceGroup().location
  tags: {}
  properties: {
    applicationRuleCollections: applicationRuleCollections
    natRuleCollections: natRuleCollections
    networkRuleCollections: networkRuleCollections
    ipConfigurations: [
      {
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
        name: 'primary'
      }
    ]
    sku: {
      name: 'AZFW_VNet'
    }
  }
}
