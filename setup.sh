# #!bin/bash

# aws eks update-kubeconfig --name expense-dev --region us-east-1


# # IAM Permissions
# eksctl utils associate-iam-oidc-provider \
#     --region us-east-1 \
#     --cluster expense-dev \
#     --approve

# curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.2/docs/install/iam_policy.json

# aws iam create-policy \
#     --policy-name AWSLoadBalancerControllerIAMPolicy \
#     --policy-document file://iam-policy.json

# eksctl create iamserviceaccount \
# --cluster=expense-dev \
# --namespace=kube-system \
# --name=aws-load-balancer-controller \
# --attach-policy-arn=arn:aws:iam::210749645231:policy/AWSLoadBalancerControllerIAMPolicy \
# --override-existing-serviceaccounts \
# --approve

# curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.2/docs/install/iam_policy.json

# # Add Controller to Cluster
# helm repo add eks https://aws.github.io/eks-charts

# kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

# get_vpc_id
# aws eks describe-cluster \
#   --name expense-dev \
#   --query "cluster.resourcesVpcConfig.vpcId" \
#   --output text

# helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=expense-dev --set region=us-east-1 --set region=us-east-1 --set vpcId=


#!/bin/bash

set -e

aws eks update-kubeconfig --name expense-dev --region us-east-1

echo "updating kube-config..."

CLUSTER_NAME=expense-dev
REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "Associating OIDC Provider..."

eksctl utils associate-iam-oidc-provider \
--cluster $CLUSTER_NAME \
--region $REGION \
--approve

echo "Downloading IAM policy..."

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

echo "Creating IAM policy..."

aws iam create-policy \
--policy-name AWSLoadBalancerControllerIAMPolicy \
--policy-document file://iam_policy.json || true

echo "Deleting old IAM ServiceAccount if exists..."

eksctl delete iamserviceaccount \
--cluster $CLUSTER_NAME \
--namespace kube-system \
--name aws-load-balancer-controller \
--region $REGION || true

echo "Creating IAM ServiceAccount..."

eksctl create iamserviceaccount \
--cluster $CLUSTER_NAME \
--namespace kube-system \
--name aws-load-balancer-controller \
--attach-policy-arn arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
--approve \
--region $REGION

echo "Installing AWS Load Balancer Controller..."

helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm uninstall aws-load-balancer-controller -n kube-system || true

VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.vpcId" --output text)

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
-n kube-system \
--set clusterName=$CLUSTER_NAME \
--set region=$REGION \
--set serviceAccount.create=false \
--set serviceAccount.name=aws-load-balancer-controller \
--set vpcId=$VPC_ID

echo "Creating namespace..."

kubectl create namespace expense || true

echo "Waiting for controller to start..."

sleep 10

echo "Checking AWS Load Balancer Controller status..."

kubectl get deployment aws-load-balancer-controller -n kube-system

echo ""

echo "Controller Pods:"

kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

echo ""

echo "Setup Completed Successfully!"

echo ""

echo "Next Steps:"

echo "1) Deploy Backend:"

echo "   kubectl apply -f backend/manifest.yaml"

echo ""

echo "2) Deploy Frontend:"

echo "   kubectl apply -f frontend/manifest.yaml"