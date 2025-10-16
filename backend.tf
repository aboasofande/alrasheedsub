terraform {
  backend "azurerm" {
    resource_group_name  = "alrasheed10-tfstate"
    storage_account_name = "alrasheed10storageacc"
    container_name       = "alrasheed10-tfstate"
    key                  = "terraform.tfstate"
  }
}