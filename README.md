# Burger Builder DevOps Runbook

This repository contains everything you need to provision, deploy, and validate the Burger Builder platform on Azure. The stack consists of:

- **Frontend**: React + Vite container hosted on Azure App Service
- **Backend**: Spring Boot (Java 21) container hosted on Azure App Service
- **Data & Networking**: Azure SQL with private endpoint, virtual network with segregated subnets, and Azure Application Gateway in front of both apps
- **Automation**: Terraform infrastructure as code and GitHub Actions pipelines for application and infrastructure delivery

---

## Prerequisites

### Tooling
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) `>= 2.52`
- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.6`
- Docker, Node 20, and Java 21/Maven locally (optional, only if you need to build images or run the services by hand)

### Azure access
- An Azure subscription with contributor access (and owner to create role assignments if secrets/action groups are new)
- Service Principal credentials for automation (stored as the `AZURE_CREDENTIALS` GitHub secret)
- Existing remote state storage (the configuration expects `tfstate-rg-project2` → `tfstate14175` → container `tfstate`)

### Budgets & quotas
- Confirm West Europe (westeurope) quota for App Service plan **P1v2**, Application Gateway **Standard_v2**, and Azure SQL **S0**
- Set a subscription budget or cost alert to monitor spend while the environment is up
- Ensure outbound connectivity to Docker Hub (for GitHub Actions image pushes)

---

## How to Provision (Terraform)

1. **Log in and select the subscription**
   ```bash
   az login
   az account set --subscription "<subscription-id>"
   ```

2. **Prepare secrets**
   - Set the SQL admin password for Terraform (`TF_VAR_sql_admin_password`) or supply it on the CLI.
   - Optional: export `ARM_` environment variables if you do not want to use `az login`.

3. **Init, plan, and apply**
   ```bash
   cd TFmain

   export TF_VAR_sql_admin_password='Super$tr0ngPass!'   # or prompt at apply time

   terraform init
   terraform plan -out plan.tfplan
   terraform apply -auto-approve plan.tfplan
   ```

4. **Review outputs**
   ```bash
   terraform output
   ```
   Useful outputs include:
   - `frontend_hostname` / `backend_hostname`
   - `app_gateway_public_ip`
   - SQL server FQDN and private endpoint IP

Re-run `terraform apply` whenever infrastructure changes are committed. The remote backend keeps state consistent across machines and CI.

---

## How to Deploy (GitHub Actions)

Three workflows live under `.github/workflows/`:

| Workflow | Trigger | Purpose | Required secrets |
| --- | --- | --- | --- |
| `infra.yml` | Push to `main`, `workflow_dispatch` | Runs Terraform in `TFmain/` | `AZURE_CREDENTIALS`, `SQL_ADMIN_PASSWORD` |
| `back.yml` | Push to `main`, `workflow_dispatch` | Builds & pushes the backend image to Docker Hub | `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` |
| `front.yml` | Push to `main`, `workflow_dispatch` | Builds & pushes the frontend image (injects backend URL via build arg) | `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` |

Deployment steps:
1. Populate GitHub repository secrets listed above.
2. Push to `main` or manually run the workflow from the Actions tab.
3. Docker images are tagged with the short commit SHA and `latest` for convenience.
4. Infra workflow consumes the same Terraform configuration used locally; state is shared via the remote backend.

---

## How to Validate

After a successful apply/deploy, validate the platform end-to-end:

### 1. Check public endpoints
- **Frontend**: `https://fe-project2-aalhatlan.azurewebsites.net/`
- **Backend health**: `https://be-project2-aalhatlan.azurewebsites.net/api/health`

### 2. Smoke-test the API
```bash
curl -s https://be-project2-aalhatlan.azurewebsites.net/api/health | jq

curl -s https://be-project2-aalhatlan.azurewebsites.net/api/ingredients \
  | jq '.[0]'
```
Expected health response:
```json
{
  "status": "UP"
}
```

### 3. Exercise the frontend
- Open the frontend URL in a browser.
- Build a burger, add to cart, and place a sample order (the backend seeds data via `data.sql`).
- Confirm assets load via the Application Gateway (inspect network tab or review App Gateway access logs).

### 4. Verify monitoring
- Navigate to **Azure Monitor → Alerts → Alert rules** and confirm the following are enabled:
  - `appgw-backend-health-alert`
  - `fe-requests-alert`
  - `sql-dtu-alert`
- Trigger a manual smoke alert if needed by temporarily stopping one backend instance.

### 5. Optional Postman collection
- Import the backend endpoints into Postman (e.g., `GET /api/ingredients`, `POST /api/orders`).
- Use the same hostname `be-project2-aalhatlan.azurewebsites.net` and ensure HTTPS is enforced.

---

## Notes & Next Steps
- Tear down the environment with `terraform destroy` when it is no longer needed to avoid extra Azure charges.
- Keep Docker images in sync with releases—consider tagging with semantic versions alongside the SHA.
- Review Application Insights dashboards for request/availability details and tune alert thresholds as usage grows.

Happy shipping! 🚀
