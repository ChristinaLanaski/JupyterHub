resource "azurerm_resource_group" "jupyter" {
  name = var.jupyter_rgp
  location = var.location
}
resource "azurerm_kubernetes_cluster" "jupyter" {
  name                = var.jupyter_cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.jupyter.name
  dns_prefix          = "jupyteraks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.jupyter.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.jupyter.kube_config_raw

  sensitive = true
}