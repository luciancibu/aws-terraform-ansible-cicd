AWS Terraform + Ansible Deployment

This project automates the deployment of a full infrastructure stack
consisting of Nginx, Flask, and MariaDB, using Terraform for
provisioning and Ansible for configuration management.

------------------------------------------------------------------------

Project Structure

    aws-terraform-ansible-cicd/
    │
    ├── ReadMe.md
    │
    ├── ansible/
    │   ├── ansible.cfg
    │   ├── ansible.log
    │   ├── ansible_cicd_client-key.pem
    │   ├── inventory
    │   ├── playbook.yml
    │   │
    │   └── roles/
    │       ├── flask/
    │       │   ├── handlers/main.yml
    │       │   ├── tasks/main.yml
    │       │   └── templates/app.py.j2
    │       │
    │       ├── mariadb/
    │       │   ├── handlers/main.yml
    │       │   └── tasks/main.yml
    │       │
    │       └── nginx/
    │           ├── files/index.html
    │           ├── files/style.css
    │           ├── handlers/main.yml
    │           ├── tasks/main.yml
    │           └── templates/default.conf.j2
    │
    └── terraform/
        ├── ami.tf
        ├── instances.tf
        ├── inventory.tmpl
        ├── keypair.tf
        ├── outputs.tf
        ├── provider.tf
        ├── security.tf
        ├── terraform.tfstate
        ├── terraform.tfstate.backup
        └── variables.tf

------------------------------------------------------------------------

1. Infrastructure Provisioning with Terraform

From the terraform/ directory:

    terraform init
    terraform apply

Terraform will create:

-   EC2 instances for Ansible Control(amazon_linux_2023), Nginx(redhat_rhel8), Flask(debian_12), and MariaDB(ubuntu_24_04)
-   Security Groups
-   Key Pair
-   Auto-generated ansible/inventory file

------------------------------------------------------------------------

2. After EC2 Creation: Automatically Copy the Ansible Folder to Control EC2

Once Terraform finishes, you must:

1. Copy the entire ansible/ folder to the EC2 control node
2️. Apply correct SSH key permissions
3️. Run the Ansible playbook

------------------------------------------------------------------------

Manual Ansible Execution (Alternative)

    cd ansible
    chmod 400 ansible_cicd_client-key.pem
    ansible-playbook playbook.yml

------------------------------------------------------------------------

4. Validation

Check the website:

    http://<nginx_public_ip>

Check the API counter:

    curl http://<nginx_public_ip>/view

------------------------------------------------------------------------

5. Destroy Infrastructure

    terraform destroy

------------------------------------------------------------------------
