## Description
    This is a simple Powershell script that can be used to better secure an Office 365 environment and 
    enable audit logging. It is offered under the BSD license. 
    
    Operations have been tested and verified in LMG Security's Office 365 testing lab. Use at your own 
    risk. Please report any issues or suggestions you might have in the "Issues" section. 

## Operations performed
This script takes the following actions:

    1.) Enables audit logging for all accounts in your organization
    2.) Enables all owner actions as logged events
    3.) Sets log retention to 365 days
    4.) Allows the user to disable several mailbox access methods
    5.) Removes external forwarding inbox rules
    6.) Disables external fowarding at a domain level

## Why are these things important?

    > 1.) Enables audit logging for all accounts in your organization
    Audit logging is not enabled by default, and it's not retroactive. If you need to investigate suspicious 
    activity, you must have already enabled audit logging to have easy access to log data.
 
    >2.) Enables all owner actions as logged events
    Not all audit logging capabilities are enabled when you enable audit logging (really). It's a pain in the 
    neck, and this fixes it.

    >3.) Sets log retention to 365 days
    Normal retention time is 90 days. This makes it longer. Feel free to set the retention time even longer (or shorter) 
    based on your organization's needs. 

    > 4.) Disables POP3, IMAP, MAPI, EWS, ActiveSync, and OWA as needed. 
    Access methods like IMAP and POP3 are just other ways that attackers can potentially access your account. If you 
    don't need them, turn them off. The script will prompt and ask you if you want to disable each access method before 
    taking action.

    > 5.) Removes external forwarding inbox rules
    External forwarding rules are often installed by attackers seeking to retain copies of user mail. Other times, users 
    themselves set up these rules to easily access work email from home, in violation of policy. The script will prompt and 
    ask you if you want to remove a particular rule before deleting it. 

    > 6.) Disables external fowarding at a domain level
    This makes it so that if you delete a user's forwarding rules, they cannot go back and re-enter the rule. Furthermore, 
    unauthorized users cannot add forwarding rules without first changing this global setting. 

## WARNING
    Carefully review at the script before running it. There are parts of this that you might not want to run on your 
    particular system, or you may want to add additional items if your organization might benefit from them. Pay 
    particular attention to the section that disables access features like POP3. These features can be enabled again 
    on a per user basis if the need is there, but if a large number of users in your organization utilize this protocol
    then you probably dont want to disable it. 

## Usage
    The script is designed to be run by an Office 365 administrator. To run the script, open an administrator level 
    powershell window, navigate to the containing folder, they execute the following command:
    PS *Path to file*>.\O365-Lockdown.ps1

    You will be prompted for your Office 365 administrative credentials in a popup window. Once these are entered, the script will 
    execute and return to the command prompt.

## Verification
    After the initial script runs, the following commands can be used to verify successful execution:

    Check that audit logging has been enabled correctly:
    Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | FL Name,Audit*

    Check that forwarding rules are gone:
    Get-Mailbox -ResultSize Unlimited -Filter {(RecipientTypeDetails -ne "DiscoveryMailbox") -and ((ForwardingSmtpAddress -ne $null) -or (ForwardingAddress -ne $null))} | Select Identity,ForwardingSmtpAddress,ForwardingAddress

## Advice from the LMG Security team
    One important thing this script does not address is multi-factor authentication. At LMG, we STRONGLY urge you to enable 
    multi-factor authentication! This is the single most effective method of preventing unauthorized access to your organization's email 
    system. We did not build this into the script because it will require some planning 
    before deployment, but it should be done as soon as possible. Here is a nice writeup on how to enable this feature: 
    https://blogs.technet.microsoft.com/office365/2015/08/25/powershell-enableenforce-multifactor-authentication-for-all-bulk-users-in-office-365/
