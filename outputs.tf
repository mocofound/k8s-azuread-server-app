output "azure_ad_object_id" {
  value = "${data.azuread_application.test.id}"
}
