ACC_ID=$(aws sts get-caller-identity --query Account --output text)
ACC_ALIAS=$(aws iam list-account-aliases --query AccountAliases[0] --output text)
USER_NAME=$(aws sts get-caller-identity --query Arn --output text | cut -d "/" -f 2)
CURR_DIR=$(basename $(pwd))
DATE=$(date '+%Y-%m-%d')

BUCKET=${ACC_ID}-shared-terraform-state

cat << EOF > backend.tf
# Backend created by ws_init.sh
# NOTE: region is only related the backend not the deployment, pls don't change it
terraform {
    backend "s3" {
      acl = "private"
      encrypt = true
      bucket = "$BUCKET"
      key    = "$USER_NAME/terraform.tfstate"
      region = "eu-west-1"
      workspace_key_prefix = "$USER_NAME"
    }
  }
EOF

terraform init

printf "\nName of the new workspace (lowercase only, first character letters only ie: gs-1234) ? : "
read WSNAME
WSNAME=${WSNAME,,}

if [ -z "$WSNAME" ]
then echo "No workspace set, reverting to (cloud) default, cloud backend configured"
else
  terraform workspace select $WSNAME >/dev/null 2>&1
  if [ $? -eq 1 ]; then
    terraform workspace new $WSNAME >/dev/null 2>&1
  fi
fi


WS=$(terraform workspace show)
WSLIST=$(terraform workspace list | grep -v default | tr -d '\* ')

cat << EOF

Workspaces backend successfully set on cloud (including default workspace).

Current account: $ACC_ALIAS
Current workspace: $WS
Available workspaces:
$WSLIST

Create and use a new workspace: `terraform workspace new ws-wxyz`
To switch into another workspace: `terraform workspace select ws-wxyz`
Once finished please clean up: from another workspace run `terraform workspace delete <workspace_name>`
Clean-up and revert to local: `rm -fr .terraform* terraform* backend.tf && terraform init`

AWS credentials are currently inherited from aws cli,
please reconfigure aws cli to change account
EOF
