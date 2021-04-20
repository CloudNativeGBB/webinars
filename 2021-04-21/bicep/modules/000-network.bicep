param prefix string
param vnetPrefix string
param subnets array

resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: '${prefix}-vnet'
  location: resourceGroup().location

  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetPrefix
      ]
    }
  } 
}

@batchSize(1)
resource vnetSubnets 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = [ for subnet in subnets: {
  name: '${vnet.name}/${subnet.name}'
  properties: {
    addressPrefix: subnet.addressPrefix
  }
}]

output vnetId string = vnet.id
