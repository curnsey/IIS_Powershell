<#
.Synopsis
   List web applications on server
.DESCRIPTION
   This script lists all web applications in IIS on the given server
.PARAMETER
  -Server: Servername
.PARAMETER
  -UserName: name of user you want to connect with. Default is Administrator
.PARAMETER
  -List: List of properties to pull back. Default list is Path, PhysicalPath, ApplicationPool, EnabledProtocols
.EXAMPLE
  PS C:\> .\List-WebApplications.ps1 -Server webserver1 -UserName "Admin"
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Server,
    [string]$UserName = "Administrator",
    [string[]]$List = ("Path", "PhysicalPath", "ApplicationPool", "EnabledProtocols")
)

#Create credentials for session
$cred = (Get-Credential "$Server\$UserName")

#Create Session
$session = new-pssession -computername $Server -credential $cred

#Import the Web Administration tools for Source server
#Any commands now ran for WebAdministration Tools will be ran on Server (iis as prefix)
Import-PSSession -Session $session -Module WebAdministrAtion -prefix iis

#Provide Developer with list of Applications
Get-iisWebApplication | select "Path","PhysicalPath","ApplicationPool","enabledprotocols" | Format-Table

#Lastly, remove the session
Remove-PSSession -session $session
