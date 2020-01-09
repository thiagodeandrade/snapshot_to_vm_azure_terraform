# Snapshot to Virtual Machine with Terraform Scripts
This script create a new Microsoft Azure Virtual Machine from snapshot

# Pre-requisits
Get snapshot IDs from Azure Portal or powershell commands

`Get-AzureRmSnapshot -ResourceGroupName “your_resource_group” -SnapshotName “Snap-Name” | grep “^Id”`

This ID are use on tag **source_resource_id**
