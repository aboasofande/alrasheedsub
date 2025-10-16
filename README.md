Burger Builder - Azure Infrastructure
A cloud-native burger builder application deployed on Azure using modern infrastructure-as-code practices with Terraform.
📖 Project Overview
This project implements a full-stack web application for building and ordering custom burgers. The infrastructure is designed with security, scalability, and cost-efficiency in mind, leveraging Azure's platform services for a production-ready deployment.
🏗️ Architecture
High-Level Design
The application follows a three-tier architecture deployed entirely on Azure:
Internet → Application Gateway → Container Apps (Frontend + Backend) → SQL Database
                ↓
          Virtual Network (Private)
Components
Frontend Layer

React application served via Azure Container Apps
Containerized using Docker from DockerHub (aboasofande/frontend-alrasheed:fixed)
Handles user interface and client-side logic

Backend Layer

Spring Boot REST API served via Azure Container Apps
Containerized using Docker from DockerHub (aboasofande/backend-alrasheed:fixed)
Manages business logic and data operations
Exposes health check endpoint at /actuator/health

Data Layer

Azure SQL Database (Standard S0 tier)
Private endpoint for secure access
No public internet exposure

Networking Layer

Azure Virtual Network with CIDR 10.20.0.0/16
Three dedicated subnets for network segmentation
Private DNS zones for internal service discovery
Network Security Groups for traffic control

Load Balancing

Azure Application Gateway (Standard_v2)
Path-based routing:

/ → Frontend
/api/* → Backend


HTTP health probes for backend monitoring

🌐 Network Architecture
Virtual Network Design
SubnetCIDRPurposeSpecial Configappgw-snet10.20.0.0/24Application GatewayNSG allows HTTP/HTTPSaca-infra-snet10.20.1.0/24Container AppsDelegated to Microsoft.Appdb-snet10.20.3.0/24SQL Private EndpointPrivate endpoint enabled
