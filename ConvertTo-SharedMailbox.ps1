$creds = Get-Credential email@example.com

Import-Module MSOnline
Connect-MsolService -Credential $creds -Verbose
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -Credential $creds -Verbose

$mailboxes = @(
    'domain1@example.com'
    'domain2@example.com'
    'domain3@example.com'
    'domain4@example.com'
    'domain5@example.com'
    'domain6@example.com' 
)

foreach ($mailbox in $mailboxes) {
    Set-Mailbox -Identity $mailbox -Type Shared -Confirm
}

Write-Host "Waiting 60 seconds until license removal..."
Start-Sleep -Seconds 60

foreach ($mailbox in $mailboxes) {
    Set-MsolUserLicense -UserPrincipalName $mailbox -RemoveLicenses "EXCHANGESTANDARD"
}