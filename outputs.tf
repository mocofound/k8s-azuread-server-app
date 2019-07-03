output "azure_ad_object_id_server" {
  value = "${k8s_azuread_application.server.id}"
}

output "azure_ad_object_id_client" {
  value = "${k8s_azuread_application.client.id}"
}
