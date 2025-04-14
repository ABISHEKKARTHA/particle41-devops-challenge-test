# SimpleTimeService - Particle41 DevOps Challenge

## 📌 Project Overview
A minimal Python-based web service that returns the current timestamp and the client IP in JSON format. This project is containerized using Docker and deployed to Azure using Terraform as part of the DevOps Engineer coding challenge.

---

## 🛠 Tech Stack
- Python (Flask)
- Docker
- Azure (Container Apps, Application Gateway)
- Terraform (IaC)
- GitHub Actions (CI/CD)

---

## 📁 Repository Structure
```
.
├── app/                # SimpleTimeService application code
│   ├── main.py         # Flask app
│   └── Dockerfile      # Container definition
├── terraform/          # Terraform code to provision Azure infrastructure
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── .github/workflows/  # CI/CD pipeline configuration
│   └── ci-cd.yml
└── README.md           # This documentation
```

---

## ✅ Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Python 3.9+](https://www.python.org/downloads/) *(for local testing only)*

---

## 🚀 Application: SimpleTimeService

### 📦 Build Docker Image
```bash
cd app

docker build -t abishekkartha/simpletimeservice:latest .
```

### ▶️ Run Docker Container
```bash
docker run -p 5000:5000 abishekkartha/simpletimeservice:latest
```

### 🌐 Access
Visit: `http://localhost:5000` or the url that populates if being run on docker desktop

Expected JSON response:
```json
{
  "timestamp": "2025-04-15T10:30:00",
  "ip": "127.0.0.1"
}
```

---

## 🌩 Infrastructure: Azure with Terraform

### 📁 Navigate to terraform directory
```bash
cd terraform
```

### 🔐 Authenticate with Azure
```bash
az login
```

### ⚙️ Initialize Terraform
```bash
terraform init
```

### 📄 Review Plan
```bash
terraform plan
```

### 🚀 Apply Deployment
```bash
terraform apply -auto-approve
```

> 📎 NOTE: Infrastructure includes:
> - Azure Resource Group
> - Azure Container App (pulls image from Docker Hub)
> - Azure Application Gateway (public access)

---

## 🔁 CI/CD (Optional but Recommended)

### GitHub Actions
The workflow file is located at `.github/workflows/ci-cd.yml`.

You need to configure the following secrets in GitHub:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `AZURE_CREDENTIALS` *(from `az ad sp create-for-rbac` JSON output)*

### CI/CD Workflow Includes:
- Build and push Docker image to Docker Hub
- Terraform deployment to Azure *(manual approval step)*

---

## 🔒 Security Notes
- The Docker container runs as a non-root user.
- No secrets or credentials are pushed to the public repository.
- Azure credentials should be stored in GitHub Secrets only.

---

## 📬 Questions?
If any issues arise during deployment, feel free to raise an issue on this repository.

---

## 📎 Useful Links
- [Docker Hub: abishekkartha/simpletimeservice](https://hub.docker.com/r/abishekkartha/simpletimeservice)
- [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/overview)

