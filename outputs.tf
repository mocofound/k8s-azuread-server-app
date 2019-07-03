output "azure_ad_object_id_server" {
  value = "$azuread_application.server.id}"
}

output "azure_ad_object_id_client" {
  value = "${azuread_application.client.id}"
}
