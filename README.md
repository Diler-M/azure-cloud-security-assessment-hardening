# Azure AKS Security Hardening Assessment

## Overview

This project demonstrates a security assessment and hardening exercise for an Azure Kubernetes Service (AKS) platform provisioned using Terraform.

The environment is intentionally configured with a number of security weaknesses and incomplete controls across networking, identity, storage, secrets management, container registry security, monitoring, and Kubernetes configuration.

The objective is to review the infrastructure-as-code as if it were being prepared for a production environment, identify the highest-priority risks, implement targeted remediation, and document the reasoning behind each change.

The `main` branch contains the intentionally insecure baseline configuration.

The `hardened-solution` branch and associated pull request contain the remediated implementation.

---

## Architecture

The Terraform configuration provisions the following Azure resources:

- Resource Group
- Virtual Network and Subnets
- Network Security Group
- Log Analytics Workspace
- Storage Account and Blob Container
- Azure Key Vault
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS)
- Azure RBAC Role Assignments

The environment is designed as a security-focused lab rather than a production deployment.

---

## Security Assessment Scope

The baseline configuration contains deliberate security weaknesses across areas including:

- Overly permissive network security rules
- Insecure storage account configuration
- AKS authentication and RBAC controls
- Azure Container Registry administrative access
- Key Vault protection and network exposure
- Logging and monitoring integration
- Sensitive Terraform outputs
- Infrastructure-as-code security validation
- Azure authentication and service connection design

The assessment focuses on identifying and prioritising the highest-impact risks before applying targeted remediation.

---

## Validation Approach

The Terraform configuration can be reviewed and validated locally without requiring access to a live Azure subscription.

Typical validation steps include:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

Infrastructure-as-code security scanning can also be performed using static analysis tooling.

This allows Terraform quality and security checks to be performed without deploying the environment.

---

## Repository Structure

```text
azure-cloud-security-assessment-hardening/
├── README.md
├── .gitignore
└── terraform/
    ├── backend.tf
    ├── main.tf
    ├── outputs.tf
    ├── terraform.tfvars.example
    ├── variables.tf
    └── versions.tf
```

---

## Branches

### `main`

Contains the intentionally insecure baseline configuration.

### `hardened-solution`

Contains the remediated Terraform configuration, security validation pipeline, and written security assessment.

The open pull request between the two branches provides a line-by-line view of the security changes applied to the baseline environment.

---

## Project Purpose

This project is designed to demonstrate practical cloud security and DevSecOps skills, including:

- Azure cloud security
- Azure Kubernetes Service
- Terraform security review
- Infrastructure-as-code hardening
- Azure RBAC
- Network security
- Key Vault security
- Container registry security
- Secure CI/CD validation
- Security misconfiguration assessment
- Risk prioritisation
- Security remediation

---

## Scope and Limitations

This project focuses on infrastructure security assessment and Terraform hardening rather than building a complete production platform.

A production implementation would require additional architectural and operational considerations such as:

- Private endpoints
- Restricted public network access
- Entra ID integration
- Workload identity
- Azure Policy
- Defender for Cloud
- Kubernetes admission controls
- Extended diagnostic logging
- Centralised secrets management
- Backup and disaster recovery
- Image signing and supply-chain controls
- Threat modelling