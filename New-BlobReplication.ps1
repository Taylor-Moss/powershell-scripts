<#
.SYNOPSIS
Creates redundant storage by replication two blob containers across two different regions.
.DESCRIPTION
Change feed: Must be enabled on the source account.
Blob versioning: Must be enabled on both the source and destination accounts.
.PARAMETER ResourceGroupName
Specify the resource group name you want to create
.PARAMETER ResourceGroupLocation
Specify the location of the newly created resource group
.PARAMETER SourceLocation
Specify the location of the source storage account
.PARAMETER DestinationLocation
Specify the location of the destination storage account
.PARAMETER SkuName
Type of storage accounts
.PARAMETER AccessTier
The access tier of the storage accounts Hot, Cold, or Archive
.PARAMETER SourceAccountName
Name of the source storage account
.PARAMETER DestinationAccountName
Name of the destination storage account
.PARAMETER SourceContainerName
Name of the source container
.PARAMETER DestinationContainerName
Name of the destination container
.PARAMETER Connected
Switch parameter. Use this if you are already connected to Azure.
.EXAMPLE
New-BlobReplication `
-ResourceGroupName "example" `
-SourceLocation "South Central US" `
-DestinationLocation "East US" `
-SkuName "Standard_LRS" `
-AccessTier "Hot" `
-ResourceGroupLocation "South Central US" `
-SourceContainerName "large1" `
-DestinationContainerName "large2" `
-SourceAccountName "taylorstestsource" `
-DestinationAccountName "taylortestdest"
#>
function New-BlobReplication {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory=$True)]
        [string]$ResourceGroupLocation,

        [Parameter(Mandatory=$True)]
        [string]$SourceLocation,

        [Parameter(Mandatory=$True)]
        [string]$DestinationLocation,

        [Parameter(Mandatory=$True)]
        [string]$SkuName,

        [Parameter(Mandatory=$True)]
        [ValidateSet('Hot','Cold','Archive')]
        [string]$AccessTier,

        [Parameter(Mandatory=$True)]
        [string]$SourceAccountName,

        [Parameter(Mandatory=$True)]
        [string]$DestinationAccountName,

        [Parameter(Mandatory=$True)]
        [string]$SourceContainerName,

        [Parameter(Mandatory=$True)]
        [string]$DestinationContainerName,

        [switch]$Connected
    )

BEGIN{}

PROCESS{

$SourceAccountName = $SourceAccountName.ToLower()
$DestinationAccountName = $DestinationAccountName.ToLower()

Import-Module Az
if (!$Connected) {
    Connect-AzAccount
}
#create resource group
New-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation

#create two storage accounts (one south central us, the other east us)
New-AzStorageAccount `
-ResourceGroupName $ResourceGroupName `
-Name $SourceAccountName `
-Location $SourceLocation `
-SkuName $SkuName `
-AccessTier $AccessTier

New-AzStorageAccount `
-ResourceGroupName $ResourceGroupName `
-Name $DestinationAccountName `
-Location $DestinationLocation `
-SkuName $SkuName `
-AccessTier $AccessTier

#create the containers in both storage accounts
Get-AzStorageAccount `
-ResourceGroupName $ResourceGroupName `
-StorageAccountName $SourceAccountName | `
New-AzStorageContainer $SourceContainerName

Get-AzStorageAccount `
-ResourceGroupName $ResourceGroupName `
-StorageAccountName $DestinationAccountName | `
New-AzStorageContainer $DestinationContainerName

#enable blob versioning and change feed on source account
Update-AzStorageBlobServiceProperty `
-ResourceGroupName $ResourceGroupName `
-StorageAccountName $SourceAccountName `
-EnableChangeFeed $true `
-IsVersioningEnabled $true

#enable blob versioning on destination account
Update-AzStorageBlobServiceProperty `
-ResourceGroupName $ResourceGroupName `
-StorageAccountName $DestinationAccountName `
-IsVersioningEnabled $true

#create replication rules and policy between source and storage accounts
$prefixrule = New-AzStorageObjectReplicationPolicyRule `
-SourceContainer $SourceContainerName `
-DestinationContainer $DestinationContainerName
 
$policies = Set-AzStorageObjectReplicationPolicy `
-ResourceGroupName $ResourceGroupName `
-StorageAccountName $DestinationAccountName `
-PolicyId default `
-SourceAccount $SourceAccountName `
-Rule $prefixrule
 
Set-AzStorageObjectReplicationPolicy -ResourceGroupName $ResourceGroupName `
-StorageAccountName $SourceAccountName `
-InputObject $policies

} #PROCESS

END{}

} #function