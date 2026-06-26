# AWS Security Lab — Terraform

**Project:** Kratva Security Lab  
**Region:** ap-south-1 (Mumbai) | Multi-AZ: ap-south-1a + ap-south-1b  
**Stack:** VPC → ALB → WAF → EC2 (private) → RDS PostgreSQL (Multi-AZ) + Bastion

---

## Architecture

```
Internet
    │
    ▼
[WAF] ──────────────── Blocks OWASP / SQLi / Rate limit / IP block list
    │
[ALB] ─── public subnets (1a + 1b) ─── HTTP→HTTPS redirect
    │
[EC2 Web] ─── private app subnet (1a) ─── Apache
    │
[RDS PostgreSQL] ─── private db subnets (1a + 1b) ─── Multi-AZ standby
    
[Bastion] ─── public subnet (1a) ─── SSH from your IP only
```

---

## Cost Control Toggles

```bash
# Destroy NAT Gateway only (saves ~$32/month when lab is idle)
terraform apply -var="enable_nat_gateway=false"

# Disable RDS Multi-AZ (saves ~50% on RDS cost)
terraform apply -var="rds_multi_az=false"

# Destroy everything
terraform destroy
```

---

## Prerequisites

```bash
# Install required tools
brew install terraform tflint pre-commit   # macOS
# or
sudo apt install terraform                 # Ubuntu

pip install checkov pre-commit

# Configure AWS CLI
aws configure
# Region: ap-south-1
# Verify identity
aws sts get-caller-identity
```

---

## Step 1 — Bootstrap Remote State (Run ONCE)

```bash
cd bootstrap/
terraform init
terraform apply
# Copy outputs into environments/lab/backend.tf
```

---

## Step 2 — Set Sensitive Variables

```bash
# Never put db_password in terraform.tfvars
export TF_VAR_db_password="YourStrongPassword123!"
```

---

## Step 3 — Update terraform.tfvars

Edit `environments/lab/terraform.tfvars`:

```bash
# Get your current IP
curl -s ifconfig.me
# Set as: my_ip_cidr = "YOUR_IP/32"

# Verify AMI is latest Amazon Linux 2 in ap-south-1
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --region ap-south-1
```

---

## Step 4 — Init, Plan, Apply

```bash
cd environments/lab/

terraform init

terraform fmt -recursive          # Format before every plan
terraform validate                # Catch syntax errors

terraform plan -out=tfplan        # Always save plan file
terraform show tfplan             # Review before apply

terraform apply tfplan            # Apply saved plan only
```

---

## Step 5 — Destroy (Fast cost control)

```bash
# Selective destroy — kill costly resources only
terraform apply -var="enable_nat_gateway=false" -var="rds_multi_az=false"

# Full destroy
terraform destroy
```

---

## GitHub Push — Industry Workflow

### First Push (new repo)

```bash
# 1. Create repo on GitHub (empty, no README)
#    Name: aws-security-lab | Private | No .gitignore (we have one)

# 2. Initialise git
cd aws-security-lab/
git init
git branch -M main

# 3. Install pre-commit hooks (runs checkov + tflint + fmt on every commit)
pre-commit install

# 4. Stage and commit
git add .
git status                        # Review what is staged
git commit -m "feat: initial terraform lab infrastructure

- Modular structure: networking, sg, alb, waf, ec2, bastion, rds, iam
- Remote state: S3 + DynamoDB with encryption and versioning
- Multi-AZ: ap-south-1a + ap-south-1b
- Security: IMDSv2, encrypted EBS/RDS, VPC flow logs, WAF managed rules
- Cost control: enable_nat_gateway and rds_multi_az toggles"

# 5. Add remote and push
git remote add origin git@github.com:YOUR_USERNAME/aws-security-lab.git
git push -u origin main
```

### Ongoing Workflow (every change)

```bash
# Always work on a feature branch — never commit directly to main
git checkout -b feat/add-guardduty

# Make changes, then:
git add -p                        # Stage hunks interactively — not git add .
git commit -m "feat: add GuardDuty module with S3 and EC2 findings"

# Push branch and open PR
git push origin feat/add-guardduty

# On GitHub: open PR → review plan output in PR description → merge to main
# Never merge without a terraform plan output in the PR
```

### Branch Strategy

```
main          ← protected, deployable always
feat/*        ← new modules or resources
fix/*         ← bug fixes
chore/*       ← pre-commit, tflint, formatting only
```

### Commit Message Format (Conventional Commits)

```
feat: add WAF rate limiting rule
fix: correct RDS subnet group AZ mapping
chore: update pre-commit hook versions
docs: add cost control section to README
refactor: extract security groups into separate module
```

---

## Security Checklist (before every apply)

- [ ] `terraform plan` reviewed — no unintended destroys
- [ ] No secrets in `.tfvars` or committed files
- [ ] `TF_VAR_db_password` set via environment variable
- [ ] `my_ip_cidr` is your actual IP, not `0.0.0.0/0`
- [ ] Pre-commit hooks passed (checkov + tflint)
- [ ] `checkov -d .` output reviewed for HIGH findings

---

## Module Structure

```
aws-security-lab/
├── bootstrap/                    # Remote state — run once
├── environments/
│   └── lab/
│       ├── main.tf               # Module wiring
│       ├── variables.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── backend.tf            # S3 remote state
│       └── terraform.tfvars      # Edit before apply
└── modules/
    ├── networking/               # VPC, subnets, IGW, NAT GW, flow logs
    ├── security-groups/          # ALB, web, bastion, RDS SGs
    ├── alb/                      # ALB, TG, listeners, access logs
    ├── waf/                      # WAF ACL, managed rules, rate limit
    ├── ec2/                      # Web server, IMDSv2, Apache
    ├── bastion/                  # SSH jump host, hardened
    ├── rds/                      # PostgreSQL Multi-AZ, encrypted
    └── iam/                      # Roles, least privilege policies
```
