<!-- # 🚀 Expense Application Deployment on AWS EKS with ALB TargetGroupBinding

This project demonstrates deploying a **microservices application on Amazon EKS** and exposing it to the internet using an **Application Load Balancer (ALB)** integrated with Kubernetes using **TargetGroupBinding**.

The project also implements **production-grade DevOps practices** such as:

* Kubernetes ConfigMaps
* Kubernetes Secrets
* Init Containers for database automation
* IAM Roles for Service Accounts (IRSA)
* AWS Load Balancer Controller
* RDS MySQL integration

---

# 🏗 Architecture

```
Route53
   ↓
Application Load Balancer (Terraform)
   ↓
Target Group (AWS)
   ↓
TargetGroupBinding (Kubernetes)
   ↓
Frontend Pods (Nginx)
   ↓
Backend Pods (NodeJS)
   ├── wait-for-db (init container)
   ├── init-db (schema initialization)
   └── backend container
   ↓
Amazon RDS MySQL
```

---

# ⚙️ Infrastructure Components

## AWS Infrastructure

Provisioned using **Terraform**

* VPC
* Public & Private Subnets
* Security Groups
* Application Load Balancer
* Target Group
* Route53 DNS
* RDS MySQL Database
* EKS Cluster
* Node Groups

---

# ☸ Kubernetes Components

## Backend

The backend service contains:

* ConfigMap
* Secret
* Init Containers
* Deployment
* Service

### Backend Workflow

During pod startup:

1️⃣ **wait-for-db init container**

Waits until the RDS DNS resolves.

2️⃣ **init-db init container**

Executes the schema initialization script.

3️⃣ **backend container**

Starts the NodeJS API server.

This ensures the **database schema is automatically created** during deployment.

---

# 🔐 Security Implementation

Sensitive information is handled securely.

| Component      | Purpose                     |
| -------------- | --------------------------- |
| ConfigMap      | Non-sensitive configuration |
| Secret         | Database credentials        |
| Init Container | Database schema creation    |
| IAM Role       | AWS API permissions         |

### Database Credentials

Credentials are stored in **Kubernetes Secrets** instead of hardcoding them inside application code.

---

# 🧠 Key DevOps Concepts Demonstrated

This project demonstrates several **real-world DevOps practices**.

✔ Amazon EKS Kubernetes deployment
✔ AWS Load Balancer Controller
✔ TargetGroupBinding integration
✔ IAM Roles for Service Accounts (IRSA)
✔ Kubernetes ConfigMaps and Secrets
✔ Database schema automation with init containers
✔ RDS connectivity from Kubernetes
✔ Production-ready container deployment

---

# 🚀 Deployment

Deploy backend:

```
kubectl apply -f backend.yaml
```

Deploy frontend:

```
kubectl apply -f frontend.yaml
```

Verify pods:

```
kubectl get pods -n expense
```

Verify TargetGroupBinding:

```
kubectl get targetgroupbinding -A
```

---

# 🔍 Pod Lifecycle

During deployment, the backend pod lifecycle works as follows:

```
1️⃣ wait-for-db
   waits until RDS DNS resolves

2️⃣ init-db
   executes schema.sql

3️⃣ backend container starts

4️⃣ backend connects to RDS
```

This ensures the database is **always initialized automatically**.

---

# 🧩 Troubleshooting Scenarios Solved

During this project, several real-world issues were debugged:

* AWS Load Balancer Controller IAM issues
* IRSA configuration errors
* CloudFormation stack conflicts
* TargetGroupBinding admission webhook failures
* STS AssumeRoleWithWebIdentity permission issues
* Database schema initialization failures

These troubleshooting steps reflect **real production DevOps debugging scenarios**.

---

# 📈 Production Best Practices

Possible improvements for production environments:

* GitOps deployment using ArgoCD
* CI/CD pipeline with GitHub Actions
* Secret management with AWS Secrets Manager
* Observability with Prometheus & Grafana
* Centralized logging with CloudWatch

---

# 👨‍💻 Author

**Sai Venkata Siva**

DevOps Enthusiast focused on:

* Kubernetes
* AWS
* Infrastructure as Code
* Cloud-native deployments

--- -->

# Expense Application on Amazon EKS

