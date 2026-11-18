# AWS Cross-Region VPC Peering using Terraform

## Architectural Diagram
<img width="1011" height="612" alt="VPC Peering" src="https://github.com/user-attachments/assets/7765bfc4-2011-4166-8fbb-6e4c1376852d" />

## Overview

This project demonstrates how to establish private network communication between two Amazon VPCs deployed in different AWS regions using **Terraform**.

It provisions two VPCs, public subnets, Internet Gateways, route tables, security groups, and EC2 instances. A cross-region VPC Peering connection enables the EC2 instances to communicate using their private IP addresses.

The entire infrastructure is automated using Terraform.

## Architecture

The infrastructure includes:

- **Two VPCs:** Deployed in separate AWS regions with non-overlapping CIDR blocks.
- **Public Subnets:** One subnet in each VPC.
- **Internet Gateways:** Provide internet connectivity to both VPCs.
- **Route Tables:** Configure internet and cross-VPC traffic routing.
- **VPC Peering:** Establishes private connectivity between the two VPCs.
- **Security Groups:** Allow SSH access from an authorized IP and ICMP traffic between VPCs.
- **EC2 Instances:** Ubuntu instances deployed in each VPC to test connectivity.
- **SSH Key Pairs:** Separate key pairs for accessing each EC2 instance.
- **Terraform Remote State:** Stores infrastructure state in an S3 backend.

## How It Works

1. Terraform creates two VPCs in separate AWS regions.
2. Each VPC receives a public subnet, Internet Gateway, and route table.
3. A cross-region VPC Peering connection is created between the two VPCs.
4. The secondary VPC accepts the peering connection.
5. Both route tables are updated with routes pointing to the peer VPC through the peering connection.
6. EC2 instances are deployed in each VPC.
7. Security groups allow ICMP traffic between the VPC CIDR ranges.
8. The EC2 instances can communicate privately using their private IP addresses.

## Technologies Used

- AWS (VPC, EC2, Internet Gateway, Route Tables, VPC Peering)
- Terraform
- AWS CLI
- SSH

## Project Structure

```text
.
├── backend.tf
├── data.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── var.tf
├── variable.tfvars # NOT INCLUDED
└── .gitignore
```

## Prerquisites
- Two key pairs for EC2 instances. (Can be generated through terraform, or through CLI)
- Create tfvars file - containing values of variables. (VPC/Subnet CIDRs, Regions etc )

## VPC Routing VS Transit Gateway
### VPC Peering
In this project we leveraged VPC Peering to enable private communication between 2 VPCs. This setup creates a one-to-one connection between 
VPCs, which constitutes to minimal latency. For businesses that utilise less than 10 VPCs, VPC Peering is an excellent way of enable private routing.
This also use to be the exclusive method of enabling communication between VPCs. 

VPC routing is also Cost-Effective, compared to alternatives like transit gateway. However, the setup can quickly become difficult to maintain and scale.
It has a mesh like topology, which requires individual connections for each VPC connection. For example, if you have 4 VPCs, you will have to configure a connection between VPC 1 --> VPC 2 --> VPC 3 --> VPC 4 THEN CONNCECT VPC 4 --> VPC 1 AND VPC 3 AND VPC 2 --> 4. So in total there will be 6 peering
connections for 4 VPCs. While this doesn't seem like much, it can become very difficult and complex to manage as more VPCs are peered. Below is a diagram 
for reference:

<img width="556" height="516" alt="peering" src="https://github.com/user-attachments/assets/02a1a792-ab81-43b9-a781-08b2e734a338" />


For this reason, it is recommended to leverage "transit gateway" if your setup cloud architecture required more than 10 VPCs. It has a far simpler
and modern-friendly setup - making maintenance seamless and timely. For more on Transit Gateway refer to my transit gateway repo.


