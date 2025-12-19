# AWS Terraform + Ansible Deployment

This project automates the provisioning of a full infrastructure stack
consisting of **Nginx**, **Flask**, and **MariaDB**, using **Terraform** for
infrastructure provisioning and **Ansible** for configuration management.

Terraform is responsible **only** for infrastructure and inventory generation.
Ansible is executed **manually** after provisioning.

---

## Project Structure

```
aws-terraform-ansible-cicd/
│
├── README.md
│
├── ansible/
│   ├── ansible.cfg
│   ├── ansible.log
│   ├── inventory              # Generated automatically by Terraform
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
└── infra/
    ├── modules/
    │   ├── ec2/
    │   ├── iam/
    │   ├── keypair/
    │   ├── s3-ansible/
    │   └── security-group/
    │
    ├── templates/
    │   └── inventory.tmpl
    │
    └── env/
        └── dev/
            ├── main.tf
            ├── locals.tf
            ├── variables.tf
            └── outputs.tf
```

---

## 1. Infrastructure Provisioning with Terraform

From the `infra/env/dev` directory:

```bash
terraform init
terraform apply
```

Terraform will create:

- EC2 instances:
  - Ansible Control Node (Amazon Linux 2023)
  - Nginx (RHEL 8)
  - Flask API (Debian 12)
  - MariaDB (Ubuntu 24.04)
- Security Groups (modularized)
- IAM roles and instance profiles (SSM-based access)
- SSH Key Pair (stored in `ansible/`)
- **Auto-generated `ansible/inventory` file** based on EC2 private IPs

Terraform **does not run Ansible**.

---

## 2. After EC2 Creation: Run Ansible Manually

After Terraform completes:

1. Ensure the SSH key has correct permissions:
   ```bash
   chmod 400 ansible/*.pem
   ```

2. Navigate to the Ansible directory:
   ```bash
   cd ansible
   ```

3. Run the playbook:
   ```bash
   ansible-playbook playbook.yml
   ```

---

## 3. Validation

### Web Interface
Open in browser:
```text
http://<nginx_public_ip>
```

### API Endpoint
```bash
curl http://<nginx_public_ip>/view
```

---

## 4. Destroy Infrastructure

From `infra/env/dev`:

```bash
terraform destroy
```

---

## Notes

- Terraform modules are fully decoupled (EC2, IAM, S3, SG, Keypair).
- Inventory regeneration is automatic when EC2 IPs change.
