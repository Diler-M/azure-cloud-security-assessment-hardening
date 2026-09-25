# Azure AKS Security Hardening - Solution

## Initial Findings

I reviewed the Terraform manually and then used Checkov and Trivy to support the review. 

The highest priority issues I identified were:

1. Sensitive values are exposed through Terraform outputs, including the AKS kubeconfig, passwords, a storage account key and a SSH private key.

2. The network security group allows unrestricted inbound and outbound traffic.

3. The storage account permits public blob access, does not enforce HTTPS and accepts TLS 1.0.

4. AKS RBAC is disabled and local admin access remains enabled.

5. The ACR admin account is enabled, and the AKS identity has broader permissions than required.

6. Key Vault purge protection is disabled and it's network access is not restricted.

7. The AKS cluster is not connected to the existing Log Analytics workspace.

I prioritised credential exposure, public access, weak identity controls and insecure network configuration as these present the biggest immediate risk.

Some scanner findings, such as geo-replication, customer managed keys, and private endpoints require more architectural and business context. I have documented these as potential production follow up work rather than implementing them blindly. 

## Initial Validation

Before making any changes, I validated and scanned the original Terraform configuration:

* `terraform fmt -check -recursive` identified `main.tf` as requiring formatting.
* `terraform init -backend=false` completed successfully.
* `terraform validate` confirmed that the configuration was syntactically valid.
* Checkov reported 16 passed checks and 48 failed checks.
* Trivy reported 44 findings: 8 critical, 25 high, 6 medium and 5 low.

The scanner results contain duplicate or overlapping findings, so I will consolidate and prioritise them based on their actual risk and the context of the platform rather than treating every finding as a separate issue.

---

# Implemented Hardening

I focused on changes that addressed immediate security risks without requiring assumptions about the wider network, identity or application architecture.

## Sensitive Terraform Outputs

I removed outputs containing the raw AKS kubeconfig, passwords, the storage account access key and the SSH private key.

These values could be displayed in local terminals or CI/CD logs and would also remain stored in Terraform state. Marking them as sensitive would reduce accidental display, but the values would still remain in Terraform state, so unnecessary credential outputs were removed entirely.

## Hardcoded and Unused Credentials

I removed the unused password and storage key variables, along with their placeholder from the terraform.tfvars.example file.

The variables were either unused or only existed to create and expose credential values. Retaining unnecessary secret inputs increases the risk of real credentials later being hardcoded, committed or passed insecurely through the pipeline.

## SSH Key Management

I removed the Terraform generated SSH key pair and replaced it with an input for an existing SSH public key.

Generating the key pair in Terraform caused the private key to be stored in Terraform state. Supplying only the public key keeps the private key outside Terraform and allows it to be managed through an appropriate secure process.

## Network Security Group Rules

I removed the explicit allow all inbound and outbound network security group rules.

The inbound rule permitted traffic from any source to any destination port and created unnecessary exposure. The outbound rule also allowed unrestricted egress. I did not introduce a strict outbound deny policy because the required AKS and application destinations were not supplied, and an incomplete allow list could prevent the cluster from operating correctly.

## Storage Account & Blob Access

I disabled anonymous public access at the storage account level and changed the 'cluster-logs' container access level from blob to private.

The original configuration allowed individual log blobs to be accessed anonymously by anyone who knew the URL. Logs may contain operational or security sensitive information, so access should require authentication.

I also enabled HTTPS only access and increased the minimum supported TLS version from TLS 1.0 to TLS 1.2.

TLS 1.0 is outdated and does not provide an appropriate modern transport security baseline. Requiring HTTPS and TLS 1.2 protects data and credentials while they are in transit.

## Azure Container Registry Authentication

I disabled the Azure Container Registry administrator account. 

The admin account uses long lived shared credentials with broad registry access. AKS already has a managed identity, so the static admin credentials were unnecessary for image pull access.

## Azure Container Registry Permissions

I changed the AKS container registry role assignment from 'Contributor' to 'AcrPull'. 

The cluster only needs to retrieve container images. 'Contributor' grants broader management permissions than required, while 'AcrPull' provides the specific access needed and follows least privilege best practices.

