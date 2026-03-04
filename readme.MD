# 🚀 Expense Application Deployment on AWS EKS with ALB TargetGroupBinding

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
