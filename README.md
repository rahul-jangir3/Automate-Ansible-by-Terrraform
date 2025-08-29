# Automate Ansible by Terrraform 

This project demonstrates **Infrastructure as Code (IaC)** with **Terraform** and **Configuration Management** with **Ansible**.  

- Terraform provisions **2 EC2 instances** in AWS (Ubuntu 22.04, region: `ap-south-1`).  
- Instance 1 → Installs **Docker**.  
- Instance 2 → Installs **Nginx** and deploys a sample **index.html** page using Ansible.  
- Terraform automatically generates an **inventory.ini** file and triggers **ansible-playbook** after provisioning.  

---

## Project Flow  

1. **Terraform provisions AWS infrastructure**:  
   - Creates an SSH key pair (`terraform-ansible-key.pem`)  
   - Creates a Security Group (SSH + HTTP open)  
   - Launches 2 EC2 instances (Docker & Nginx)  

2. **Terraform → Ansible Integration**:  
   - Terraform generates `inventory.ini` with instance IPs.  
   - Runs `ansible/main.yml` automatically after provisioning.  

3. **Ansible Playbook Actions**:  
   - **Docker Instance** → Installs Docker and verifies it.  
   - **Nginx Instance** → Installs Nginx and deploys an `index.html` app.  

---

## 📂 Project Structure  

```bash

terraform-ansible-ec2/
├── ansible       # All Playbooks of Ansible
│   ├── main.yml
│   └── playbooks
│       ├── app.yml
│       ├── deploy.yml
│       └── env.yml
├── ansible.tf    # Inventory, repo clone, and Ansible provisioner
├── ec2-docker.tf # It is creating my docker Instance
├── ec2-nginx.tf  # It is creating my Nginx Instance
├── inventory.tpl # Template file for inventory.ini
├── outputs.tf    # All outputs
├── provider.tf   # Procider AWS
├── security.tf   # Security group
├── ssh.tf        # Key pair generation & private key
└── terraform.tf  # terraform block
```
------------------------------------------------------------------
Install Dependencies

1. Terraform
```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install -y terraform
```
2. AWS CLI
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install
```
Configure AWS CLI
```
aws configure
```
3. Ansible
```
sudo apt-get install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible
```
-----------------------------------------------------------------
Initialize Terraform
```
terraform init
```
Plan infrastructure
```
terraform plan
```
Apply changes
```
terraform apply -auto-approve
```
Destroy everything created by Terraform:
```
terraform destroy -auto-approve
```

