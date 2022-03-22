#!/bin/bash

AKS_RESOURCE_GROUP="terraform-resources-rg"
AKS_CLUSTER_NAME="AKS-Test-Cluster"
ACR_RESOURCE_GROUP="terraform-resources-rg"
ACR_NAME="ACR-Repository"

# Get the id of the service principal configured for AKS
# CLIENT_ID=$(az aks show --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --query "servicePrincipalProfile.clientId" --output tsv)

# Get the ACR registry resource id
# ACR_ID=$(az acr show --name $ACR_NAME --resource-group $ACR_RESOURCE_GROUP --query "id" --output tsv)

# Create role assignment
az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID



version=$(az aks get-versions -l <region> --query 'orchestrators[-1].orchestratorVersion' -o tsv)

az group create --name akshandsonlab --location <region>

az aks create --resource-group "kube-resources-uks" --name "AKS-Test-Cluster" --enable-addons monitoring,http_application_routing --kubernetes-version 1.23.3 --generate-ssh-keys ./ --location "ukwest"

az acr create --resource-group "kube-resources-uks" --name "domACRrepo" --sku Standard --location "ukwest"

az aks update -n "AKS-Test-Cluster" -g "kube-resources-uks" --attach-acr "domACRrepo"

az sql server create -l "ukwest" -g "kube-resources-uks" -n dom-kube-sql -u sqladmin -p P2ssw0rd1234

az sql db create -g "kube-resources-uks" -s "dom-kube-sql" -n "sample-db" --service-objective S0

# SSH key files '/home/domaddams/.ssh/id_rsa' and '/home/domaddams/.ssh/id_rsa.pub' have been generated under ~/.ssh to allow SSH access to the VM.
# dom-kube-sql.database.windows.net // domacrrepo.azurecr.io // 
# https://docs.microsoft.com/en-us/azure/devops/pipelines/licensing/concurrent-jobs?view=azure-devops&tabs=ms-hosted