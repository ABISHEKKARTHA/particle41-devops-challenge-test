provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.project}-${var.environment}-rg"
  location = var.location
  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.project}-${var.environment}-vnet"
  address_space       = [var.address_space]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Subnets
resource "azurerm_subnet" "public1" {
  name                 = "${var.project}-${var.environment}-public1"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 0)]
}

resource "azurerm_subnet" "public2" {
  name                 = "${var.project}-${var.environment}-public2"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 1)]
}

resource "azurerm_subnet" "private1" {
  name                 = "${var.project}-${var.environment}-private1"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 2)]
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "private2" {
  name                 = "${var.project}-${var.environment}-private2"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 3)]
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Application Gateway subnet
resource "azurerm_subnet" "appgw" {
  name                 = "${var.project}-${var.environment}-appgw"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 4)]
}

# Public IP for App Gateway
resource "azurerm_public_ip" "appgw" {
  name                = "${var.project}-${var.environment}-appgw-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Network Profile for container instances
resource "azurerm_network_profile" "aci" {
  name                = "${var.project}-${var.environment}-np"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  container_network_interface {
    name = "aci-nic"

    ip_configuration {
      name      = "aci-ip-config"
      subnet_id = azurerm_subnet.private1.id
    }
  }
}

# Container Instance - Instance 1
resource "azurerm_container_group" "instance1" {
  name                = "${var.project}-${var.environment}-aci-1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_address_type     = "Private"
  network_profile_id  = azurerm_network_profile.aci.id
  os_type             = "Linux"

  container {
    name   = var.project
    image  = var.container_image  # Docker Hub image
    cpu    = var.container_cpu
    memory = var.container_memory

    ports {
      port     = var.container_port
      protocol = "TCP"
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Container Instance - Instance 2
resource "azurerm_container_group" "instance2" {
  name                = "${var.project}-${var.environment}-aci-2"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_address_type     = "Private"
  network_profile_id  = azurerm_network_profile.aci.id
  os_type             = "Linux"

  container {
    name   = var.project
    image  = var.container_image  # Docker Hub image
    cpu    = var.container_cpu
    memory = var.container_memory

    ports {
      port     = var.container_port
      protocol = "TCP"
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Application Gateway
resource "azurerm_application_gateway" "main" {
  name                = "${var.project}-${var.environment}-appgw"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  backend_address_pool {
    name = "backend-pool"
    ip_addresses = [
      azurerm_container_group.instance1.ip_address,
      azurerm_container_group.instance2.ip_address
    ]
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = var.container_port
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "health-probe"
  }

  probe {
    name                = "health-probe"
    host                = "127.0.0.1"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    protocol            = "Http"
    path                = "/"
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-configuration"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 1
  }

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}
