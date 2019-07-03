# Configure the Microsoft Azure Active Directory Provider
provider "azuread" {
  version = "=0.3.0"
}


resource "azuread_application" "server" {
  name                       = "k8s azuread rbac server app"
  homepage                   = "https://myaksserver"
  identifier_uris            = ["https://myaksserver"]
  reply_urls                 = ["https://replyurlserver"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
  type                       = "webapp/api"

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
      type = "Role"
    }
    resource_access {
      id = ".e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }

    resource_access {
      id = "06da0dbc-49e2-44d2-8312-53f166ab848a"
      type = "Scope"
    }
  }

  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    resource_access {
      id = "..."
      type = "Scope"
    }
  }
}

resource "azuread_application" "client" {
  name                       = "k8s azuread rbac server app"
  homepage                   = "https://myakssclient"
  identifier_uris            = ["https://myaksclient"]
  reply_urls                 = ["https://replyurlclient"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
  type                       = "webapp/api"

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
      type = "Role"
    }
    resource_access {
      id = ".e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }

    resource_access {
      id = "06da0dbc-49e2-44d2-8312-53f166ab848a"
      type = "Scope"
    }
  }

  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    resource_access {
      id = "..."
      type = "Scope"
    }
  }
}
