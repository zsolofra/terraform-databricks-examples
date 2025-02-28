//dpcp pvt endpoint
resource "azurerm_private_endpoint" "dpcp" {
  name                = "dpcppvtendpoint"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.plsubnet.id //private link subnet, in databricks spoke vnet

  private_service_connection {
    name                           = "ple-${var.workspace_prefix}-dpcp"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-dpcp"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdpcp.id]
  }
}

resource "azurerm_private_dns_zone" "dnsdpcp" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dpcpdnszonevnetlink" {
  name                  = "dpcpspokevnetconnection"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsdpcp.name
  virtual_network_id    = azurerm_virtual_network.this.id // connect to spoke vnet
}

resource "azurerm_private_endpoint" "auth" {
  name                = "aadauthpvtendpoint"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.plsubnet.id //private link subnet, in databricks spoke vnet

  private_service_connection {
    name                           = "ple-${var.workspace_prefix}-auth"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["browser_authentication"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-auth"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdpcp.id]
  }
}

//dbfs pvt endpoint
resource "azurerm_private_endpoint" "dbfspe" {
  name                = "dbfspvtendpoint"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.plsubnet.id //private link subnet, in databricks spoke vnet


  private_service_connection {
    name                           = "ple-${var.workspace_prefix}-dbfs"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/${local.dbfsname}"])
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-dbfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdbfs.id]
  }
}
resource "azurerm_private_dns_zone" "dnsdbfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dbfsdnszonevnetlink" {
  name                  = "dbfsspokevnetconnection"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsdbfs.name
  virtual_network_id    = azurerm_virtual_network.this.id // connect to spoke vnet
}
