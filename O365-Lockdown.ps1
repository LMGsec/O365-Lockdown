<# Create the Exchange PS Session #>
$UserCredential = Get-Credential
$Session = New-PSSession –ConfigurationName Microsoft.Exchange –ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential –Authentication Basic -AllowRedirection
Import-PSSession $Session

<# Enable logging for all accounts, enable all owner log actions, and retain for 365 days #>
Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true
Set-AdminAuditLogConfig -AdminAuditLogAgeLimit 365.00:00:00
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditEnabled $true -AuditLogAgeLimit 365
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditOwner Create,HardDelete,MailboxLogin,Move,MoveToDeletedItems,SoftDelete,Update
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditDelegate Create,FolderBind,SendAs,SendOnBehalf,SoftDelete,HardDelete,Update,Move,MoveToDeletedItems,UpdateFolderPermissions
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditAdmin Create, FolderBind,MessageBind,SendAs,SendOnBehalf,SoftDelete,HardDelete,Update,Move,Copy,MoveToDeletedItems,UpdateFolderPermissions

Write-Host "Audit logging activation results"
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Select Name,Audit*
<#
    The following lines will disable various mailbox access methods. Each line will prompt for input prior to shutting down access.
#>

<# Disable Outlook Web Access. This can be enabled on a per user basis if there is a need for it #>
Write-Host "Would you like to disable Outlook Web Access? y/n"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost)
{
    y {Write-Host "Outlook Web Access Disabled"; Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-CASMailbox -OWAEnabled $False}
    Default {Write-Host "Outlook Web Access still active"}
}

<# Disable ActiveSync. This can be enabled on a per user basis if there is a need for it #>
Write-Host "Would you like to disable ActiveSync? y/n"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost)
{
    y {Write-Host "ActiveSync Disabled"; Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-CASMailbox -ActiveSyncEnalbed $False}
    Default {Write-Host "ActiveSync still active"}
}

<# Disable MAPI Access. This can be enabled on a per user basis if there is a need for it #>
Write-Host "Would you like to disable MAPI access? y/n"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost)
{
    y {Write-Host "MAPI Disabled"; Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-CASMailbox -MAPIEnabled $False}
    Default {Write-Host "MAPI still active"}
}

<# Disable EWS Access. This can be enabled on a per user basis if there is a need for it #>
Write-Host "Would you like to disable EWS access? y/n"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost)
{
    y {Write-Host "EWS Disabled"; Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-CASMailbox -EWSEnabled $False}
    Default {Write-Host "EWS still active"}
}

<# Disable POP3 Access. This can be enabled on a per user basis if there is a need for it #>
Write-Host "Would you like to disable POP3 access? y/n"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost)
{
    y {Write-Host "POP3 Disabled"; Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-CASMailbox -PopEnabled $False}
    Default {Write-Host "POP3 still active"}
}

<# Disable IMAP Access. This can be enabled on a per user basis if there is a need for it #>
Write-Host "Would you like to disable IMAP access? y/n"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost)
{
    y {Write-Host "IMAP Disabled"; Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-CASMailbox -ImapEnabled $False}
    Default {Write-Host "IMAP still active"}
}

<#
    The following lines will restrict the ability to auto-forward to an external domain. Manual forwarding is still possible.
#>

<# Remove any existing forwarding rules at the users discretion #>
$Forwards = Get-Mailbox -ResultSize Unlimited -Filter {(RecipientTypeDetails -ne "DiscoveryMailbox") -and ((ForwardingSmtpAddress -ne $null) -or (ForwardingAddress -ne $null))} | Select Identity,ForwardingSmtpAddress,ForwardingAddress

foreach($Forward in $Forwards)
{   
    Write-Host "Forwarding address found. " $Forward.Identity " forwards to " $Forward.ForwardingAddress " " $Forward.ForwardingSmtpAddress ". Would you like to remove it?  y/n"
    $ReadHost = Read-Host " ( y / n ) "
    Switch($ReadHost)
    {
        y {Write-Host "Deleting"; Set-Mailbox -Identity $Forward.Identity -ForwardingSmtpAddress $null -ForwardingAddress $null}
        n {Write-Host "Skipping"}
        Default {Write-Host "Skipping"}
    }
}

<# Remove auto forwarding #>
Write-Host "Would you like to disable automatic forwarding completely? y/n"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost)
{
    y {Write-Host "Forwarding Disabled"; Set-RemoteDomain Default -AutoForwardEnabled $false}
    Default {Write-Host "Forwards still active"; Get-Mailbox -ResultSize Unlimited -Filter {(RecipientTypeDetails -ne "DiscoveryMailbox") -and ((ForwardingSmtpAddress -ne $null) -or (ForwardingAddress -ne $null))} | Select Identity,ForwardingSmtpAddress,ForwardingAddress}
}

