param prefix string
param suffix string
param vnetPrefix string
param adminUsername string = 'azueruser'
param adminPublicKey string
param aadTenantId string = subscription().tenantId
param adminGroupObjectIDs array = []
param acrRole string

var firewallSubnetInfo = {
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefix: '10.0.0.0/26'
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
  aksSubnetInfo
  jumpboxSubnetInfo
]

resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: '${prefix}-${suffix}-vnet'
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

module aks 'modules/040-aks-cluster.bicep' = {
  name: 'AksCluster'
  params: {
    clusterName: '${prefix}-${suffix}-aks'
    subnetId: '${vnet.id}/subnets/${aksSubnetInfo.name}'
    adminPublicKey: adminPublicKey
    aadTenantId: aadTenantId
    adminGroupObjectIDs: adminGroupObjectIDs
  }
}

// ACR ARM Template: https://docs.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries?tabs=json#QuarantinePolicy
resource acr 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: '${prefix}${suffix}'
  location: resourceGroup().location
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: false // disable username/password auth

  }
}

// Role Assignments ARM Template: https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2020-04-01-preview/roleassignments?tabs=json#RoleAssignmentProperties
// ACR Permissions: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-roles
resource aksAcrPermissions 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id)
  scope: acr
  properties: {
    principalId: aks.outputs.identity
    roleDefinitionId: acrRole
  }
}
