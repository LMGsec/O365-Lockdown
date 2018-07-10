<#
Copyright 2018, LMG Security

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE
#>


<# Create the Exchange PS Session #>
$UserCredential = Get-Credential
$Session = New-PSSession –ConfigurationName Microsoft.Exchange –ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential –Authentication Basic -AllowRedirection
Import-PSSession $Session

<# Enable logging for all accounts, enable all owner log actions, and retain for 365 days #>
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditEnabled $true -AuditLogAgeLimit 365
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditOwner Create,HardDelete,MailboxLogin,Move,MoveToDeletedItems,SoftDelete,Update
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditDelegate Create,FolderBind,SendAs,SendOnBehalf,SoftDelete,HardDelete,Update,Move,MoveToDeletedItems,UpdateFolderPermissions
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditAdmin Create, FolderBind,MessageBind,SendAs,SendOnBehalf,SoftDelete,HardDelete,Update,Move,Copy,MoveToDeletedItems,UpdateFolderPermissions

<#
    The following lines will disable POP3 and IMAP access. The same commands can also be used to disable MAPI, EWS, ActiveSync, and OWA access if desired by 
    copying the content on line 18 and replacing "-PopEnabled" with "-MAPIEnabled", "-EWSEnabled", "-ActiveSyncEnalbed", or "-OWAEnabled"
#>

<# Disable POP3 Access. This can be enabled on a per user basis if there is a need for it. Comment out the next line if you dont want to disable POP3 #>
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-CASMailbox -PopEnabled $False

<# Disable IMAP Access. This can be enabled on a per user basis if there is a need for it. Comment out the next line if you dont want to disable IMAP #>
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-CASMailbox -ImapEnabled $False

<#
    The following lines will restrict the ability to auto-forward to an external domain. 
#>

<# Remove any existing forwarding rules #>
Get-Mailbox -filter {(RecipientTypeDetails -ne "DiscoveryMailbox") -and ((ForwardingSmtpAddress -ne $null) -or (ForwardingAddress -ne $null))} | Set-Mailbox -ForwardingSmtpAddress $null -ForwardingAddress $null

<# Remove auto forwarding #>
Set-RemoteDomain Default -AutoForwardEnabled $false

