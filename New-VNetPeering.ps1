Import-Module Az
Connect-AzAccount
Disconnect-AzAccount

New-AzResourceGroup -Name 'vnetpeer' -Location 'EastUS'

$subnet1 = New-AzVirtualNetworkSubnetConfig -Name subnet1 -AddressPrefix "10.0.1.0/24"
$vnet = @{
    Name              = 'vnet1'
    ResourceGroupName = 'vnetpeer'
    Location          = 'EastUS'
    AddressPrefix     = '10.0.0.0/16'
    Subnet            = $subnet1
}
New-AzVirtualNetwork @vnet

$subnet2 = New-AzVirtualNetworkSubnetConfig -Name subnet2 -AddressPrefix "192.168.1.0/24"
$vnet2 = @{
    Name              = 'vnet2'
    ResourceGroupName = 'vnetpeer'
    Location          = 'EastUS'
    AddressPrefix     = '192.168.0.0/16'
    Subnet            = $subnet2
}
New-AzVirtualNetwork @vnet2

$vm1 = @{
    Credential         = (Get-Credential)
    Name               = 'vm1'
    ResourceGroupName  = 'vnetpeer'
    Location           = 'EastUS'
    Image              = 'UbuntuLTS'
    OpenPorts          = 22
    VirtualNetworkName = 'vnet1'
    SubnetName         = 'subnet1'
}
New-AzVM @vm1

$vm2 = @{
    Credential         = (Get-Credential)
    Name               = 'vm2'
    ResourceGroupName  = 'vnetpeer'
    Location           = 'EastUS'
    Image              = 'UbuntuLTS'
    OpenPorts          = 22
    VirtualNetworkName = 'vnet2'
    SubnetName         = 'subnet2'
}
New-AzVM @vm2

$ParentVnet = Get-AzVirtualNetwork -Name vnet1
$RemoteVnet = Get-AzVirtualNetwork -Name vnet2
Add-AzVirtualNetworkPeering `
    -Name myVirtualNetwork1-myVirtualNetwork2 `
    -VirtualNetwork $ParentVnet `
    -RemoteVirtualNetworkId $RemoteVnet.id

Add-AzVirtualNetworkPeering `
    -Name myVirtualNetwork2-myVirtualNetwork1 `
    -VirtualNetwork $RemoteVnet `
    -RemoteVirtualNetworkId $ParentVnet.id

#test connection: (on-prem > vm1 > vm2)
Get-AzVm | Get-AzPublicIpAddress | Select-Object Name,IpAddress

ssh azureadmin@xx.xxx.xxx.xxx