### End-to-End Deployment, Automation & Troubleshooting Guide

This document explains the **architecture, deployment process, problems encountered, and how they were resolved** while deploying the Expense application on **Amazon EKS with ALB + TargetGroupBinding**.

The goal of this project was to build a **production-style Kubernetes deployment with complete automation**, including database schema creation, secure credential management, and AWS load balancer integration.

This README is written in **very simple language**, so even someone new to DevOps can understand the journey.

---

# 1. Architecture Overview

The application consists of **frontend, backend, and database** components.

```
User Browser
      │
      ▼
Route53 (expense-dev.devops76.sbs)
      │
      ▼
AWS Application Load Balancer
      │
      ▼
Target Group
      │
      ▼
TargetGroupBinding (Kubernetes)
      │
      ▼
Frontend Service (Nginx)
      │
      ▼
Frontend Pods
      │
      ▼
Backend Service
      │
      ▼
Backend Pods (NodeJS API)
      │
      ▼
Amazon RDS MySQL
```

---

# 2. Technologies Used

| Component               | Technology                   |
| ----------------------- | ---------------------------- |
| Container orchestration | Kubernetes (Amazon EKS)      |
| Infrastructure          | Terraform                    |
| Load balancing          | AWS ALB                      |
| Kubernetes integration  | AWS Load Balancer Controller |
| Database                | Amazon RDS MySQL             |
| Application             | NodeJS + Nginx               |
| Config management       | ConfigMaps                   |
| Secrets management      | Kubernetes Secrets           |
| Database initialization | Init Containers              |

---

# 3. Automation Goals

The deployment was designed to ensure:

* No manual database setup
* Secure credential management
* Fully automated Kubernetes deployment
* Production-style AWS networking integration

---

# 4. Problem 1 — Database Schema Not Created

## Symptom

The backend application started successfully, but database operations failed.

Example error:

```
ERROR 1049 (42000): Unknown database 'expense'
```

This meant the **database did not exist**.

---

## Root Cause

RDS **does not automatically create databases or tables**.

The backend expected:

```
Database: expense
Table: transactions
```

But nothing existed in the database.

---

## Temporary Fix (Manual)

Initially the database was created manually:

```sql
CREATE DATABASE expense;

USE expense;

CREATE TABLE transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  amount DECIMAL(10,2),
  description VARCHAR(255)
);
```

However, this was **not ideal** because infrastructure should be fully automated.

---

## Final Solution — Init Container Automation

A **Kubernetes init container** was added to create the schema automatically before the backend starts.

```
Pod Start
   │
   ▼
Init Container
   │
   ▼
Execute schema.sql
   │
   ▼
Database + Table created
   │
   ▼
Backend container starts
```

Schema file:

```
CREATE DATABASE IF NOT EXISTS expense;

USE expense;

CREATE TABLE IF NOT EXISTS transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  amount INT,
  description VARCHAR(255)
);
```

Now every time the backend pod starts:

```
Database automatically initialized
```

No manual SQL required.

---

# 5. Problem 2 — Database Credentials Exposed

## Symptom

Initially database credentials were hardcoded in Kubernetes manifests.

Example:

```
DB_USER=expense
DB_PASSWORD=ExpenseApp1
```

This is **not secure**.

---

## Solution — Kubernetes Secrets

Credentials were moved into a Secret.

```
kubectl create secret generic db-secret \
--from-literal=DB_USER=expense \
--from-literal=DB_PASSWORD=ExpenseApp1 \
-n expense
```

Then injected into pods as environment variables.

```
env:
- name: DB_USER
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: DB_USER
```

Benefits:

* Sensitive data not visible in manifests
* Secure configuration management

---

# 6. Problem 3 — TargetGroupBinding Not Working

This was the **most complex issue in the project**.

## Symptom

Frontend deployment failed with error:

```
admission webhook "mtargetgroupbinding.elbv2.k8s.aws" denied the request
AccessDenied: sts:AssumeRoleWithWebIdentity
```

---

## Root Cause

The **AWS Load Balancer Controller did not have IAM permissions** to access AWS APIs.

Required components were missing:

* IAM Role
* Trust Policy
* OIDC provider
* Service Account binding

---

