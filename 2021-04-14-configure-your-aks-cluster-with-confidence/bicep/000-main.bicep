param prefix string
param suffix string
param vnetPrefix string = '10.0.0.0/16'
param k8sVersion string = '1.18.14'
param adminUsername string = 'azureuser'
param adminPublicKey string
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

    aksSettings: {
      clusterName: '${prefix}-${suffix}-aks'
      identity: 'SystemAssigned'
      kubernetesVersion: k8sVersion
      networkPlugin: 'azure'
      networkPolicy: 'calico'
      serviceCidr: '172.16.0.0/22' // Must be cidr not in use any where else across the Network (Azure or Peered/On-Prem).  Can safely be used in multiple clusters - presuming this range is not broadcast/advertised in route tables.
      dnsServiceIP: '172.16.0.10' // Ip Address for K8s DNS
      dockerBridgeCidr: '172.16.4.1/22' // Used for the default docker0 bridge network that is required when using Docker as the Container Runtime.  Not used by AKS or Docker and is only cluster-routable.  Cluster IP based addresses are allocated from this range.  Can be safely reused in multiple clusters.
      outboundType: 'loadBalancer'
      loadBalancerSku: 'standard'
      sku_tier: 'Paid'				
      enableRBAC: true 
      aadProfileManaged: true
      adminGroupObjectIDs: adminGroupObjectIDs 
    }

    defaultNodePool: {
      name: 'systempool01'
      count: 3
      vmSize: 'Standard_D2s_v3'
      osDiskSizeGB: 50
      osDiskType: 'Ephemeral'
      vnetSubnetID: '${vnet.id}/subnets/${aksSubnetInfo.name}'
      osType: 'Linux'
      maxCount: 6
      minCount: 2
      enableAutoScaling: true
      type: 'VirtualMachineScaleSets'
      mode: 'System' // setting this to system type for just k8s system services
      nodeTaints: [
        'CriticalAddonsOnly=true:NoSchedule' // adding to ensure that only k8s system services run on these nodes
      ]
    }
    
    userNodePools: [
      {
        name: 'usernp01'
        count: 2
        vmSize: 'Standard_D4s_v3'
        osDiskSizeGB: 100
        osDiskType: 'Ephemeral'
        vnetSubnetID: '${vnet.id}/subnets/${aksSubnetInfo.name}'
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
    adminUserEnabled: true // disable username/password auth
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
