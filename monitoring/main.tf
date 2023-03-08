
# data "kubectl_file_documents" "secret" {
#   content = file("manifests/apikey.yaml")
# }

# resource "kubectl_manifest" "secret" {
#   for_each   = data.kubectl_file_documents.secret.manifests
#   yaml_body  = each.value
#   provisioner "local-exec" {
#     command = "sleep 10"
#   }
# }

data "kubectl_file_documents" "exporter" {
  content = file("manifests/elasticsearch-exporter.yaml")
}

resource "kubectl_manifest" "exporter" {
  for_each   = data.kubectl_file_documents.exporter.manifests
  yaml_body  = each.value
  # depends_on = [kubectl_manifest.secret]
  # lifecycle {
  #   replace_triggered_by = [
  #     kubectl_manifest.secret.id
  #   ]
  # }
}

data "kubectl_file_documents" "podmonitoring" {
  content = file("manifests/podmonitoring.yaml")
}

resource "kubectl_manifest" "podmonitoring" {
  for_each   = data.kubectl_file_documents.podmonitoring.manifests
  yaml_body  = each.value
  depends_on = [kubectl_manifest.exporter]
}

