#!/bin/bash

subscriptionId=$(az account show --query id | tr -d '"')
aksadminrole_with_id=${aksadminrole//\$\{subscriptionId\}/$subscriptionId}

#tenantId=$(az account show --query tenantId)

FS='' export subscriptionId && read -r -d '' aksadminrole <<"EOF"
{
  "Name": "AKS Admin",
  "Description": "Perform AKS cluster create/read/update/delete actions",
  "Actions": [
    "*"
  ],
  "NotActions": [
    "Microsoft.Billing/*",
    "Microsoft.Authorization/elevateAccess/Action",
    "Microsoft.Blueprint/blueprintAssignments/write",
    "Microsoft.Blueprint/blueprintAssignments/delete"
  ],
  "AssignableScopes": [
    "/subscriptions/${subscriptionId}"
  ]
}
EOF

aksadminrole_with_id=${aksadminrole//\$\{subscriptionId\}/$subscriptionId}
echo "$aksadminrole_with_id"

az role definition create --verbose --role-definition "$aksadminrole_with_id"
az ad sp create-for-rbac --name "AKSAdminSP" --role "AKS Admin"
