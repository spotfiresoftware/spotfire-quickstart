#!/bin/bash

# Note: You might need to activate PIM role for your Azure AD group to be able to reset credentials for the Service Principal
# https://portal.azure.com/?feature.msaljs=true#view/Microsoft_Azure_PIMCommon/ActivationMenuBlade/~/aadgroup/provider/aadgroup

# This script retrieves the credentials for an existing Azure Service Principal
# and outputs the necessary environment variable exports for Ansible or Terraform use.
# https://docs.ansible.com/projects/ansible/5/scenario_guides/guide_azure.html
# https://learn.microsoft.com/en-us/azure/developer/ansible/install-on-linux-vm?tabs=azure-cli
# On the host virtual machine, export the service principal values to configure your Ansible credentials.
# export AZURE_SUBSCRIPTION_ID=<subscription_id>
# export AZURE_CLIENT_ID=<service_principal_app_id>
# export AZURE_SECRET=<service_principal_password>
# export AZURE_TENANT=<service_principal_tenant_id>

# Replace this with the display name of your existing Service Principal
#PRINCIPAL_NAME="<your_existing_service_principal_name>"
PRINCIPAL_NAME="AKSAdminSP"

# Retrieve the App ID (Client ID) and Tenant ID of the existing SP
SP_METADATA=$(az ad sp list --display-name "$PRINCIPAL_NAME" --query "[0].{AppId:appId, TenantId:appOwnerOrganizationId}" --output json)

AZURE_CLIENT_ID=$(echo "$SP_METADATA" | jq -r '.AppId')
AZURE_TENANT=$(echo "$SP_METADATA" | jq -r '.TenantId')


APP_ID=$AZURE_CLIENT_ID
AZURE_CREDS=$(az ad sp credential reset --id $APP_ID --output json)

# Export environment variables for Ansible or Terraform use:
echo "export AZURE_CLIENT_ID=$AZURE_CLIENT_ID"
echo "export AZURE_SUBSCRIPTION_ID=$(az account show --query 'id' --output tsv)"
echo "export AZURE_TENANT=$(az account show --query 'tenantId' --output tsv)"

#echo "export AZURE_AD_USER=$(az account show --query 'user.name' --output tsv)"
#echo "export AZURE_PASSWORD=<your_password>"
#echo "export AZURE_ACCESS_TOKEN=$(az account get-access-token --query 'accessToken' --output tsv)"

echo "export AZURE_SECRET=$(echo "$AZURE_CREDS" | jq -r '.password')"

# Create Azure credentials file for Ansible or Terraform use:
export CONFIG_FILE=~/.azure/credentials
cat << EOF > $CONFIG_FILE
[default]
subscription_id=$AZURE_SUBSCRIPTION_ID
client_id=$AZURE_CLIENT_ID
tenant=$AZURE_TENANT
secret=$AZURE_SECRET
EOF

# Also show Terraform style environment variables:
#echo "export ARM_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID"
#echo "export ARM_TENANT=$AZURE_TENANT"
#echo "export ARM_CLIENT_ID=$AZURE_CLIENT_ID"
#echo "export ARM_CLIENT_SECRET=$AZURE_SECRET"