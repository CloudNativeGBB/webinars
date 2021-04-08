param prefix string
param clusterName string
param vnetPrefix string

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

resource firewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${vnet.name}/AzureFirewallSubnet'
  properties: {
    addressPrefix: '10.0.0.0/26'
  }
}

module firewall 'modules/010-firewall.bicep' = {
  name: 'AzureFirewall'
  dependsOn: [
    firewallSubnet
  ]

  params: {
    prefix: prefix
    subnetId: '${vnet.id}/subnets/AzureFirewallSubnet'
  }
}

resource defaultRouteTable 'Microsoft.Network/routeTables@2020-08-01' = {
  dependsOn: [
    firewall
  ]
  name: 'DefaultRouteTable'
  properties: {
    
  }
}

resource defaultRoute 'Microsoft.Network/routeTables/routes@2020-08-01' = {
  dependsOn: [
    defaultRouteTable
  ]
  name: '${defaultRouteTable.name}/DefaultRoute'
  properties: {
    addressPrefix: '0.0.0.0/0'
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: firewall.outputs.privateIpAddress

  }
}

var subnets = [
  {
    name: 'VpnGatewaySubnet'
    addressPrefix: '10.0.1.0/24'
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

@batchSize(1)
resource defaultSubnets 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = [ for subnet in subnets: {
  dependsOn: [
    defaultRoute
  ]
  name: '${vnet.name}/${subnet.name}'
  properties: {
    addressPrefix: subnet.addressPrefix
    routeTable: defaultRouteTable
  }
}]

// Outputs
output vnetId string = vnet.id
