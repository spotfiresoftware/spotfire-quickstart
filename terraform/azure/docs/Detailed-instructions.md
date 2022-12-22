# Detailed instructions

## Overview

These detailed instructions describe how to use `terraform` and `ansible` commands to automatically deploy the Spotfire Platform on Azure.

If you do not want to know about the details, jump to the "Easy peasy instructions" section in [Automatic Deployment of Spotfire Platform on Azure](../README.md).

## Procedure

### Prepare your launcher host

1. Move to the Azure Terraform templates folder:
    ```bash
    cd <this_repo_root>/terraform/azure
    ```

2. Initiate the Terraform environment (only the first time or if you need to upgrade Terraform):
    ```bash
    terraform init --upgrade
    ```

### Configure the target environment

3. You can customize the (terraform) **deployment environment** by editing the file `terraform.env`. 
   Apply those variables with:
    ```bash
    . ./terraform.env
    ```

   **Note**: You need to use a different `TF_WORKSPACE` for applying different environments for the same location.

4. Edit the file `variables.tfvars` to configure your deployment location, operating system, credentials, etc.

   **Note**: You need to use a different `prefix` in `variables.tfvars` for applying multiple environments using the same account.

   **Note**: You need to modify the `source_address_prefix` variable, so you can access the environment from your ip address or subnet 
   (you can find your public ip address for example in https://whatismyipaddress.com/).

5. Edit the file `vars-size-XS.tfvars` to configure your deployment optional resources creation and sizing (type and number of instances)

   **Note**: The `vars-size-XS.tfvars` settings overrides `variables.tfvars` settings.

6. Select a Terraform workspace. For example, a workspace named `spotfire-dev`:
    ```bash
    terraform spotfire-dev 
    ```

7. Verify the planed infrastructure changes before applying them:
    ```bash
    terraform plan -var-file="variables.tfvars" -var-file="vars-size-XS.tfvars"
    ```

### Create the required infrastructure (Terraform)

8. If you agree with the Terraform planned changes, apply them to create the infrastructure:
    ```bash
    terraform apply -var-file="variables.tfvars" -var-file="vars-size-XS.tfvars" --auto-approve
    ```

    **Note**: This step may take 15-30 minutes depending on the sizing.

### Deploy the Spotfire software (Ansible)

9. Move to the ansible folder:
    ```bash
    cd <this_repo_root>/ansible/
    ```

10. Configure the Spotfire deployment by editing the file `config/vars.yml`.

    **Note**: The variables in `config/vars.yml` are used as defaults and may be overridden by previous configuration files.

11. Deploy the Spotfire software with the predefined Ansible playbooks for Spotfire:
    ```bash
    ANSIBLE_PERSISTENT_COMMAND_TIMEOUT=120 ANSIBLE_TIMEOUT=120 ANSIBLE_DISPLAY_SKIPPED_HOSTS=false ANSIBLE_HOST_KEY_CHECKING=False \
	    ansible-playbook \
        -i ../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config/host_groups_azure_rm.yml \
        --extra-vars @config/vars.yml \
        --extra-vars @../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config_files/infra.yml \
        site.yml
    ```

### Resize or reconfigure the created environment

12. You can resize or change your system's configuration by editing again the named configuration files and repeating steps 4-11.

    **Note**: You can use similar deploy command as previous to limit the deployment to a specific type of server. 
    For example if you increased the number of VM instances for the Web Player servers you can just deploy those with:
    ```bash
    ANSIBLE_PERSISTENT_COMMAND_TIMEOUT=120 ANSIBLE_TIMEOUT=120 ANSIBLE_DISPLAY_SKIPPED_HOSTS=false ANSIBLE_HOST_KEY_CHECKING=False \
		ansible-playbook \
       -i ../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config/host_groups_azure_rm.yml \
       --extra-vars @config/vars.yml \
       --extra-vars @../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config_files/infra.yml \
       site.yml \
       --limit wp_servers
    ```

### Destroy the created environment

13. Remember to destroy your environment when you are not going to use it to avoid unneeded costs:
    ```bash
    terraform destroy
    ```
