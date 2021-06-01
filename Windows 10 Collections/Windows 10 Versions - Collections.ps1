#############################################################################
# Author  : Benoit Lecours 
# Website : www.SystemCenterDudes.com
# Twitter : @scdudes @benoitlecours
#
# Version : 1.0
# Created : 2021/06/1
#            
# Purpose : This script create a set of SCCM Windows 10 collections and move it in an "Windows 10 - Versions" folder
#
#############################################################################

#Load Configuration Manager PowerShell Module
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5)+ '\ConfigurationManager.psd1')

#Get SiteCode
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-location $SiteCode":"

#Error Handling and output
Clear-Host
$ErrorActionPreference= 'SilentlyContinue'

#Create Default Folder 
$CollectionFolder = @{Name ="Windows 10 - Versions"; ObjectType =5000; ParentContainerNodeId =0}
Set-WmiInstance -Namespace "root\sms\site_$($SiteCode.Name)" -Class "SMS_ObjectContainerNode" -Arguments $CollectionFolder -ComputerName $SiteCode.Root
$FolderPath =($SiteCode.Name +":\DeviceCollection\" + $CollectionFolder.Name)
Write-host *** Windows 10 - Versions folder has been created ***

#Set Default limiting collections
$LimitingCollection ="All Systems"

#Refresh Schedule
$Schedule =New-CMSchedule –RecurInterval Days –RecurCount 7


#Find Existing Collections
$ExistingCollections = Get-CMDeviceCollection -Name "*Windows 10*" | Select-Object CollectionID, Name

#List of Collections Query
$DummyObject = New-Object -TypeName PSObject 
$Collections = @()


$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"All Windows 10"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build like '10%' and SMS_R_System.OperatingSystemNameandVersion like '%Workstation%'"}},@{L="LimitingCollection"
; E={"$LimitingCollection"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows 10 v1507"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.10240'"}},@{L="LimitingCollection"
; E={"All Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system v1507"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows 10 v1511"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.10586'"}},@{L="LimitingCollection"
; E={"All Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system v1511"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows 10 v1607"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.14393'"}},@{L="LimitingCollection"
; E={"All Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system v1607"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows 10 v1703"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.15063'"}},@{L="LimitingCollection"
; E={"All Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system v1703"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows 10 v1709"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.16299'"}},@{L="LimitingCollection"
; E={"All Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system v1709"}}


##Collection 83
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows 10 v1803"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build = '10.0.17134'"}},@{L="LimitingCollection"
; E={"All Windows 10"}},@{L="Comment"
; E={"Windows 10 v1803"}}

##Collection 93
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows 10 v1809"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build = '10.0.17763'"}},@{L="LimitingCollection"
; E={"All Windows 10"}},@{L="Comment"
; E={"Windows 10 v1809"}}

##Collection 94
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows 10 v1903"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build = '10.0.18362'"}},@{L="LimitingCollection"
; E={"All Windows 10"}},@{L="Comment"
; E={"Windows 10 v1903"}}

##Collection 100
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows 10 v1909"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build = '10.0.18363'"}},@{L="LimitingCollection"
; E={"All Windows 10"}},@{L="Comment"
; E={"Windows 10 v1909"}}

##Collection 100
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows 10 v2004"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build = '10.0.19041'"}},@{L="LimitingCollection"
; E={"All Windows 10"}},@{L="Comment"
; E={"Windows 10 v2004"}}

##Collection 100
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows 10 v20H2"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build = '10.0.19042'"}},@{L="LimitingCollection"
; E={"All Windows 10"}},@{L="Comment"
; E={"Windows 10 v20H2"}}

##Collection 100
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows 10 v21H1"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build = '10.0.19043'"}},@{L="LimitingCollection"
; E={"All Windows 10"}},@{L="Comment"
; E={"Windows 10 v21H1"}}


$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows 10 v21H2"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build = '10.0.21390'"}},@{L="LimitingCollection"
; E={"All Windows 10"}},@{L="Comment"
; E={"Windows 10 v21H2"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows 10 Not on Latest build (21H1)"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build != '10.0.19042'"}},@{L="LimitingCollection"
; E={"All Windows 10"}},@{L="Comment"
; E={"Windows 10 v21H2"}}




#############################################

#Check Existing Collections
$Overwrite = 1
$ErrorCount = 0
$ErrorHeader = "The script has already been run. The following collections already exist in your environment:`n`r"
$ErrorCollections = @()
$ErrorFooter = "Would you like to delete and recreate the collections above? (Default : No) "
$ExistingCollections | Sort-Object Name | ForEach-Object {If($Collections.Name -Contains $_.Name) {$ErrorCount +=1 ; $ErrorCollections += $_.Name}}

#Error
If ($ErrorCount -ge1) 
    {
    Write-Host $ErrorHeader $($ErrorCollections | ForEach-Object {(" " + $_ + "`n`r")}) $ErrorFooter -ForegroundColor Yellow -NoNewline
    $ConfirmOverwrite = Read-Host "[Y/N]"
    If ($ConfirmOverwrite -ne "Y") {$Overwrite =0}
    }

#Create Collection And Move the collection to the right folder
If ($Overwrite -eq1) {
$ErrorCount =0

ForEach ($Collection In $($Collections))# | Sort-Object LimitingCollection -Descending))

{
If ($ErrorCollections -Contains $Collection.Name)
    {
    Get-CMDeviceCollection -Name $Collection.Name | Remove-CMDeviceCollection -Force
    Write-host *** Collection $Collection.Name removed and will be recreated ***
    }
}

ForEach ($Collection In $($Collections))# | Sort-Object LimitingCollection))
{

Try 
    {
    New-CMDeviceCollection -Name $Collection.Name -Comment $Collection.Comment -LimitingCollectionName $Collection.LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection.Name -QueryExpression $Collection.Query -RuleName $Collection.Name
    Write-host *** Collection $Collection.Name created ***
    }

Catch {
        Write-host "-----------------"
        Write-host -ForegroundColor Red ("There was an error creating the: " + $Collection.Name + " collection.")
        Write-host "-----------------"
        $ErrorCount += 1
        Pause
}

Try {
        Move-CMObject -FolderPath $FolderPath -InputObject $(Get-CMDeviceCollection -Name $Collection.Name)
        Write-host *** Collection $Collection.Name moved to $CollectionFolder.Name folder***
    }

Catch {
        Write-host "-----------------"
        Write-host -ForegroundColor Red ("There was an error moving the: " + $Collection.Name +" collection to " + $CollectionFolder.Name +".")
        Write-host "-----------------"
        $ErrorCount += 1
        Pause
      }

}

If ($ErrorCount -ge1) {

        Write-host "-----------------"
        Write-Host -ForegroundColor Red "The script execution completed, but with errors."
        Write-host "-----------------"
        Pause
}

Else{
        Write-host "-----------------"
        Write-Host -ForegroundColor Green "Script execution completed without error. Windows 10 Collections created sucessfully."
        Write-host "-----------------"
        Pause
    }
}

Else {
        Write-host "-----------------"
        Write-host -ForegroundColor Red ("The following collections already exist in your environment:`n`r" + $($ErrorCollections | ForEach-Object {(" " +$_ + "`n`r")}) + "Please delete all collections manually or rename them before re-executing the script! You can also select Y to do it automaticaly")
        Write-host "-----------------"
        Pause
}
