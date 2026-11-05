# terraform-aws-iac
# AWS Infrastructure as Code with Terraform

**Provisioning modular AWS infrastructure using Terraform, with remote state management and reusable modules.**

## Project Overview

This project demonstrates how to provision and manage AWS infrastructure using **Terraform**, following Infrastructure as Code (IaC) principles.

The infrastructure represents the foundation of a web application environment, with public and private networking, an EC2 compute instance, and a managed MySQL database.

Instead of manually creating resources through the AWS Management Console, the infrastructure is defined declaratively in Terraform, organised into reusable modules, and managed through version-controlled configuration.

## Architecture

The infrastructure consists of:

- A custom Amazon VPC.
- Two public subnets across separate Availability Zones.
- Two private subnets across separate Availability Zones.
- An Internet Gateway and public route table.
- A private route table for private subnet routing.
- An EC2 instance deployed in a public subnet.
- Security groups controlling access to the EC2 instance and RDS database.
- An Amazon RDS MySQL database deployed privately.
- An S3 remote backend with DynamoDB-based state locking.

### Architecture Diagram

```mermaid
flowchart TB
    Internet(("Internet"))
    Terraform["Terraform CLI"]

    subgraph AWS["AWS CLOUD | ap-southeast-2"]
        direction TB

        subgraph VPC["AMAZON VPC | 10.0.0.0/16"]
            direction TB

            IGW["Internet Gateway"]
            PUBRT["Public Route Table"]

            subgraph PUBLIC["PUBLIC TIER"]
                direction LR
                subgraph AZ1PUB["Availability Zone: ap-southeast-2a"]
                    PUB1["Public Subnet 1<br/>10.0.1.0/24"]
                    EC2["EC2 Web Server"]
                end
                subgraph AZ2PUB["Availability Zone: ap-southeast-2b"]
                    PUB2["Public Subnet 2<br/>10.0.2.0/24"]
                end
            end

            PRIVRT["Private Route Table"]

            subgraph PRIVATE["PRIVATE TIER"]
                direction LR
                subgraph AZ1PRIV["Availability Zone: ap-southeast-2a"]
                    PRIV1["Private Subnet 1<br/>10.0.11.0/24"]
                end
                subgraph AZ2PRIV["Availability Zone: ap-southeast-2b"]
                    PRIV2["Private Subnet 2<br/>10.0.12.0/24"]
                end
                RDS["Amazon RDS<br/>MySQL Database<br/>Not publicly accessible"]
            end

            WEBSG["Web Security Group"]
            DBSG["Database Security Group<br/>Inbound TCP 3306<br/>Source: Web Security Group"]
        end

        subgraph STATE["REMOTE STATE MANAGEMENT"]
            direction LR
            S3[("Amazon S3<br/>Terraform State")]
            DDB[("Amazon DynamoDB<br/>State Locking")]
        end
    end

    Internet --> IGW
    IGW --> PUBRT
    PUBRT --> PUB1
    PUBRT --> PUB2
    EC2 --- PUB1

    PRIVRT --> PRIV1
    PRIVRT --> PRIV2
    RDS --- PRIV1
    RDS --- PRIV2

    EC2 --> WEBSG
    WEBSG -. "Allows MySQL traffic" .-> DBSG
    DBSG -. "Protects database access" .-> RDS

    Terraform --> S3
    Terraform --> DDB

    classDef internet fill:#e0f2fe,stroke:#0284c7,color:#0c4a6e,stroke-width:2px
    classDef network fill:#dbeafe,stroke:#2563eb,color:#1e3a8a,stroke-width:1.5px
    classDef public fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px
    classDef private fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px
    classDef security fill:#fce7f3,stroke:#db2777,color:#831843,stroke-width:1.5px
    classDef state fill:#ede9fe,stroke:#7c3aed,color:#4c1d95,stroke-width:1.5px
    classDef terraform fill:#e0e7ff,stroke:#4f46e5,color:#312e81,stroke-width:2px

    class Internet internet
    class IGW,PUBRT,PRIVRT network
    class PUB1,PUB2,EC2 public
    class PRIV1,PRIV2,RDS private
    class WEBSG,DBSG security
    class S3,DDB state
    class Terraform terraform

    style AWS fill:#f8fafc,stroke:#334155,stroke-width:2px,color:#0f172a
    style VPC fill:#eff6ff,stroke:#2563eb,stroke-width:2px,color:#1e3a8a
    style PUBLIC fill:#f0fdf4,stroke:#16a34a,stroke-width:1.5px,color:#14532d
    style PRIVATE fill:#fffbeb,stroke:#d97706,stroke-width:1.5px,color:#78350f
    style STATE fill:#f5f3ff,stroke:#7c3aed,stroke-width:1.5px,color:#4c1d95
```

