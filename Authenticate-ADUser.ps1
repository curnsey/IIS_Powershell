<#
.Synopsis
   Authenticates user with Domain
.DESCRIPTION
   Take the input of a domain, user, and password and authenticates the user. Returns result (T/F)
.EXAMPLE
   .\Authenticate-ADUser.ps1 -Domain myDomain -User Bob -Password mypassword

#>
param(
    [Parameter(Mandatory=$True)]
    [string] $Domain,
    [Parameter(Mandatory=$True)]
    [string] $User,
    [Parameter(Mandatory=$True)]
    [SecureString] $Password
)

Add-Type -AssemblyName System.DirectoryServices.AccountManagement
$ct = [System.DirectoryServices.AccountManagement.ContextType]::Domain
$pc = New-Object System.DirectoryServices.AccountManagement.PrincipalContext $ct, $Domain
$result = $pc.ValidateCredentials($User, [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)))

if($result){
    Write-Host "User ($User) authenticated." -ForegroundColor green
    #Log the event in Event 1
    Write-EventLog -LogName Application -Source "Authenticate-ADUser" -Message "User ($User) authenticated." -EntryType Information -EventId 26000
}
else{
    Write-Host "User ($User) NOT authenticated." -ForegroundColor red
    #Log the event in Event Viewer
    Write-EventLog -LogName Application -Source "Authenticate-ADUser" -Message "User ($User) NOT authenticated." -EntryType Information -EventId 26001
}
return $result
