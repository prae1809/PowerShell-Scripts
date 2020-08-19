#############################################################################
# Author  : Benoit Lecours 
# Website : www.SystemCenterDudes.com
# Twitter : @scdudes
#
# Version : 1.0
# Created : 2018/12/21
# 
#            
# Purpose : This script copies a device/user collection membership to another device/user
#
#############################################################################


############UserVariable#############################
#
$SiteServer = 'CM01'  ##SCCM Servername
$SiteCode = 'SCD'     ##SCCM Site Code
$Domain = 'SCDLAB'    ##Domain Name (See Asset/User SCCM node)
#
#####################################################

Clear-host
Import-Module -Name "$(split-path $Env:SMS_ADMIN_UI_PATH)\ConfigurationManager.psd1"

$location = $SiteCode + ":"
Set-Location -Path $location

Write-Host "**** Configuration variable ****"
Write-Host "Site Server : $SiteServer"
Write-Host "Site Code   : $SiteCode"
Write-Host "Domain      : $Domain"
Write-Host ""

Write-Host "This script copies a device/user collection membership to another device/user. You will be prompted to confirm at each collection."
Write-Host ""
$UserOrDevice = (Read-Host -Prompt 'Do you want to copy device or user membership ? (Enter Device or User)')
Write-Host ""

##User##
if ($UserOrDevice -eq 'User'){
$ReferenceUser1 = (Read-Host -Prompt 'Enter Reference User login name')
$ReplacementUser1 = (Read-Host -Prompt 'Enter Destination User login name')
$ReferenceUser = $Domain + "\" + $ReferenceUser1
$ReplacementUser = $Domain + "\" + $ReplacementUser1
if(Get-CMUser -Name $ReferenceUser){
    if(Get-CMUser -Name $ReferenceUser){
        $ReplacementID = (get-cmuser | Where-Object {$_.SMSID -eq $ReplacementUser}).ResourceID
        $ResID = (get-cmuser | Where-Object {$_.SMSID -eq $ReferenceUser}).ResourceID
        Get-WmiObject -ComputerName $SiteServer -Class sms_fullcollectionmembership -Namespace root\sms\site_$SiteCode -Filter "ResourceID = '$($ResID)'" | % {
            if(Get-CMUserCollectionDirectMembershipRule -CollectionID $_.CollectionID -ResourceID $ResID){
                $colname = (Get-CMUserCollection -CollectionId $_.CollectionID).Name
                if(!(Get-CMUserCollectionDirectMembershipRule -CollectionID $_.CollectionID -ResourceID $ReplacementID)){
                    $confirm = Read-Host "Do you want to add $ReplacementUser to the collection $colname ? (y/n) "
                    if($confirm -eq "y"){
                        Write-Host "Adding $ReplacementUser to collection $colname" -ForegroundColor 'Green'
                        Add-CMUserCollectionDirectMembershipRule -CollectionId $_.CollectionID -ResourceId $ReplacementID
                    }
                    else {
                        Write-Host "Skipping collection $colname" -ForegroundColor 'Yellow'
                    }
                }
                else {
                    Write-Host "$ReplacementUser is already a member of $colname" -ForegroundColor 'Yellow'
                }
            }
        }
    }
    else {
        Write-Host "Error - Unknown destination user : $ReplacementUser" -ForegroundColor 'Red'
    }
}
else {
    Write-Host "Error - Unknown reference user : $ReferenceUser" -ForegroundColor 'Red'
}
exit
}

##Machine##
if ($UserOrDevice -eq 'Device'){
$ReferenceMachine = (Read-Host -Prompt 'Enter Reference Device Name')
$ReplacementMachine = (Read-Host -Prompt 'Enter Destination Device Name')
if(Get-CMDevice -Name $ReferenceMachine){
    if(Get-CMDevice -Name $ReferenceMachine){
        $ReplacementID = (Get-CMDevice -Name $ReplacementMachine).ResourceID
        $ResID = (Get-CMDevice -Name $ReferenceMachine).ResourceID
        Get-WmiObject -ComputerName $SiteServer -Class sms_fullcollectionmembership -Namespace root\sms\site_$SiteCode -Filter "ResourceID = '$($ResID)'" | % {
            if(Get-CMDeviceCollectionDirectMembershipRule -CollectionID $_.CollectionID -ResourceName $ReferenceMachine){
                $colname = (Get-CMDeviceCollection -CollectionId $_.CollectionID).Name
                if(!(Get-CMDeviceCollectionDirectMembershipRule -CollectionID $_.CollectionID -ResourceName $ReplacementMachine)){
                    $confirm = Read-Host "Do you want to add $ReplacementMachine to the collection $colname ? (y/n) "
                    if($confirm -eq "y"){
                        Write-Host "Adding $ReplacementMachine to collection $colname"  -ForegroundColor 'Green'
                        Add-CMDeviceCollectionDirectMembershipRule -CollectionId $_.CollectionID -ResourceId $ReplacementID
                    }
                    else {
                        Write-Host "Skipping collection $colname" -ForegroundColor 'Yellow'
                    }
                }
                else {
                    Write-Host "$ReplacementMachine is already a member of $colname"  -ForegroundColor 'Yellow'
                }
            }
        }
    }
    else {
        Write-Host "Error - Unknown Destination machine : $ReplacementMachine" -ForegroundColor 'Red'
    }
}
else {
    Write-Host "Error - Unknown reference machine : $ReferenceMachine" -ForegroundColor 'Red'
}
exit
}