*The diagram represents the intended architecture. The private route table currently provides private subnet routing; a NAT Gateway has not been configured.*

## AWS Services Used

| Service | Purpose |
|---|---|
| Amazon VPC | Isolated cloud network |
| Amazon EC2 | Compute instance for the web tier |
| Amazon RDS (MySQL) | Managed relational database |
| Amazon S3 | Terraform remote state storage |
| Amazon DynamoDB | Terraform state locking |
| AWS IAM | Identity and access management |
| Internet Gateway | Internet connectivity for public subnets |
| Security Groups | Network traffic control |

## Infrastructure Components

### 1. Networking

- Created a custom VPC with CIDR `10.0.0.0/16`.
- Created two public subnets across two Availability Zones.
- Created two private subnets across two Availability Zones.
- Configured an Internet Gateway.
- Created public and private route tables.
- Associated the route tables with their respective subnets.

### 2. Compute

- Provisioned an Amazon EC2 instance in a public subnet.
- Used an Amazon Linux 2023 AMI.
- Configured a web security group.
- Restricted administrative access using a configurable CIDR variable.

### 3. Database

- Provisioned an Amazon RDS MySQL instance.
- Created a dedicated DB subnet group using private subnets.
- Configured a database security group.
- Allowed MySQL traffic on port `3306` only from the EC2 web security group.
- Configured the database as non-publicly accessible.

### 4. Terraform State Management

- Configured an Amazon S3 backend for remote Terraform state.
- Configured DynamoDB-based state locking.
- Enabled state encryption.
- Created a local state backup before refactoring the infrastructure.

### 5. Modular Terraform Architecture

The Terraform configuration was refactored into reusable modules to improve maintainability and separation of concerns.

```text
terraform-aws-iac/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── .gitignore
├── .terraform.lock.hcl
│
└── modules/
    ├── network/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── compute/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── database/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

| Module | Responsibility |
|---|---|
| `network` | VPC, subnets, Internet Gateway and route tables |
| `compute` | EC2 instance and web security group |
| `database` | RDS MySQL, DB subnet group and database security group |

## Terraform Workflow

The infrastructure is managed using the following workflow:

```bash
# Initialise Terraform
terraform init

# Format configuration files
terraform fmt -recursive

# Validate configuration
terraform validate

# Preview infrastructure changes
terraform plan

# Apply infrastructure changes
terraform apply
```

To inspect the resources managed by Terraform:

```bash
terraform state list
```

## Key Learnings

Through this project, I gained practical experience with:

- Infrastructure as Code using Terraform and HCL.
- Provisioning AWS networking and compute resources.
- Designing public and private subnet architectures.
- Configuring security groups and resource-level access.
- Deploying and configuring Amazon RDS.
- Managing Terraform remote state using S3.
- Understanding Terraform state locking.
- Refactoring root-level resources into reusable modules.
- Migrating existing Terraform state into module-based resource addresses.
- Using `terraform plan` to detect infrastructure drift and avoid unintended changes.


## Cleanup

When the infrastructure is no longer required, it can be removed using:

```bash
terraform destroy
```

Review the destruction plan carefully before confirming. The S3 backend and DynamoDB lock table should be managed separately if they are shared or required to retain Terraform state.

---

**Author:** Khyati Saxena

**Technologies:** Terraform | AWS | HCL | Amazon VPC | EC2 | RDS | S3 | DynamoDB | IAM