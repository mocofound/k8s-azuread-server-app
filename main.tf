# Configure the Microsoft Azure Active Directory Provider
provider "azuread" {
  #version = "=0.3.0"
}

#ToDo Maybe: az ad app permission grant --id $serverApplicationId --api 00000003-0000-0000-c000-000000000000
#ToDo Probably: az ad app permission admin-consent --id  $serverApplicationId
#https://docs.microsoft.com/en-us/azure/aks/azure-ad-integration-cli
#https://docs.microsoft.com/en-us/azure/aks/azure-ad-integration


resource "azuread_application" "server" {
  name                       = "k8s-azuread-rbac-server-app"
  homepage                   = "https://myaksserver"
  identifier_uris            = ["https://myaksserver"]
  reply_urls                 = ["https://replyurlserver"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
  type                       = "webapp/api"
  group_membership_claims    = "All"

  /*
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
      type = "Role"
    }
    resource_access {
      id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }

    resource_access {
      id = "06da0dbc-49e2-44d2-8312-53f166ab848a"
      type = "Scope"
    }
  }
    /*
/*
  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    resource_access {
      id = "..."
      type = "Scope"
    }
  }
  */
}
/*
oAuthPermissionId=$(az ad app show --id $serverApplicationId --query "oauth2Permissions[0].id" -o tsv)
Add the permissions for the client application and server application components to use the oAuth2 communication flow using the az ad app permission add command. Then, grant permissions for the client application to communication with the server application using the az ad app permission grant command:

Azure CLI

Copy

Try It
az ad app permission add --id $clientApplicationId --api $serverApplicationId --api-permissions $oAuthPermissionId=Scope
az ad app permission grant --id $clientApplicationId --api $serverApplicationId
  */


resource "azuread_application" "client" {
  name                       = "k8s azuread rbac server app"
  #homepage                   = "https://myakssclient"
  #identifier_uris            = ["https://myaksclient"]
  reply_urls                 = ["https://replyurlclient"]
  #available_to_other_tenants = false
  #oauth2_allow_implicit_flow = true
  type                       = "native"
/*
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
      type = "Role"
    }
    resource_access {
      id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }

    resource_access {
      id = "06da0dbc-49e2-44d2-8312-53f166ab848a"
      type = "Scope"
    }
  }
  
  */
  required_resource_access {
    resource_app_id = "${azuread_application.server.application_id}"

    resource_access {
      id = "${azuread_application.server.oauth2_permissions[0].id}"
      type = "Scope"
    }
  }

}

resource "azuread_service_principal" "server" {
  application_id = "${azuread_application.server.application_id}"
}

resource "azuread_service_principal" "client" {
  application_id = "${azuread_application.client.application_id}"
}

resource "azuread_service_principal_password" "server" {
  service_principal_id = "${azuread_service_principal.server.id}"
  value                = var.azuread_service_principal_password_string
  end_date             = "2020-01-01T01:02:03Z"
}

variable "azuread_service_principal_password_string" {
  type = string
}

# Azure Resource Group
resource "azurerm_resource_group" "k8sexample" {
  name     = "${var.resource_group_name}"
  location = "${var.azure_location}"
}

# Azure Container Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "k8sexample" {
  name = "${var.vault_user}-k8sexample-cluster"
  location = "${azurerm_resource_group.k8sexample.location}"
  resource_group_name = "${azurerm_resource_group.k8sexample.name}"
  dns_prefix = "${var.dns_prefix}"
  kubernetes_version = "${var.k8s_version}"

  linux_profile {
    admin_username = "${var.admin_user}"
    ssh_key {
      key_data = "${chomp(tls_private_key.ssh_key.public_key_openssh)}"
    }
  }

  agent_pool_profile {
    name       = "${var.agent_pool_name}"
    count      =  "${var.agent_count}"
    os_type    = "${var.os_type}"
    os_disk_size_gb = "${var.os_disk_size}"
    vm_size    = "${var.vm_size}"
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

    role_based_access_control {
    enabled = true
    azure_active_directory {
            server_app_id     = "${azuread_application.server.application_id}"
            server_app_secret = "${var.azuread_service_principal_password_string}"
            client_app_id     = "${azuread_application.client.application_id}"
            tenant_id         = "${var.tenant_id}"
    }
  }
}
  
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}
