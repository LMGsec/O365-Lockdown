## Advice from the LMG Security team
    Enable multi-factor authentication! This is the single most effective method of preventing unauthorized access to your companies email system. 
    We did not build this into the script because it will require some planning before deployment, but it should be done as soon as possible. Here
    is a nice writeup on how to enable this feature - https://blogs.technet.microsoft.com/office365/2015/08/25/powershell-enableenforce-multifactor-authentication-for-all-bulk-users-in-office-365/

## Description
    This is a basic powershell script that can be used to secure an Office 365 environment and enable audit logging. It is offered under the BSD license.
    
    Warning - look at the script before running it. There are parts of this that you might not want to run on your particular system, or you may want to
    add additional items if your organization might benefit from them. Pay particular attention to the section that disables access features like POP3.
    These features can be enabled again on a per user basis if the need is there, but if a large number of users in your organization utilize this protocol
    then you probably dont want to disable it.

    Operations have been tested and verified in our Office 365 testing lab. Please report any issues or suggestions you might have

## Operations performed
    1.) Enable audit logging for all accounts in your organization
    2.) Enable all owner actions as logged events
    3.) Set log retention to 365 days
    4.) Disable POP3 - comment out line 18 if you dont want this
    5.) Disable IMAP - comment out line 21 if you dont want this
    6.) Remove external forwarding inbox rules
    7.) Disable external fowarding at a domain level


## Usage
    The script is designed to be run by an Office 365 administrator. To run the script, open an administrator level powershell window, navigate to the containing
    folder, they execute the following command:
    PS *Path to file*>.\O365-Lockdown.ps1

    You will be prompted for your Office 365 credentials in a popup window. Once these are entered, the script will execute and return to the command prompt

## Verification
    After the initial script runs, the following commands can be used to verify successful execution:

    Check that audit logging has been enabled correctly:
    Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | FL Name,Audit*

    Check that forwarding rules are gone:
    Get-Mailbox -ResultSize Unlimited -Filter {(RecipientTypeDetails -ne "DiscoveryMailbox") -and ((ForwardingSmtpAddress -ne $null) -or (ForwardingAddress -ne $null))} | Select Identity,ForwardingSmtpAddress,ForwardingAddress