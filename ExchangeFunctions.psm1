function Set-CalendarPermission {
    <#
    .SYNOPSIS
Sets calendar permissions for a user in Company's Office 365 environment
    .DESCRIPTION
Sets calendar permissions for a user in Company's Office 365 environment. If a user doesn't already have the permission
the cmdlet will add the permission.
    .PARAMETER Connect
Use this switch parameter when you need to connect to Exchange. If you do not use this parameter, the cmdlet will
assume you are already connected, and will error out if you are not connected.
    .PARAMETER Identity
The calendar that you want to apply permissions to. Use the format *:\calendar where * is a wildcard for any name
before it ':\calendar'
    .PARAMETER User
The user you want to give permission to
    .PARAMETER AccessRights
What level of permission you'd like to give to the user

The following individual permissions are available:

CreateItems: The user can create items within the specified folder.
CreateSubfolders: The user can create subfolders in the specified folder.
DeleteAllItems: The user can delete all items in the specified folder.
DeleteOwnedItems: The user can only delete items that they created from the specified folder.
EditAllItems: The user can edit all items in the specified folder.
EditOwnedItems: The user can only edit items that they created in the specified folder.
FolderContact: The user is the contact for the specified public folder.
FolderOwner: The user is the owner of the specified folder. The user can view the folder, move the folder and create subfolders. The user can't read items, edit items, delete items or create items.
FolderVisible: The user can view the specified folder, but can't read or edit items within the specified public folder.
ReadItems: The user can read items within the specified folder.

The roles that are available, along with the permissions that they assign, are described in the following list:

Author: CreateItems, DeleteOwnedItems, EditOwnedItems, FolderVisible, ReadItems
Contributor: CreateItems, FolderVisible
Editor: CreateItems, DeleteAllItems, DeleteOwnedItems, EditAllItems, EditOwnedItems, FolderVisible, ReadItems
None: FolderVisible
NonEditingAuthor: CreateItems, FolderVisible, ReadItems
Owner: CreateItems, CreateSubfolders, DeleteAllItems, DeleteOwnedItems, EditAllItems, EditOwnedItems, FolderContact, FolderOwner, FolderVisible, ReadItems
PublishingEditor: CreateItems, CreateSubfolders, DeleteAllItems, DeleteOwnedItems, EditAllItems, EditOwnedItems, FolderVisible, ReadItems
PublishingAuthor: CreateItems, CreateSubfolders, DeleteOwnedItems, EditOwnedItems, FolderVisible, ReadItems
Reviewer: FolderVisible, ReadItems

The following roles apply specifically to calendar folders:

AvailabilityOnly: View only availability data
LimitedDetails: View availability data with subject and location
    .EXAMPLE
Set-CalendarPermission `
-Connect `
-Identity corporatecalendar:\calendar `
-User first.name@example.com `
-AccessRights Reviewer `
-Verbose
#>
    [CmdletBinding()]
    param(
        [switch]$Connect,

        [Parameter(Mandatory = $true)]
        [string]$Identity,

        [Parameter(Mandatory = $true)]
        [string]$User,

        [Parameter(Mandatory = $true)]
        [string]$AccessRights
    )
    BEGIN {
        if ($Connect) {
            Import-Module ExchangeOnlineManagement
            Connect-ExchangeOnline -Credential (Get-Credential)
        } #if
    } #BEGIN

    PROCESS {
        Write-Verbose "Setting Calendar Permission if it already exists"
        try {
            Set-MailboxFolderPermission `
                -Identity $Identity `
                -User $User `
                -AccessRights $AccessRights `
                -SendNotificationToUser $false `
                -ErrorAction Stop
        }
        catch {
            Write-Verbose "Adding MailboxFolderPermission because it did not exist"
            Add-MailboxFolderPermission `
                -Identity $Identity `
                -User $User `
                -AccessRights $AccessRights `
                -SendNotificationToUser $false
        } #trycatch
    } #PROCESS

    END {
        Write-Verbose "Getting Calendar Permission"
        $User = $User.Replace('@example.com', "")
        $User = $User.Replace(".", " ")
        Get-MailboxFolderPermission -Identity $Identity | Where-Object { $_.User -like '*' + $User }
        Write-Verbose "End of function"
    } #END

} #function Set-CalendarPermission

##############################################

function ConvertTo-SharedMailbox {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$address
    )
    foreach ($mailbox in $address) {
        Set-Mailbox -Identity $mailbox -Type Shared
    }

    Write-Host "Waiting 60 seconds until license removal..."
    Start-Sleep -Seconds 60

    foreach ($mailbox in $address) {
        Set-MsolUserLicense -UserPrincipalName $mailbox -RemoveLicenses "company0:EXCHANGESTANDARD"
    } #foreach ConvertTo-SharedMailbox
} #function ConvertTo-SharedMailbox

