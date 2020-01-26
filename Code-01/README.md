Assumptions
------------
1. No monitoring required
2. No logging required
3. No code deployment required, default landing page is ok
4. Performance is not required, free tier can be used
5. No Terraform state management required, local state is ok
5. Basic Terraform knowledge
6. Azure knowledge

Requirements
------------
1. Azure Subscription
2. Account with at least Contributor access to the Azure Subscription
3. Azure CLI or Azure Cloud Shell
    - Installation guide: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
    - Or, use chocolatey to install: choco install azure-cli
4. Terraform 0.12.20+
    - Can be downloaded from: https://www.terraform.io/downloads.html
    - Or, use chocolatey to install: choco install terraform
    - Available on Azure Cloud Shell (Bash or Powershell)
5. Internet Connection
    - Preferrably run from a system that doesn't require a proxy to go out the internet
    - If proxy is required, configure "netsh winttp set proxy" or proxy environment variables
    - AzureRM provider can also be used with Azure Service Principal by uncommenting and populating the block (line 34-37)

Steps
------------
1. Login to Azure using Azure CLI or through Azure Cloud Shell
    - Command: az login
2. If there are multiple subscription, set the account
    - Command: az account set -s [Subscription Name or ID]
3. Change directory to where the main.tf is extracted/downloaded
4. Run Terraform Plan
    - Review the plan, and confirm values are ok
    - Variables can be bypassed using: var = 'foo=bar' (can be set multiple times)
5. Run Terraform Apply
    - Type "yes" to proceed
6. There will be an output for website_url, site should be accessible within seconds, browse away!
7. Run Terraform Destroy to delete the deployed resources
    - Ensure this is ran on the same directory during plan/apply (state file will be located there)
    - Type "yes" to proceed