# 7. Fix — IAM Roles for Service Accounts (IRSA)

To allow Kubernetes pods to access AWS APIs securely, **IRSA** was configured.

---

## Step 1 — Associate OIDC Provider

```
eksctl utils associate-iam-oidc-provider \
--cluster expense-dev \
--approve
```

This allows Kubernetes service accounts to assume IAM roles.

---

## Step 2 — Create IAM Policy

```
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```

```
aws iam create-policy \
--policy-name AWSLoadBalancerControllerIAMPolicy \
--policy-document file://iam_policy.json
```

---

## Step 3 — Create Service Account with IAM Role

```
eksctl create iamserviceaccount \
--cluster expense-dev \
--namespace kube-system \
--name aws-load-balancer-controller \
--attach-policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--approve
```

This links:

```
Kubernetes Service Account
        │
        ▼
IAM Role
        │
        ▼
AWS Permissions
```

---

# 8. Problem 4 — Helm Installation Issues

Initially the controller was installed using:

```
helm install
```

But during redeployments it caused errors.

---

## Solution — Helm Upgrade

Instead of deleting and reinstalling:

```
helm upgrade --install aws-load-balancer-controller
```

Benefits:

* Idempotent
* Safe redeployment
* Production best practice

---

# 9. Problem 5 — Target Group Not Found

Error:

```
TargetGroupNotFound
```

Cause:

Terraform recreated the ALB, generating a **new target group ARN**.

Solution:

Update the ARN inside the Kubernetes manifest.

```
targetGroupARN: arn:aws:elasticloadbalancing:...
```

---

# 10. Problem 6 — API Endpoint Mismatch

## Symptom

Browser requests failed with:

```
504 Gateway Timeout
```

Backend returned:

```
Cannot GET /api/transaction
```

---

## Root Cause

Frontend was calling:

```
/api/transaction
```

But backend API was:

```
/transaction
```

---

## Solution — Nginx Reverse Proxy Rewrite

Nginx configuration was updated.

```
location /api/ {
  proxy_pass http://backend:8080/;
}
```

Now nginx translates:

```
/api/transaction
      │
      ▼
/transaction
```

Backend receives correct request.

---

# 11. Troubleshooting Commands Used

## Check pods

```
kubectl get pods -n expense
```

## Check service endpoints

```
kubectl get endpoints backend -n expense
```

## Test backend connectivity

```
kubectl exec -it deployment/frontend -n expense -- sh
curl http://backend:8080/transaction
```

## Check logs

```
kubectl logs deployment/backend -n expense
```

## Check TargetGroupBinding

```
kubectl get targetgroupbinding -A
```

## Verify controller

```
kubectl get pods -n kube-system
```

---

# 12. Key DevOps Lessons Learned

### 1. Infrastructure takes time to stabilize

Kubernetes + ALB health checks may take **30-60 seconds** before traffic works.

---

### 2. Always debug layer by layer

```
Browser
↓
Load Balancer
↓
Frontend
↓
Backend
↓
Database
```

---

### 3. Use automation whenever possible

Manual steps should always be replaced by:

* Init containers
* Terraform
* Kubernetes manifests

---

### 4. Secure credentials

Never store passwords in manifests.

Always use:

```
Kubernetes Secrets
```

---

# 13. Final Outcome

After resolving all issues:

* Fully automated deployment
* Secure credential management
* Automated database schema initialization
* Proper AWS load balancer integration
* Production-style Kubernetes architecture

The system now works reliably with:

```
kubectl apply -f backend/
kubectl apply -f frontend/
```

No manual database setup required.

---

# 14. Future Improvements

Potential enhancements:

* CI/CD pipeline (GitHub Actions)
* GitOps deployment (ArgoCD)
* Monitoring with Prometheus + Grafana
* Logging with CloudWatch
* Terraform output automation for TargetGroup ARN

---

# Conclusion

This project demonstrates a **complete DevOps deployment pipeline on Amazon EKS**, including real-world troubleshooting of:

* IAM roles and trust policies
* AWS Load Balancer Controller
* TargetGroupBinding
* Database automation
* Reverse proxy configuration
* Kubernetes networking

The experience gained from debugging and fixing these issues closely reflects **real production DevOps operations**.
