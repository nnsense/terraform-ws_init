# ws_init

A small bash script to create a shared terraform backend.tf.

It is enforcing paths and names into the S3 backet used as backend using some details taken from the user's environment such as the AWS username and the AWS account ID.

On S3, there will be only one directory per user, which will allow to list and select the user's workspace from any location. For cloud engineers, this will ease the management, it helps collaboation, since a user can easily reconfigure the backend to have access to another's workspace, and it allows the user to see only personal workspaces, and use them for different deployments and tests.

## Usage

Run ws_init.sh to setup the terraform backend.tf. The script will ask to create a new terraform workspace, please provide a name for the new workspace (if by any chance you type an existing workspace, the script will just switch into it).

Skipping (hitting enter without providing any name) will configure the backend without changing into any workspace, make sure to run terraform workspace list and select one.

The script will then run terraform init to complete the setup.

The generated backend.tf will contain the settings to use the S3 workspace, there's no need to run the script again, you might even copy this backend into other deployments, provided you're working into the same account.

If you hange the account, run the script again to create a new backend.tf targeting the right bucket.
