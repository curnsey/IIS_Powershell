<#
.Synopsis
   Replicate Web application
.DESCRIPTION
   Replicates a website from staging server to the other production web servers.
.EXAMPLE
   .\ReplicateSite.ps1 -Recurse Y -Overwrite Y

#>
param(   
    [string] $Recurse = "Y",
    [string] $Overwrite = "N"
)
#
# Currently only copying forward the files in the virtual directory
# Next step - copying the new web configuration
#


#Variables
$Server = "webserver1"
$domain = "domain"
$DestServers = Get-Content "C:\Scripts\servers.txt"
$BackupName = (Get-Date -format "yyyy-MM-dd_HHmmss")+"_$User"

if($env:USERNAME.ToUpper() -match "ADMINISTRATOR"){
    Write-Warning "Log in as yourself to run script."
    return
}
$User = $env:USERNAME.ToLower()
$Password = Read-Host "Password for $User" -AsSecureString
$Authenticated = (.\Authenticate-ADUser.ps1 -Domain $domain -User $User -Password $Password)
if(-Not $Authenticated){
    Write-Host "Sorry $User, but we can't authenticate you. Exiting." -ForegroundColor Red
    return
}

#Provide Developer with list of Applications
$apps = Get-WebApplication

#Format Table
$a = @{Expression={[array]::IndexOf($apps, $_)};Label="Id";width=3},
@{Expression={$_.ApplicationPool};Label="App Pool";width=25},
@{Expression={$_.Path};Label="App Path";width=25},
@{Expression={$_.EnabledProtocols};Label="Protocol";width=15},
@{Expression={$_.PhysicalPath};Label="Physical Path";width=50}

#Output Web Applications
$apps | Format-Table $a

#Get Application Id - force the user to select an existing item in the list
do{
Write-Host "Enter the ID of your Application you would like to migrate: " -ForegroundColor green -NoNewline
$WebApplicationToMigrate = Read-Host
} while([convert]::ToInt32($WebApplicationToMigrate) -lt 0 -or [convert]::ToInt32($WebApplicationToMigrate) -ge $apps.Length)
$myApp = $apps[$WebApplicationToMigrate]

#Print out their selection
$myApp | Format-Table $a
Write-Warning ("About to replicate the site "+$myApp.Path +". Replicating this site will replace all existing files located on "+($DestServers -join ",")+" in the application's physical path.")

#Let the user confirm that they want to proceed
do{
Write-Host "Please confirm that you would like to proceed (Y/N)? " -ForegroundColor Red  -NoNewline
$Confirm = Read-Host
}while (!(($Confirm.ToUpper() -Match "Y") -or ($Confirm.ToUpper() -Match "N")))

#Confirm that they said Yes
if($Confirm.ToUpper() -Match "N"){
Write-Output "Replication was aborted! Exiting."
return
}

#Create Backup
Write-Output "Backing up IIS Configuration as '$BackupName'."
Backup-WebConfiguration -Name $BackupName
$BackupMsg = ("$User ran backup of IIS through ReplicationSite.ps1 script.")
#Log the event in Event Viewer
Write-EventLog -LogName Application -Source "Replication Site Script" -Message $BackupMsg -EntryType Information -EventId 26100

#Replication Process
Write-Output ("Replicating files to "+($DestServers -join ",")+".")
$DestServers | foreach{ 
    $dServer = $_
    #Build Destination UNC Path
    $dPath = ("\\$dServer\"+$myApp.PhysicalPath.Replace('C:', "c$"))
    Write-Host "Copying files to $dServer." -ForegroundColor Green
    #Check if Path exists
    if(-Not (Test-Path $dPath)){
        #Create path
        Write-Warning "Path does not exist. Creating path '$dPath'."
        $gc = New-Item -ItemType directory -Path $dPath
    } 
        
    #Copy Items
    if($Overwrite.ToUpper() -Match "Y" -and $Recurse.ToUpper() -Match "Y"){
        Copy-Item -Path ($myApp.PhysicalPath+"\*") -Destination $dPath -Recurse -Force
    }
    elseif($Overwrite.ToUpper() -Match "Y"){
        Copy-Item -Path ($myApp.PhysicalPath+"\*") -Destination $dPath -Force
    }
    elseif($Recurse.ToUpper() -Match "Y"){
        Copy-Item -Path ($myApp.PhysicalPath+"\*") -Destination $dPath -Recurse
    }
    else{
        Copy-Item -Path ($myApp.PhysicalPath+"\*") -Destination $dPath
    }
}


