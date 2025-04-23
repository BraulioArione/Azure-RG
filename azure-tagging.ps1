# Login and set the context
#
Connect-AzAccount
$subscriptionId = "57f91af3-98f9-40b3-b418-355d5ed48460"  # Example subscription ID
Select-AzSubscription -SubscriptionId $subscriptionId

# Default values if tags are missing
$defaultOwner = "unassigned@example.com"
$defaultChargeback = "UNDEFINED"
$usageTag = "UsagePattern"

# Resource group definitions ( defining resource Group names, locations, and tags)
$resourceGroups = @(
    [PSCustomObject]@{
        ResourceGroupName = "Dev-RG"
        Location = "UK South"
        Tags = @{ Owner = "dev.team@example.com"; ChargebackCode = "DEV1001" }
    },
    [PSCustomObject]@{
        ResourceGroupName = "Prod-RG"
        Location = "WestEurope"
        Tags = @{ Owner = "prod.team@example.com"; ChargebackCode = "PRD3003" }
    }
)

# Resource definitions by resource group
$resourceData = @{
    "Dev-RG" = @(
        @{ Name = "dev-vm01"; Type = "VM"; Location = "UK South" },
        @{ Name = "devstorage01"; Type = "Storage"; Location = "UK South" }
    )
    "Prod-RG" = @(
        @{ Name = "prodsql01"; Type = "SQL"; Location = "WestEurope" },
        @{ Name = "prodweb01"; Type = "WebApp"; Location = "WestEurope" }
    )
}

# Create Resource Groups
foreach ($rg in $resourceGroups) {
    Write-Host "Creating Resource Group: $($rg.ResourceGroupName) in $($rg.Location)"
    New-AzResourceGroup -Name $rg.ResourceGroupName -Location $rg.Location -Tag $rg.Tags
}

# Create Resources
foreach ($group in $resourceData.Keys) {
    foreach ($res in $resourceData[$group]) {
        switch ($res.Type) {
            "VM" {
                Write-Host "Creating VM: $($res.Name) in $group"
                New-AzVM -Name $res.Name -ResourceGroupName $group -Location $res.Location -ImageName "Win2019Datacenter" -Credential (Get-Credential) -PublicIpAddressName "$($res.Name)-ip" -OpenPorts 3389
            }
            "Storage" {
                Write-Host "Creating Storage Account: $($res.Name) in $group"
                New-AzStorageAccount -ResourceGroupName $group -Name $res.Name.ToLower() -Location $res.Location -SkuName Standard_LRS -Kind StorageV2
            }
            "SQL" {
                Write-Host "Creating SQL Server: $($res.Name) in $group"
                New-AzSqlServer -ResourceGroupName $group -ServerName $res.Name -Location $res.Location -SqlAdministratorCredentials (Get-Credential)
            }
            "WebApp" {
                Write-Host "Creating App Service Plan and Web App: $($res.Name) in $group"
                $aspName = "$($res.Name)-asp"
                New-AzAppServicePlan -Name $aspName -Location $res.Location -ResourceGroupName $group -Tier "Basic" -NumberofWorkers 1
                New-AzWebApp -Name $res.Name -ResourceGroupName $group -Location $res.Location -AppServicePlan $aspName
            }
        }
    }
}

Write-Host "All resources and resource groups created."

