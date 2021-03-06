#! /bin/bash

export RESOURCE_GROUP_NAME=""
export CLUSTER_NAME=""
export KUBERNETES_VERSION=""
export NODE_POOL_NAME=""

## Check cluster upgrade candidates
az aks get-upgrades --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --output table

## Full cluster upgrade
## https://docs.microsoft.com/en-us/azure/aks/upgrade-cluster#upgrade-an-aks-cluster
az aks upgrade \
	--resource-group $RESOURCE_GROUP_NAME \
	--name $CLUSTER_NAME \
	--kubernetes-version $KUBERNETES_VERSION

## Upgrade control plane only
az aks upgrade \
	--resource-group $RESOURCE_GROUP_NAME \
	--name $CLUSTER_NAME \
	--kubernetes-version $KUBERNETES_VERSION \
	--control-plane-only

## Upgrade all node pools images only (does not upgrade k8s version)
## https://docs.microsoft.com/en-us/azure/aks/node-image-upgrade#upgrade-all-nodes-in-all-node-pools
az aks upgrade \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $CLUSTER_NAME \
    --node-image-only

## Upgrade specific node pools only
## Node pool K8s version updates
## Upgrade node pool k8s version only
az aks nodepool upgrade \
    --resource-group $RESOURCE_GROUP_NAME \
    --cluster-name $CLUSTER_NAME \
    --name $NODE_POOL_NAME \
    --kubernetes-version $KUBERNETES_VERSION

## IMAGE UPGRADES
## Check node pool image upgrade candidates
az aks nodepool get-upgrades \
    --nodepool-name $NODE_POOL_NAME \
    --cluster-name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP_NAME

## Check/verify your node pool image version
az aks nodepool show \
    --resource-group $RESOURCE_GROUP_NAME \
    --cluster-name $CLUSTER_NAME \
    --name $NODE_POOL_NAME \
    --query nodeImageVersion

## Apply upgrade
## https://docs.microsoft.com/en-us/azure/aks/node-image-upgrade#upgrade-a-specific-node-pool
az aks nodepool upgrade \
    --resource-group $RESOURCE_GROUP_NAME \
    --cluster-name $CLUSTER_NAME \
    --name $NODE_POOL_NAME \
#   --max-surge 33% \
    --node-image-only