## AKS Role Based Access Control

I enabled Kubernetes RBAC on the AKS cluster.

Without RBAC, access to Kubernetes resources cannot be controlled according to the responsibilities of users and workloads. Enabling RBAC provides the foundation for applying more granular permissions, while the organisation specific roles and assignments remain outside the scope of this assessment.

Local AKS accounts remain enabled because Entra ID integration is not configured in the supplied architecture. Disabling them without first establishing and testing an alternative administrative access path could remove the only confirmed way to administrate the cluster.

## AKS Monitoring

I connected the AKS cluster to the existing Log Analytics workspace using the managed identity enabled OMS agent.

The workspace was already provisioned but was not connected to the cluster. Enabling Container Insights centralised container logs, Kubernetes events and performance information that can support troubleshooting, operational monitoring and incident investigation.

## Validation Results

After implementing these changes:

* Checkov improved from 16 passed and 48 failed checks to 28 passed and 34 failed checks.
* Trivy findings reduced from 44 to 11: 3 critical, 1 high, 4 medium and 3 low.

The scanner totals were used as supporting evidence rather than the sole measure of security. Some important credential exposures were identified through manual review, while several remaining scanner findings require additional architectural, operational or business context.

# Remaining Work and Trade Offs

The assessment was intentionally scoped, so I did not attempt to remove every scanner finding. The following items require additional architectural, operational or business context before they can be implemented safely.

* **Private Network Access:** Storage, Key Vault and ACR remain accessible through public endpoints. Private endpoints and restricted network rules would reduce internet exposure, but the required workload, admin and CI/CD network paths were not supplied.
* **AKS API & Admin Access:** The AKS API remains public, and local accounts remain enabled. Authorised IP ranges or a private cluster would reduce exposure, while Entra ID integration would provide centrally managed user access. These changes require confirmed network ranges and a tested replacement admin path.
* **Workload identity:** OIDC and AKS Workload Identity remain disabled. Workload identity would allow pods to use short-lived Azure tokens instead of stored secrets or shared keys, but the required workloads, service accounts and permissions were not provided.
* **Key Vault security:** The Terraform identity has broad permissions across keys, secrets and certificates, and the vault has no network restrictions. These permissions should be reduced and Azure RBAC considered once the required deployment, administrative and workload access is understood.
* **Storage authentication:** Shared Key authentication remains enabled. Managed identities and Entra ID roles would reduce reliance on long-lived account keys, but existing storage consumers must be identified and migrated first.
* **Monitoring and secret scanning:** Additional AKS control-plane, Storage, Key Vault and ACR diagnostics should be assessed based on retention and cost requirements. TruffleHog was added to the pipeline because the IaC scanners did not reliably detect all credential exposures found during manual review.
* **Supply-chain, resilience and encryption controls:** Image scanning, signing, geo-replication, customer-managed keys and higher availability options require defined compliance, recovery, availability and cost requirements.

## Azure DevOps Pipeline

I created an Azure DevOps pipeline that runs on pushes and pull requests to `main`.

It performs the following offline checks:

* Terraform formatting
* Terraform initialisation without the backend
* Terraform validation
* Targeted Checkov security checks
* TruffleHog secret scanning

The pipeline blocks changes that fail the implemented security controls or contain potential credentials.

Deployment was intentionally excluded. A production deployment process should use separate plan and apply stages, approvals and an appropriately scoped Azure service connection.

## Azure Authentication and RBAC

A production deployment pipeline should authenticate to Azure through an Azure DevOps service connection using workload identity federation rather than a stored client secret.

The service connection should be assigned only the permissions required to deploy the Terraform resources, ideally scoped to the target resource group rather than the full subscription.

Terraform would receive the Azure identity through the service connection, while sensitive values should be stored in Azure DevOps secret variables or Key Vault rather than committed to the repository.

## Use of AI tools

I used an AI assistant to help clarify unfamiliar Terraform and Azure concepts and as a second pair of eyes when reviewing the scanner findings. The final prioritisation, implementation decisions and validation were completed by me as part of this exercise.
