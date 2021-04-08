param prefix string
param clusterName string
param vnetPrefix string
param adminUsername string = 'azueruser'
param adminPublicKey string
param aadTenantId string = subscription().tenantId
param adminGroupObjectIDs array = []

var firewallSubnetInfo = {
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefix: '10.0.0.0/26'
  }
}

var vpnGatewaySubnetInfo = {
  name: 'GatewaySubnet'
  properties: {
    addressPrefix: '10.0.1.0/24'
  }
}

var aksSubnetInfo = {
  name: 'AksSubnet'
  properties: {
    addressPrefix: '10.0.4.0/22'
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

var jumpboxSubnetInfo = {
  name: 'JumpboxSubnet'
  properties: {
    addressPrefix: '10.0.255.240/28'
  }
}

var allSubnets = [
  firewallSubnetInfo
  vpnGatewaySubnetInfo
  aksSubnetInfo
  jumpboxSubnetInfo
]

var genericSubnets = [
  aksSubnetInfo
  jumpboxSubnetInfo
]

resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: '${prefix}-vnet'
  location: resourceGroup().location

  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetPrefix
      ]
    }
    subnets: allSubnets
  } 
}

resource firewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${vnet.name}/${firewallSubnetInfo.name}'
  properties: firewallSubnetInfo.properties
}

resource vpnGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  dependsOn: [
    firewallSubnet
  ]

  name: '${vnet.name}/${vpnGatewaySubnetInfo.name}'
  properties: vpnGatewaySubnetInfo.properties
}

@batchSize(1)
resource defaultSubnets 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = [ for subnet in genericSubnets: {
  dependsOn: [
    vpnGatewaySubnet
    defaultRouteTable
  ]

  name: '${vnet.name}/${subnet.name}'
  properties: {
    addressPrefix: subnet.properties.addressPrefix
    routeTable: {
      id: defaultRouteTable.id
    }
    privateEndpointNetworkPolicies: 'Disabled'
  }
}]

resource defaultRouteTable 'Microsoft.Network/routeTables@2020-08-01' = {
  dependsOn: [
    firewall
  ]
  name: 'DefaultRouteTable'
  location: resourceGroup().location
  properties: {}
}

resource defaultRoute 'Microsoft.Network/routeTables/routes@2020-08-01' = {
  dependsOn: [
    defaultRouteTable
  ]
  name: '${defaultRouteTable.name}/DefaultRoute'
  properties: {
    addressPrefix: '0.0.0.0/0'
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: '10.0.0.4'

  }
}

module firewall 'modules/010-firewall.bicep' = {
  name: 'AzureFirewall'
  dependsOn: [
    firewallSubnet
  ]

  params: {
    prefix: prefix
    subnetId: '${vnet.id}/subnets/${firewallSubnetInfo.name}'
  }
}

module aks 'modules/040-aks-private-cluster.bicep' = {
  dependsOn: [
    defaultSubnets
  ]

  name: 'AksPrivateCluster'
  params: {
    clusterName: '${prefix}-aks-cluster'
    subnetId: '${vnet.id}/subnets/${aksSubnetInfo.name}'
    adminPublicKey: adminPublicKey
    aadTenantId: aadTenantId
    adminGroupObjectIDs: adminGroupObjectIDs
  }
}

// Outputs
output vnetId string = vnet.id
