#!/usr/bin/env bash

# https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html
# Check for an existing node role or create a new one.
# For that, follow the steps in the link or executing this script

# Create the IAM role
aws iam create-role \
      --role-name AmazonEKSNodeRole \
      --assume-role-policy-document file://"eks-node-role-trust-policy.json"

# Attach two required IAM managed policies to the IAM role.
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy \
  --role-name AmazonEKSNodeRole
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly \
  --role-name AmazonEKSNodeRole
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
  --role-name AmazonEKSNodeRole