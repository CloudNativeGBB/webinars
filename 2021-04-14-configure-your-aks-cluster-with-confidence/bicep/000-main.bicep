param prefix string
param suffix string
param vnetPrefix string
param k8sVersion string = '1.18.14'
param adminUsername string = 'azueruser'
param adminPublicKey string
param aadTenantId string = subscription().tenantId
param adminGroupObjectIDs array = []
param acrRole string

var aksSubnetInfo = {
  name: 'AksSubnet'
  properties: {
    addressPrefix: '10.0.4.0/22'
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

var allSubnets = [
  aksSubnetInfo
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
    prefix: prefix
    suffix: suffix
    subnetId: '${vnet.id}/subnets/${aksSubnetInfo.name}'
    
    adminPublicKey: adminPublicKey
    adminGroupObjectIDs: adminGroupObjectIDs
    
    userNodePools: [
      {
        name: 'usernp01'
        count: 2
        vmSize: 'Standard_D4s_v3'
        osDiskSizeGB: 100
        osDiskType: 'Ephemeral'
        maxPods: 30
        maxCount: 6
        minCount: 2
        enableAutoScaling: true
        mode: 'User'
        orchestratorVersion: k8sVersion
        maxSurge: null
        tags: {}
        nodeLabels: {}
        taints: []
      }
    ]
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
