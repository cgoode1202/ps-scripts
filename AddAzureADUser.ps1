# Connect to Azure AD
Connect-AzureAD

# Create a password object
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile

# Assign the password
$PasswordProfile.Password = "<Password>"

# Identify the name of your Azure AD tenant
$domainName = ((Get-AzureAdTenantDetail).VerifiedDomains)[0].Name

# Create the new user
New-AzureADUser -DisplayName 'Isabel Garcia' -PasswordProfile "$passwordProfile" -UserPrincipalName "Isabel@$domainName" -AccountEnabled $true -MailNickName 'Isabel'

# Create a new group
New-AzureADGroup -Description "Marketing" -DisplayName "Marketing" -MailEnabled $false -SecurityEnabled $true -MailNickName "Marketing"

# Get role information
Get-AzRoleDefinition Owner

# Create a new security group
New-AzureADGroup -DisplayName 'Junior Admins' -MailEnabled $false -SecurityEnabled $true -MailNickName JuniorAdmins

# List groups in your AAD tenant
Get-AzureADGroup

# Add a member to a group
$user = Get-AzureADUser -Filter "MailNickName eq 'Isabel'"
Add-AzADGroupMember -MemberUserPrincipalName $user.userPrincipalName -TargetGroupDisplayName "Junior Admins"
Add-AzureADGroupMember -ObjectId "<Group Object Id" -RefObjectId "User Object Id"

# Add an owner to a group
Add-AzureADGroupOwner -ObjectId "<Group Object Id" -RefObjectId "User Object Id"

# List details of a role
Get-AzRoleDefinition -Name '<roleName>'

# Sync on-prem AD updates with Azure AD
Import-Module -Name 'C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1'

Start-ADSyncSyncCycle -PolicyType Delta