##############################################

<#
function Set-SharedMailboxPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$address,

        [Parameter(Mandatory = $true)]
        [string]$User
    )
    foreach ($mailbox in $address) {
        Add-MailboxPermission `
            -Identity $mailbox `
            -AccessRights FullAccess `
            -InheritanceType All `
            -AutoMapping:$true `
            -User $user

        Add-RecipientPermission -Identity "$mailbox" -AccessRights SendAs -Trustee "$user" -Confirm:$false
        Set-Mailbox $mailbox -GrantSendOnBehalfTo @{add = "$user" }
    } #foreach Set-SharedMailbox
} #function Set-SharedMailbox
#>

##############################################

function Set-SharedMailboxPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$address,

        [Parameter(Mandatory = $true)]
        [string[]]$User
    )
    foreach ($mailbox in $address) {
        foreach ($account in $user) {
            Add-MailboxPermission `
                -Identity $mailbox `
                -AccessRights FullAccess `
                -InheritanceType All `
                -AutoMapping:$true `
                -User $account

            Add-RecipientPermission -Identity "$mailbox" -AccessRights SendAs -Trustee "$account" -Confirm:$false
            Set-Mailbox $mailbox -GrantSendOnBehalfTo @{add = "$account" }
        } #foreach account in user
    } #foreach mailbox in address
} #function Set-SharedMailboxPermission

##############################################

<#
function Remove-SharedMailboxPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$address,

        [Parameter(Mandatory = $true)]
        [string]$user
    )
    foreach ($mailbox in $address) {
        Remove-MailboxPermission `
            -Identity $mailbox `
            -AccessRights FullAccess `
            -Confirm:$false `
            -User $user

        Remove-RecipientPermission `
            -Identity $mailbox `
            -AccessRights SendAs `
            -Confirm:$false `
            -Trustee $user

        Set-Mailbox $mailbox -GrantSendOnBehalfTo @{remove = "$user" }
    }
} #function Remove-SharedMailbox
#>

##############################################

function Remove-SharedMailboxPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$address,

        [Parameter(Mandatory = $true)]
        [string[]]$user
    )
    foreach ($mailbox in $address) {
        foreach ($account in $user) {
            Remove-MailboxPermission `
                -Identity $mailbox `
                -AccessRights FullAccess `
                -Confirm:$false `
                -User $account

            Remove-RecipientPermission `
                -Identity $mailbox `
                -AccessRights SendAs `
                -Confirm:$false `
                -Trustee $account

            Set-Mailbox $mailbox -GrantSendOnBehalfTo @{remove = $account }
        }
    }
}

##############################################

function Get-SharedMailboxPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$User
    )
    Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited |
    Get-MailboxPermission -User $User |
    Select-Object Identity |
    Sort-Object Identity |
    Format-Table -AutoSize
} #function Get-SharedMailboxPermission

##############################################

function Get-SendOnBehalfOfPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$User
    )
    $User = $User.Replace('@example.com', '')
    Get-Mailbox | 
    Where-Object { $_.GrantSendOnBehalfTo -match "$User" } |
    Select-Object Name |
    Sort-Object Name |
    Format-Table -AutoSize
} #function Get-SendOnBehalfOfPermission

##############################################

function Set-SendOnBehalfOfPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$address,

        [Parameter(Mandatory = $true)]
        [string[]]$User
    )
    foreach ($mailbox in $address) {
        Set-Mailbox $mailbox -GrantSendOnBehalfTo @{add = $User }
    }
} #function Set-SendOnBehalfOfPermission

##############################################

function New-CloudEmail {
    [CmdletBinding()]
    param (
  
        [Parameter(Mandatory = $true)]
        [string]$DisplayName,

        [Parameter(Mandatory = $true)]
        [string]$FirstName,

        [Parameter(Mandatory = $true)]
        [string]$LastName
    )
    Write-Verbose "Importing Module"
    Import-Module MSOnline

    $upn = $FirstName + "." + $LastName + "@example.com"
    Add-Type -AssemblyName 'System.Web'
    $usrpwd = [System.Web.Security.Membership]::GeneratePassword(16, 1)

    Write-Verbose "Creating User Email..."

    New-MsolUser `
        -DisplayName $DisplayName `
        -FirstName $FirstName `
        -LastName $LastName `
        -UserPrincipalName $upn `
        -UsageLocation US `
        -LicenseAssignment company0:EXCHANGESTANDARD `
        -Password "$usrpwd" `
        -ForceChangePassword $false

    Write-Verbose "User Email Created..."
    Get-MsolUser -UserPrincipalName $upn

    Write-Verbose "The users' password is:"
    return $usrpwd
} #function New-CloudEmail