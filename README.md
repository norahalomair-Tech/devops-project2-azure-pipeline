# Burger Builder – Azure DevOps Project by Norah

This project automates the **provisioning, deployment, and monitoring** of a secure three-tier web application on **Microsoft Azure** using **Terraform**, **Docker**, and **GitHub Actions**.

---

##  Project Overview

The solution provisions a complete **frontend–backend–database** stack inside a private Azure network.  
Automation ensures that every resource is created, configured, and deployed consistently with full CI/CD integration.

<p align="center">
  <img width="972" height="542" alt="image" src="https://github.com/user-attachments/assets/65aac071-1171-44fa-ac10-d5298f3c3845" />
>
</p>

---

## Infrastructure Components

| Layer | Description |
|-------|--------------|
| **Networking** | Resource Group, Virtual Network, Subnets, and NSGs for isolation and control |
| **Compute** | Azure App Services for frontend and backend, each running Docker containers |
| **Gateway** | Application Gateway (WAF v2) for routing, SSL termination, and health probes |
| **Database** | Azure SQL Database with Private Endpoint access only |
| **Monitoring** | Log Analytics & Application Insights for centralized observability |
| **Alerts** | Configured for CPU, DTU usage, and backend health; notifications via Action Groups |

---

##  CI/CD Automation

GitHub Actions automate build and deployment across all layers:

| Workflow | Purpose | Key Secrets |
|-----------|----------|--------------|
| `infra.yml` | Runs Terraform to provision infrastructure | `AZURE_CREDENTIALS`, `SQL_ADMIN_PASSWORD` |
| `backend.yml` | Builds and pushes backend (Spring Boot + Maven) Docker image | `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` |
| `frontend.yml` | Builds and pushes frontend (React + Vite) Docker image with App Gateway URL | `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` |

The build pipelines automatically:
- Package and push container images to Docker Hub
- Inject environment variables such as the App Gateway public IP
- Deploy new versions directly to Azure App Services

---

##  Prerequisites

Before deploying, ensure you have:

- Active **Azure Subscription** with Contributor permissions.
- **Azure CLI** installed and authenticated (`az login`).
- **Service Principal** credentials added to GitHub Secrets:
  - `AZURE_CREDENTIALS`
  - `DOCKERHUB_USERNAME` / `DOCKERHUB_TOKEN`
  - `SQL_ADMIN_PASSWORD`



##  Infrastructure as Code (Terraform)

All infrastructure code is inside the `TFmain/` directory
You can deploy locally or automatically via the GitHub Actions workflow

```bash
cd TFmain
terraform init
terraform plan
terraform apply -auto-approve```
---
## How to Validate the Deployment

After the GitHub Actions workflows complete successfully:

1. Get the Application Gateway IP

From Terraform output (app_gateway_public_ip) or Azure Portal → Application Gateway → public IP

2. Test Frontend Access

Open the frontend in your browser:

``http://<App-Gateway-IP>/``

Expected: The Burger Builder UI should load correctly.

3. Test Backend API Health

``http://<App-Gateway-IP>/api/health``

Expected response:

``{
  "status": "UP"
}``
----
## Application Logs and Monitoring
In Azure Portal:

Application Gateway → Backend Health → Ensure all backends are healthy

Application Insights → Logs → View live metrics, requests, and failures

### Monitor → Alerts → Verify configured alerts:

App Service CPU > 70%

SQL DTU/CPU > 80%

Application Gateway backend health < 100%
-------
 ## Troubleshooting
If the backend probe fails:

Verify backend port (should be 443 or 8080 depending on app settings)

Ensure App Service access is restricted to Application Gateway subnet only

Review probe path /api/health configuration
-------
When finished, destroy the environment to avoid Azure charges:

cd TFmain``
terraform destroy -auto-approve``
