# Azure Hello World App

This repository contains the Python web application used throughout my Azure learning journey and DevOps / Cloud Engineer practical assessment.

The project begins as a simple Flask **Hello World** application and gradually evolves into a production-like Azure web application by integrating additional Azure services.

Rather than creating a new project for every exercise, the same application is continuously extended, allowing each Azure service to be integrated into a realistic solution.

---

# Project Evolution

The application grows step by step as new Azure services are introduced.

```text
Hello World

↓

Azure App Service

↓

Azure Storage

↓

Azure SQL Database

↓

Azure Key Vault

↓

Managed Identity

↓

Application Insights

↓

Production Architecture
```

Each milestone introduces a new Azure service while keeping the application fully functional.

---

# Repository Structure

```text
azure-hello-world-app/

│
├── app.py
├── requirements.txt
├── templates/
├── static/
├── .github/
│   └── workflows/
├── README.md
└── .gitignore
```

---

# CI/CD

The application is automatically deployed to Azure App Service using GitHub Actions.

```text
VS Code

↓

Git

↓

GitHub

↓

GitHub Actions

↓

Azure App Service
```

Every push to the **main** branch automatically builds and deploys the latest version of the application.

---

# Technologies

- Microsoft Azure
- Python
- Flask
- Git
- GitHub
- GitHub Actions

---

# Infrastructure as Code

The Azure infrastructure required by this application is managed in a separate Terraform repository.

**Infrastructure Repository**

```text
https://github.com/BredyByte/azure-infrastructure
```

This repository contains:

- Terraform configurations
- Reusable Terraform modules
- Azure networking
- Storage
- SQL Database
- Key Vault
- Managed Identity
- Application Gateway
- Final production infrastructure

Separating the application code from the infrastructure follows common DevOps practices and allows both projects to evolve independently.

---

# Project Goals

- Learn Azure services through practical implementation.
- Build a production-like Flask application.
- Integrate Azure services incrementally.
- Deploy automatically using GitHub Actions.
- Follow DevOps and Infrastructure as Code (IaC) best practices.
