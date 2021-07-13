# Detailed instructions

## Overview

These detailed instructions describe how to use `terraform` and `ansible` commands to automatically deploy the Spotfire Platform on Azure.

If you do not want to know about the details, jump to the "Easy peasy instructions" section in [Automatic Deployment of Spotfire Platform on Azure](../README.md).

## Procedure

### Prepare the environment

1. Move to the Azure Terraform templates folder

   ~~~
   cd <this_repo_root>/terraform/azure
   ~~~

2. Initiate the Terraform environment (only the first time or if you need to upgrade Terraform).

   ~~~
   terraform init --upgrade
   ~~~

### Configure the environment

3. You can customize some **Terraform environment** by editing the file `terraform.env`. Apply those variables.

   ~~~
   . ./terraform.env
   ~~~
   
   Note: You need to use a different `TF_WORKSPACE` for applying different environments for the same location.
   
4. Edit the file `variables.tfvars` to configure your deployment location, operating system, credentials, etc.

   Note: You need to use a different `prefix` in `variables.tfvars` for applying multiple environments using the same account.

   Note: You need to modify the `source_address_prefix` variable, so you can access the environment from your ip address or subnet (you can find your public ip address for example in https://whatismyipaddress.com/).

   Note: By default, we do not create an Azure Application Gateway or an Azure Bastion (they take some more time to spin up in Azure and are not very interesting for small test environments). Check in `vars-size-XS.tfvars` the variables that control *resource creation and sizing*. 

5. Edit the file `vars-size-XS.tfvars` to configure your deployment optional resources creation and sizing (type and number of instances)

   Note: The `vars-size-XS.tfvars` settings overrides `variables.tfvars` settings.

6. Select a Terraform workspace. For example, a workspace named `spotfire-dev`.

   ~~~
   terraform spotfire-dev 
   ~~~

7. Prepare the Terraform plan. This step helps to verify the changes before applying them.

   ~~~
   terraform plan -var-file="variables.tfvars" -var-file="vars-size-XS.tfvars"
   ~~~

### Create the required infrastructure (Terraform)

8. If you agree with the Terraform planned changes, apply them to create the infrastructure.

   ~~~
   terraform apply -var-file="variables.tfvars" -var-file="vars-size-XS.tfvars" --auto-approve
   ~~~
   
   Note: This step may take 15-30 minutes depending on the sizing.

### Deploy the Spotfire software (Ansible)

9. Move to the ansible folder:

   ~~~
   cd <this_repo_root>/ansible/
   ~~~

10. Configure the Spotfire deployment by editing the file `config/vars.yml`.

    Note: The variables in `config/vars.yml` are used as defaults and may be override by previous configuration files.

11. Deploy the Spotfire software with the predefined Ansible playbooks for Spotfire.

    ~~~
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
       -i ../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config/host_groups_azure_rm.yml \
       --extra-vars @config/vars.yml \
       --extra-vars @../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config_files/infra.yml \
       site.yml
    ~~~

# Modify the environment 

13. At any time you can modify the configuration and reapply the Terraform planned changes to remove/create/modify the infrastructure.

   ~~~
   terraform apply -var-file="variables.tfvars" -var-file="vars-size-XS.tfvars" --auto-approve
   ~~~
 
14. You can use similar command as previous to just deploy a specific type of servers for example if you just increased the number of instances of that type of server with the Terraform command (e.g. Web Player servers).

    ~~~
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
       -i ../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config/host_groups_azure_rm.yml \
       --extra-vars @config/vars.yml \
       --extra-vars @../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config_files/infra.yml \
       site.yml \
       --limit wp_servers
    ~~~
    
### Destroy the environment

15. Remember to destroy your environment when you are not going to use it to avoid unneeded costs.

    ~~~
    terraform destroy
    ~~~
