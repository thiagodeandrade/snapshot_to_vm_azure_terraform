# Create VM with snapshot
# First step after create snapshot
# In this case, I have 2 disks, (1)raiz and (2)data
# Create a disk from snapshot. The "source_resource_id" is the name of your snapshot previously created
# My new disk (osDisk), "raiz"
resource "azurerm_managed_disk" "raiz" {
  name = "raiz"
  location = "East US"
  resource_group_name = "your_resource_group"
  # Disk type:
  # Standard_LRS = HDD Standard
  # StandardSSD_LRS = SSD Standard
  # Premium_LRS = SSD Premium
  storage_account_type = "StandardSSD_LRS"
  # option, copy and create a new disk from snapshot
  create_option = "Copy"
  # Snapshot ID
  source_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/your_resource_group/providers/Microsoft.Compute/snapshots/my_snapshot_raiz"
  disk_size_gb = "40"
}
# My new disk (dataDisk), "data"
resource "azurerm_managed_disk" "data" {
  name = "data"
  location = "East US"
  resource_group_name = "your_resource_group"
  storage_account_type = "StandardSSD_LRS"
  create_option = "Copy"
  source_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/your_resource_group/providers/Microsoft.Compute/snapshots/my_snapshot_data"
  disk_size_gb = "40"
}
resource "azurerm_network_security_group" "nsg-mynewvm" {
    name                = "NSG-mynewvm"
    location            = "eastus"
    resource_group_name = "your_resource_group"
    
    security_rule {
        name                       = "SSH Access"
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["22","2222"]
        source_address_prefixes    = ["xxx.xxx.xxx.xxx", "yyy.yyy.yyy.yyy"]
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "WEB Access"
        priority                   = 102
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["80","443"]
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}
# Create public IP to new vm
resource "azurerm_public_ip" "publicip_newvm" {
    name                         = "IP-newvm"
    location                     = "eastus"
    resource_group_name          = "your_resource_group"
    allocation_method            = "Dynamic"
}
# Create interface to VM
resource "azurerm_network_interface" "newnic" {
    name                = "iface-newvm"
    location            = "eastus"
    resource_group_name = "your_resource_group"
    # get NSG created before
    network_security_group_id = "${azurerm_network_security_group.nsg-mynewvm.id}"
ip_configuration {
        name                          = "iplan_newvm"
        subnet_id                     = "/subscriptions/e1f3589e-c1c2-469a-aa1d-c51d0dd73f64/resourceGroups/ORGANIZA/providers/Microsoft.Network/virtualNetworks/NET-Organiza/subnets/LAN-Organiza"
        private_ip_address_allocation = "Dynamic"
        # get public ip created before
        public_ip_address_id          = "${azurerm_public_ip.publicip_newvm.id}"
    }
}
# Create virtual machine
resource "azurerm_virtual_machine" "mynewvm" {
    name                  = "MyNewVM"
    location              = "East US"
    resource_group_name   = "your_resource_group"
    # Type of vm Microsoft Azure
    vm_size               = "Standard_B2S"
    network_interface_ids  = ["${azurerm_network_interface.newnic.id}"]
# Attach new disks
    storage_os_disk {
    name              = "${azurerm_managed_disk.raiz.name}"
    os_type           = "linux"
    disk_size_gb      = "40"
    managed_disk_id   = "${azurerm_managed_disk.raiz.id}"
    create_option     = "Attach"
    }
    storage_data_disk {
    name              = "${azurerm_managed_disk.data.name}"
    lun               = "0"
    disk_size_gb      = "40"
    managed_disk_id   = "${azurerm_managed_disk.data.id}"
    create_option     = "Attach"
    }
}