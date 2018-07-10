<# Create the Exchange PS Session #>
$UserCredential = Get-Credential
$Session = New-PSSession –ConfigurationName Microsoft.Exchange –ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential –Authentication Basic -AllowRedirection
Import-PSSession $Session

<# Enable logging for all accounts, enable all owner log actions, and retain for 365 days #>
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditEnabled $true -AuditLogAgeLimit 365
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditOwner Create,HardDelete,MailboxLogin,Move,MoveToDeletedItems,SoftDelete,Update
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditDelegate Create,FolderBind,SendAs,SendOnBehalf,SoftDelete,HardDelete,Update,Move,MoveToDeletedItems,UpdateFolderPermissions
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditAdmin Create, FolderBind,MessageBind,SendAs,SendOnBehalf,SoftDelete,HardDelete,Update,Move,Copy,MoveToDeletedItems,UpdateFolderPermissions

Write-Host "Audit logging activation results"
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Select Name,Audit*
<#
    The following lines will disable POP3 and IMAP access. The same commands can also be used to disable MAPI, EWS, ActiveSync, and OWA access if desired by 
    copying the content on line 18 and replacing "-PopEnabled" with "-MAPIEnabled", "-EWSEnabled", "-ActiveSyncEnalbed", or "-OWAEnabled"
#>

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
    The following lines will restrict the ability to auto-forward to an external domain. 
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
        Defuault {Write-Host "Skipping"}
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

