<#############################################################################
Author  : Benoit Lecours 
Website : www.SystemCenterDudes.com
Twitter : @scdudes
Version : 1.0
Created : 2019/12/10

The purposes of this script:
1. Create SCCM device collections based on Active Directory Organisational Unit
2. Define the Refresh Schedule of collection to 7 days
3. Create Query Rule for collection membership
4. Move created collection to custom folder
5. Updates collection membership at once.
##############################################################################>

# Import PS modules
Import-Module ActiveDirectory
Import-Module 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'

# SCCM Site
$Site = (Get-PSDRive -PSProvider CMSite).Name
CD ${Site}:

# Defining refresh interval for collection - 7 days
$Schedule = New-CMSchedule –RecurInterval Days –RecurCount 7

##Get User Inputs for Base OU
$Users = Get-ADOrganizationalUnit -Filter * -Properties DistinguishedName,CanonicalName |Select-Object DistinguishedName,CanonicalName
Clear-Host
Write-Host "Here's the list of all OU in your Organisation".ToUpper()
Write-Host ""

For ($i=0; $i -lt $Users.Count; $i++)  {
  Write-Host "$($i+1): $($Users[$i].CanonicalName)"
}

Write-Host ""
[int]$number = Read-Host "Select the number corresponding to the desired top-most OU".ToUpper()
Write-Host ""
Write-Host -ForegroundColor Green "You've selected $($users[$number-1].CanonicalName). The script will create 1 collection for each OU under the selected OU.:".ToUpper()
$SearchBase = $($Users[$number-1]).DistinguishedName


#Get User Input for folder
Write-Host ""
$folderName = Read-Host "Enter the desired folder name. The folder will be created under the Device Collection Node and all collections will be moved to the folder"
New-Item -Name $folderName -Path "${Site}:\DeviceCollection"
$TargetFolder = "${Site}:\DeviceCollection\$folderName"


#Getting Canonical name and GUID from AD OUs based on user input
$ADOUs = Get-ADOrganizationalUnit -SearchBase "$SearchBase" -Filter * -Properties Canonicalname |Select-Object DistinguishedName,CanonicalName

#Create Collections

foreach ($OU in $ADOUs)
{
    $O_Name = $OU.CanonicalName
    $O_GUID = $OU.ObjectGUID

Try
{
    New-CMDeviceCollection -LimitingCollectionName 'All Systems' -Name $O_Name -RefreshSchedule $Schedule -Comment $O_GUID | Out-Null
    Write-host *** Collection $O_Name created ***
}
Catch
{
    Write-host -ForegroundColor Red ("There was an error creating the: " + $O_Name + " collection. Possible cause is that there's already a collection with that name.")
}

# Creating Query Membership rule
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $O_Name -QueryExpression "select *  from  SMS_R_System where SMS_R_System.SystemOUName = '$O_Name'" -RuleName "OU Membership" | Out-Null

# Getting collection ID
$ColID = (Get-CMDeviceCollection -Name $O_Name).collectionid

# Moving collection to folder
Try
{
    Move-CMObject -FolderPath $TargetFolder -ObjectId "$ColID"
    Write-host *** Collection $O_Name moved to the $folderName folder ***
}
Catch
{
    Write-host -ForegroundColor Red ("There was an error moving the: " + $O_Name + " collection.")
}

# Updating collection membership
Invoke-CMDeviceCollectionUpdate -Name $O_Name
}
Write-Host ""
Write-host *** SCRIPT COMPLETED ***
