
data "kubectl_file_documents" "secret" {
  content = file("manifests/apikey.yaml")
}

resource "kubectl_manifest" "secret" {
  for_each   = data.kubectl_file_documents.exporter.manifests
  yaml_body  = each.value
}

data "kubectl_file_documents" "exporter" {
  content = file("manifests/elasticsearch-exporter.yaml")
}

resource "kubectl_manifest" "exporter" {
  for_each   = data.kubectl_file_documents.exporter.manifests
  yaml_body  = each.value
  depends_on = [kubectl_manifest.secret]
}

data "kubectl_file_documents" "podmonitoring" {
  content = file("manifests/elasticsearch-exporter.yaml")
}

resource "kubectl_manifest" "podmonitoring" {
  for_each   = data.kubectl_file_documents.podmonitoring.manifests
  yaml_body  = each.value
  depends_on = [kubectl_manifest.exporter]
}

