#Variables
$SupportFilesPath = "\\13-L0001\c$\TEMP" 
$DevFile = "$SupportFilesPath\developers.txt"
$FTPDirectory = "C$\FTPRoot"
#Backup Website

#TODO


#Select a Developer
Get-Content $DevFile
do{
    $DevName = Read-Host "Which developer is copying a site (from list above)"
} while(!((Get-Content $DevFile).Contains($DevName)))


#Enter Source Location
$Source = Read-Host "Enter the Source Server Name (ie. WEBAPP1VP): "
#Enter Destination Location
$Destination = Read-Host "Enter the Destination Server Name (ie. WEBAPP2VP): "


#Do we want ALL sub folders and files?
do{
    $CopyToDevFTP = Read-Host "Copy files to developers FTP folder (Y/N)? "
}while (!(($CopyToDevFTP.ToUpper() -Match "Y") -or ($CopyToDevFTP.ToUpper() -Match "N")))
Write-Host $CopyToDevFTP


#What sub directory are we looking for?


#Check if destination folder exists, if it does, ARE WE SURE we want to overwrite it? Maybe take a backup?
if (!(Test-Path -path $Destination)) {
    New-Item $Destination -Type Directory
}
else{
    Write-Host "Ok, that directory already exists."
    #TODO # Do we want to create a backup of this directory?
    Write-Host "Let's ask if they want a backup."
    #TODO # Are we sure we want to overwrite?
    Write-Host "Let's make sure they are ok with overwriting."
}


#Do we want ALL sub folders and files?
do{
    $Recurse = Read-Host "Do we want all files in ALL sub directories (Y/N)? "
}while (!(($Recurse.ToUpper() -Match "Y") -or ($Recurse.ToUpper() -Match "N")))
Write-Host $Recurse


#Do we want a filter applied?
$Filter = "*.*"
Write-Host "Let's ask about applying a filter".
#TODO # Get filter from user input


#Copy Items
Copy-Item -Path $Source -Destination $Destination -Recurse -Filter $Filter

#TODO # If/Else for -Recurse Parameter
