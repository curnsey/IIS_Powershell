<#
.Synopsis
   List web applications on server
.DESCRIPTION
   This script lists all web applications in IIS on the given server
.EXAMPLE
  .\List-WebApplications.ps1 -Server webserver1 -UserName "Admin" -List "Path", "PhysicalPath"
#>
 [CmdletBinding()]
 param(
     [Parameter(Mandatory=$True)]
     [string]$Server,
     [string]$UserName = "Administrator",
     [string[]]$List = ("Path", "PhysicalPath", "ApplicationPool", "EnabledProtocols")
 )

 #Create credentials for session
 $cred = (Get-Credential "$Server\$UserName")
 
 #Create Session
 $session = new-pssession -computername $Server -credential $cred

 #Import the Web Administration tools for Source server
 #Any commands now ran for WebAdmin will be ran on Staging Server
 Import-PSSession -Session $session -Module WebAdministrAtion -prefix iis

 #Provide user with list of Applications
 Get-iisWebApplication | select $List | Format-Table

 #Lastly, remove the session
 Remove-PSSession -session $session
