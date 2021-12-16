#!/bin/bash
# This script will run an ARM template deployment to deploy all the
# required resources into Azure.
# Azure CLI (log in)

# Get outputs of Azure Deployment
function getOutput {
   echo $(az deployment sub show --name $rgName --query "properties.outputs.$1.value" --output tsv)
}

# Get the IP address of specified Kubernetes service
function getIp {
   kubectl get services $1 --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
}

# Get RG name, location, and App Name
source env.sh

# Deploy the infrastructure
az deployment sub create --name $rgName \
   --location $location \
   --template-file ./main.bicep \
   --parameters rgName=$rgName \
   --parameters location=$location \
   --parameters name=$name \
   --parameters databasePassword=$administratorPassword \
   --output none

# Get outputs
# ghostFQDN=$(getOutput 'ghostFQDN')
# frontDoor=$(getOutput 'frontdoorFQDN')

# printf "\nYour app is accessible from https://%s\n" $frontDoor
