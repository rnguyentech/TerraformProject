# Set variables
$resourceGroupName = "terraform-rg"
$location = "eastus"
$storageAccountName = "tfstate$(Get-Random -Minimum 10000 -Maximum 99999)"
$containerName = "tfstate"

# Create resource group
az group create --name $resourceGroupName --location $location

# Create storage account
az storage account create --name $storageAccountName `
    --resource-group $resourceGroupName `
    --location $location `
    --sku Standard_LRS `
    --encryption-services blob

# Retrieve storage key
$accountKey = az storage account keys list `
    --resource-group $resourceGroupName `
    --account-name $storageAccountName `
    --query "[0].value" `
    --output tsv

# Create blob container
az storage container create `
    --name $containerName `
    --account-name $storageAccountName `
    --account-key $accountKey

# Output Terraform backend config
@"
resource_group_name  = `"$resourceGroupName`"
storage_account_name = `"$storageAccountName`"
container_name       = `"$containerName`"
key                  = `"dev.terraform.tfstate`"
"@