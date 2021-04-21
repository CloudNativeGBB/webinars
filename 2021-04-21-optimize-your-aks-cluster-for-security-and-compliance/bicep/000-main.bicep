param prefix string
param suffix string
param vnetPrefix string = '10.0.0.0/16'
param k8sVersion string = '1.18.14'
param adminUsername string = 'azureuser'
param adminPublicKey string
param adminGroupObjectIDs array = []
param acrRole string

var azureFirewallSubnetInfo = {
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
  azureFirewallSubnetInfo
  aksSubnetInfo
  jumpboxSubnetInfo
]

var applicationRuleCollections = [
  {
    name: 'aksFirewallRules'
    properties: {
      priority: 100
      action: {
        type: 'allow'
      }
      rules: [
        {
          name: 'aksFirewallRules'
          description: 'Rules needed for AKS to operate'
          sourceAddresses: [
            aksSubnetInfo.properties.addressPrefix
          ]
          protocols: [
            {
              protocolType: 'Https'
              port: 443
            }
            {
              protocolType: 'Http'
              port: 80
            }
          ]
          targetFqdns: [
            '*.hcp.${resourceGroup().location}.azmk8s.io'
            'mcr.microsoft.com'
            '*.cdn.mcr.io'
            '*.data.mcr.microsoft.com'
            'management.azure.com'
            'login.microsoftonline.com'
            'dc.services.visualstudio.com'
            '*.ods.opinsights.azure.com'
            '*.oms.opinsights.azure.com'
            '*.monitoring.azure.com'
            'packages.microsoft.com'
            'acs-mirror.azureedge.net'
            'azure.archive.ubuntu.com'
            'security.ubuntu.com'
            'changelogs.ubuntu.com'
            'launchpad.net'
            'ppa.launchpad.net'
            'keyserver.ubuntu.com'
          ]
        }
      ]
    }
  }
]

var natRuleCollections = []

var networkRuleCollections = [
  {
    name: 'ntpRule'
    properties: {
      priority: 100
      action: {
        type: 'allow'
      }
      rules: [
        {
          name: 'ntpRule'
          description: 'Allow Ubuntu NTP for AKS'
          protocols: [
            'UDP'
          ]
          sourceAddresses: [
            aksSubnetInfo.properties.addressPrefix
          ]
          destinationAddresses: [
            '*'
          ]
          destinationPorts: [
            '123'
          ]
        }
      ]
    }
  }
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

resource defaultRouteTable 'Microsoft.Network/routeTables@2020-07-01' = {
  name: 'defaultRouteTable'
  location: resourceGroup().location
  tags: {}
  properties: {
    routes: [
      {
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.0.0.4' // hard coding the FW IP address as the azureFirewalls.hubIPAddresses.privateIPAddress does not seem to work as expected at this time on a single FW
        }
        name: 'defaultRoute'
      }
    ]
    disableBgpRoutePropagation: true
  }
}

resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  name: '${vnet.name}/${aksSubnetInfo.name}'
  properties: union(aksSubnetInfo.properties, {
    routeTable: {
      id: defaultRouteTable.id
    }
  })
}

module firewall 'modules/020-azure-firewall.bicep' = {
  name: 'AzureFirewall'

  params: {
    prefix: prefix
    suffix: suffix
    subnetId: '${vnet.id}/subnets/${azureFirewallSubnetInfo.name}'
    applicationRuleCollections: applicationRuleCollections
    natRuleCollections: natRuleCollections
    networkRuleCollections: networkRuleCollections
  }
}

module aks 'modules/040-aks-cluster.bicep' = {
  name: 'AksCluster'
  
  dependsOn: [
    firewall
    aksSubnet
    defaultRouteTable
  ]

  params: {
    prefix: prefix
    suffix: suffix
    subnetId: aksSubnet.id
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
      loadBalancerSku: 'standard'
      sku_tier: 'Paid'				
      enableRBAC: true 
      aadProfileManaged: true
      adminGroupObjectIDs: adminGroupObjectIDs 
      
      outboundType: 'userDefinedRouting'
      enablePrivateCluster: true
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

module jumpbox 'modules/030-jumpbox.bicep' = {
  name: 'jumpbox'
  params: {
    prefix: prefix
    suffix: suffix
    subnetId: '${vnet.id}/subnets/${jumpboxSubnetInfo.name}'
    adminUsername: adminUsername
    adminSshKey: adminPublicKey
  }
}

output jumpboxFqdn string = jumpbox.outputs.fqdn
