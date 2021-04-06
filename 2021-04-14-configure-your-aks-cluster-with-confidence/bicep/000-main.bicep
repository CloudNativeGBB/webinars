param prefix string
param clusterName string
param vnetPrefix string

module network '010-virtual-network.bicep' = {
  name: '${prefix}-vnet'
  params: {
    prefix: prefix
    location: resourceGroup().location
    vnetPrefix:  vnetPrefix
  }
}
