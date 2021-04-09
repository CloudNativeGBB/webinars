param clusterName string
param subnetId string
param adminUsername string = 'azueruser'
param adminPublicKey string
param aadTenantId string
param adminGroupObjectIDs array

// https://docs.microsoft.com/en-us/azure/templates/microsoft.containerservice/managedclusters?tabs=json#ManagedClusterAgentPoolProfile

resource aks 'Microsoft.ContainerService/managedClusters@2021-02-01' = {
  name: 'AksPrivateCluster'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.19.7'
    dnsPrefix: clusterName
    linuxProfile: {
      adminUsername: adminUsername
      ssh: {
        publicKeys: [
          {
            keyData: adminPublicKey
          }
        ]
      }
    }
    
    addonProfiles: {}
    
    enableRBAC: true

    enablePodSecurityPolicy: false // setting to false since PSPs will be deprecated in favour of Gatekeeper/OPA

    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'calico'
      serviceCidr: '172.16.0.0/22' // Must be cidr not in use any where else across the Network (Azure or Peered/On-Prem).  Can safely be used in multiple clusters - presuming this range is not broadcast/advertised in route tables.
      dnsServiceIP: '172.16.0.10' // Ip Address for K8s DNS
      dockerBridgeCidr: '172.16.4.1/22' // Used for the default docker0 bridge network that is required when using Docker as the Container Runtime.  Not used by AKS or Docker and is only cluster-routable.  Cluster IP based addresses are allocated from this range.  Can be safely reused in multiple clusters.
      outboundType: 'userDefinedRouting'
      loadBalancerSku: 'standard'
      // networkMode: 'transparent' // defaults to transparent
      // podCidr: '' // used when networkPlugin is set to kubenet
      // loadBalancerProfile: {} // Profile for when outboundType: 'loadBalancer' - can config multiple pip etc. for cluster LB
    }

    aadProfile: {
      managed: true
      enableAzureRBAC: true
      tenantID: aadTenantId
      adminGroupObjectIDs: adminGroupObjectIDs
    }

    autoUpgradeProfile: {}

    apiServerAccessProfile: {
      enablePrivateCluster: false // we're not deploying a private cluster in this webinar
      // privateDNSZone: 'some.customdomain.com' // allows you to BYO DNS
      // authorizedIPRanges: [] // we are not whitelisting IP ranges to communicate with the API server
    }
    
    agentPoolProfiles: [
      {
        name: 'systempool01'
        count: 3
        vmSize: 'Standard_D2s_v3'
        osDiskSizeGB: 50
        osDiskType: 'Ephemeral'
        vnetSubnetID: subnetId
        osType: 'Linux'
        maxCount: 6
        minCount: 2
        enableAutoScaling: true
        mode: 'System' // setting this to system type for just k8s system services
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule' // adding to ensure that only k8s system services run on these nodes
        ]
        //
        // kubeletDiskType: 'Temporary' //In the future you can allow kubelet to write to temp disk
        // maxPods: 30 // Default is 30 per node
        //
        //
        // enableAutoScaling: false // we will not need auto scaling for this demo on systemNodePool
        // type: 'VirtualMachineScaleSets' // default is VMSS
        // orchestratorVersion: // Leave this empty and follow whatever the cluster is
        // upgradeSettings: {
          //   maxSurge: '20%'
        // }
        // availabilityZones: [
        //   '1'
        //   '2'
        //   '3'
        // ]
        // enableNodePublicIP: false // Ability to directly assign Public IP address to each node
        // nodePublicIPPrefixID: // What Public IP Prefix "pool" should we allocate Node Public IPs from
        // scaleSetPriority: 'Regular' // Weather to set spot vms/pricing to this nodepool
        // scaleSetEvictionPolicy: 'Delete' // Spot instance eviction policy Delete or Deallocate
        // spotMaxPrice: // Spot VM pricing
        // tags: {} // Tags to add to the underlying Azure VMSS resources
        // nodeLabels: {} // K8s Labels to apply to all nodes in pool
        // 
        // proximityPlacementGroupID: // Provision 
        // kubeletConfig: {
        // }
        // linuxOSConfig: {}
      }
    ]
    // Optional Configs/Out of scope for Webinar
    // 
    // windowsProfile: {}
    // servicePrincipalProfile: {} 
    // podIdentityProfile: {} not using pod identity for this webinar(1)
    
    // diskEncryptionSetID: {} // we are not using host disk encryption
    //
    // identityProfile: {
    //   kubeletidentity: {
    //     clientId: '00000000000000000000000000000000'
    //     objectId: '00000000000000000000000000000000'
    //     resourceId: '/subscriptions/00000000000000000000000/resourcegroups/MC_xxxxxxxx_westeurope/providers/Microsoft.ManagedIdentity/userAssignedIdentities/xxxxxx-agentpool'
    //   }
    // } // Used for setting the KubeletIdenttiy
  }
}
