# Setup Up the Azure Resources

## Terraform Init

```bash

# Use remote storage
terraform init --backend-config ./backend-secrets.tfvars

```

## Terraform Plan and Apply

```bash

# Run the plan to see the changes
terraform plan \
-var 'base_name=cdw-wordpress-20210216' \
-var 'location=westus2'

#--var-file=secrets.tfvars


# Apply the script with the specified variable values
terraform apply \
-var 'base_name=cdw-wordpress-20210216' \
-var 'location=westus2'

#--var-file=secrets.tfvars

```
