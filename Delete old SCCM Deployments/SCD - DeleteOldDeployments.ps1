#############################################################################
# Author  : Benoit Lecours 
# Website : www.SystemCenterDudes.com
# Twitter : @scdudes
#
# Version : 1.0
# Created : 2018/06/05
# Modified : 
#
# Purpose : This script delete deploymentsolder than the specified date
#
#############################################################################

#Load Configuration Manager PowerShell Module
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

#Get SiteCode
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-location $SiteCode":"
Clear-Host

Write-host "--------------- SYSTEM CENTER DUDES - DELETE OLD DEPLOYMENTS ----------------`n"
Write-host "This script deletes SCCM deployments older than the number of days specified.`n"
Write-Host "The script is based on Creation Date. The user will be prompted before each deletion.`n" -ForegroundColor Yellow
$SCCMServer = Read-Host "Enter your SCCM server Name"
$UserDate = Read-Host "Delete deployments older than how many days ? (ex: 365 = 1 year)"
$DeleteDate = (Get-Date).AddDays(-$UserDate)
Write-Host ""
Write-host "-------------------------------------------------------------------------------------"
Write-Host "Building Deployment List older than " -NoNewline; Write-Host $DeleteDate.ToShortDateString() -ForegroundColor Red -NoNewline; Write-Host " This may take a couple of minutes...";
Write-host "-------------------------------------------------------------------------------------`n"

$DeploymentList = Get-CMDeployment | Where-Object {$_.CreationTime -le $Deletedate}
$DeploymentNumber=0
Write-Host ("Found " + $DeploymentList.Count + " deployments older than specified date`n") -ForegroundColor Yellow

foreach ($Deployment in $DeploymentList)
{
    $DeploymentID = $Deployment.DeploymentID
    $DeploymentName = $Deployment.ApplicationName
    $DeploymentNumber++
               
    # User Prompt
    Write-Host ""
    Write-host "--------------- " -NoNewline; Write-host "DEPLOYMENT #"$DeploymentNumber -ForegroundColor Red -NoNewline; Write-host " ---------------------------------------------------------"
    Write-Host ("Deployment Name: " + $DeploymentName) 
    Write-Host ("Targetted Collection: " + $Deployment.CollectionName)
    Write-Host ("Deployment ID: " + $Deployment.DeploymentID)
    Write-Host ("Creation Date: " + $Deployment.CreationTime)
    Write-Host ("Deployment Time: " + $Deployment.DeploymentTime)
    Write-Host ("Enforcement Deadline: " + $Deployment.EnforcementDeadline)
    Write-Host ("Feature Type: " + $Deployment.FeatureType)
    Write-host "----------------------------------------------------------------------------------------`n"

    # User Confirmation
    If ((Read-Host -Prompt "Type `"Y`" to delete the deployment, any other key to skip") -ieq "Y")
    {
      Try
            {
                #Delete the deployment based on the Deployment Feature Type
                Switch ($Deployment.FeatureType) 
                {
                    #Application
                    1{Remove-CMDeployment -DeploymentId $DeploymentID -ApplicationName $DeploymentName -ErrorAction Stop -Force
                    Write-Host "Sucessfully Deleted Application Deployment #"$DeploymentNumber -ForegroundColor Green -BackgroundColor Black}
                    
                    # Package/Program
                    2{                
                    $AdvertFilter = "AdvertisementID='$DeploymentID'"
                    #gwmi sms_advertisement -Namespace $SiteNamespace -ComputerName $SiteServer -filter $advertFilter | % {$_.Delete()}
                    Get-WmiObject -Namespace "root\sms\site_$sitecode" -ComputerName $SCCMServer -class SMS_Advertisement -filter $advertFilter -ErrorAction stop | % {$_.Delete()}
                    Write-Host "Sucessfully Deleted Program Deployment #"$DeploymentNumber -ForegroundColor Green -BackgroundColor Black}
                    
                    #Software Update
                    5{   
                    $AdvertFilter = "AssignmentUniqueID='$DeploymentID'"
                    #gwmi SMS_UpdatesAssignment -Namespace $SiteNamespace -ComputerName $SiteServer -filter $advertFilter | % {$_.Delete()}
                    Get-WmiObject -Namespace "root\sms\site_$sitecode" -ComputerName $SCCMServer -class SMS_UpdatesAssignment -filter $advertFilter -ErrorAction stop | % {$_.Delete()}
                    Write-Host "Sucessfully Deleted Software Update Deployment #"$DeploymentNumber -ForegroundColor Green -BackgroundColor Black}

                    #Baseline
                    6{
                    $AdvertFilter = "AssignmentUniqueID='$DeploymentID'"
                    #gwmi sms_baselineassignment -Namespace $SiteNamespace -ComputerName $SiteServer -filter $advertFilter | % {$_.Delete()}
                    Get-WmiObject -Namespace "root\sms\site_$sitecode" -ComputerName $SCCMServer -class SMS_baselineassignment -filter $advertFilter -ErrorAction stop | % {$_.Delete()}
                    Write-Host "Sucessfully Deleted Baseline Deployment #"$DeploymentNumber -ForegroundColor Green -BackgroundColor Black}

                    #Task Sequence
                    7{
                    $AdvertFilter = "AdvertisementID='$DeploymentID'"
                    #gwmi sms_advertisement -Namespace $SiteNamespace -ComputerName $SiteServer -filter $advertFilter | % {$_.Delete()}
                    Get-WmiObject -Namespace "root\sms\site_$sitecode" -ComputerName $SCCMServer -class SMS_Advertisement -filter $advertFilter -ErrorAction stop | % {$_.Delete()}
                    Write-Host "Sucessfully Deleted Task Sequence Deployment #"$DeploymentNumber -ForegroundColor Green -BackgroundColor Black}

                    Default {
                    Write-Host ("Feature Type not supported" + $Deployment.FeatureType)}
                 }
            }
       Catch{Write-Host "Can't delete deployment #"$DeploymentNumber -ForegroundColor Red -BackgroundColor Black }    
    }
}

