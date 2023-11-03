#!/usr/bin/env bash

# https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
# Check for an existing cluster role or create a new one.
# For that, follow the steps in the link or executing this script

# Create the IAM role
aws iam create-role \
  --role-name AmazonEKSClusterRole \
  --assume-role-policy-document file://"eks-cluster-role-trust-policy.json"

# Attach two required IAM managed policies to the IAM role.
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
  --role-name AmazonEKSClusterRole
