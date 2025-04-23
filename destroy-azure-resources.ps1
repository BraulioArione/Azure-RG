$resourceGroupName = "Dev-RG"
Connect-AzAccount
Select-AzSubscription -SubscriptionId "57f91af3-98f9-40b3-b418-355d5ed48460"

# Step 1: Delete VMs
$vms = Get-AzVM -ResourceGroupName $resourceGroupName
foreach ($vm in $vms) {
    Write-Host "Deleting VM: $($vm.Name)"
    Remove-AzVM -Name $vm.Name -ResourceGroupName $resourceGroupName -Force
}

# Step 2: Delete NICs
$nics = Get-AzNetworkInterface -ResourceGroupName $resourceGroupName
foreach ($nic in $nics) {
    Write-Host "Deleting NIC: $($nic.Name)"
    Remove-AzNetworkInterface -Name $nic.Name -ResourceGroupName $resourceGroupName -Force
}

# Step 3: Delete Public IPs
$pips = Get-AzPublicIpAddress -ResourceGroupName $resourceGroupName
foreach ($pip in $pips) {
    Write-Host "Deleting Public IP: $($pip.Name)"
    Remove-AzPublicIpAddress -Name $pip.Name -ResourceGroupName $resourceGroupName -Force
}

# Step 4: Delete NSGs
$nsgs = Get-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName
foreach ($nsg in $nsgs) {
    Write-Host "Deleting NSG: $($nsg.Name)"
    Remove-AzNetworkSecurityGroup -Name $nsg.Name -ResourceGroupName $resourceGroupName -Force
}

# Step 5: Delete VNETs (and subnets)
$vnets = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName
foreach ($vnet in $vnets) {
    Write-Host "Deleting VNET: $($vnet.Name)"
    Remove-AzVirtualNetwork -Name $vnet.Name -ResourceGroupName $resourceGroupName -Force
}

# Step 6: Delete storage, SQL, webapps, etc.
$resources = Get-AzResource -ResourceGroupName $resourceGroupName
foreach ($res in $resources) {
    Write-Host "Deleting remaining: $($res.Name) ($($res.ResourceType))"
    Remove-AzResource -ResourceId $res.ResourceId -Force
}

