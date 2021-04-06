param prefix string
param location string
param vnetPrefix string
param subnets array

resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: '${prefix}-vnet'
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetPrefix
      ]
    }
  } 
}

resource subnetworks 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = [ for subnet in subnets: {
  name: 'subnets'
  properties: {
    
  }
}]

output vnetId string = vnet.id
