#############################################################
# This script allows :
# - Change all reports datasource that are located in a specific SSRS folder. The script will point on the default SCCM DataSource - {5C6358F2-4BB6-4a1b-A16E-8D96795D8602}
# - Upload all reports (.RDL) from a specific folder to your SCCM Reporting Point
# - Download all reports that are located in a specific SSRS folder created on an SCCM Reporting Point.
#
# 4 users variables are needed before the script to be run
# 
# Credit for the originals Script : 
# Datasource : https://stackoverflow.com/questions/9178685/change-datasource-of-ssrs-report-with-powershell
# Upload : https://kohera.be/blog/sql-server/automated-deployment-ssrs-reports-powershell/
# Download : https://sqlbelle.com/2011/03/28/how-to-download-all-your-ssrs-report-definitions-rdl-files-using-powershell/
#
# Tested on SQL 2012 and 2016
#
# System Center Dudes - www.SystemCenterDudes.com
# Benoit Lecours
# 2018/04/06
# Version 1.0
##############################################################


function Show-Menu
{
     param (
           [string]$Title = 'System Center Dudes - Report Manager Tool'
     )
     cls
     Write-Host "================ $Title ================"
     Write-Host ""
     Write-Host "1: Upload Reports to SCCM Reporting Server"
     Write-Host "2: Download Reports from SCCM Reporting Server"
     Write-Host "3: Change DataSource of All Reports in a SSRS Folder"
     Write-Host ""
     Write-Host "Q: Quit"
}

do
{
     Show-Menu
     Write-Host ""
     $input = Read-Host "What do you want to do?"
     switch ($input)
     {
        '1'
        {      
        ###################### 1 - UPLOAD ######################################################################

        #Remove Users Variable
        Remove-Variable * -ErrorAction SilentlyContinue

        Clear-Host
        $ErrorActionPreference= 'SilentlyContinue'
        $Error1 = 0

        $ReportServer = Read-Host "Enter your SCCM Reporting Point server name"
        $SiteCode = Read-Host "Enter your SCCM Site Code"
        $SSRSFolder = Read-Host "Enter the destination SSRS folder name"

        Write-Host "Select the source folder name containing the reports to upload"

        Add-Type -AssemblyName System.Windows.Forms
        $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $FolderBrowser.Description = 'Select the folder containing the reports'
        $result = $FolderBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
        if ($result -eq [Windows.Forms.DialogResult]::OK){
            $SourceDirectory = $FolderBrowser.SelectedPath
        }
        else {
           Write-Host "Cancel button pushed. Exiting script"
        }

        #Reports with the same name will be overwritten
        $IsOverwriteReport = 1
        $ReportFolder = "/ConfigMgr_" + $SiteCode +"/" + $SSRSFolder

        try{
        $webServiceUrl = "http://$($ReportServer)/reportserver/reportservice2010.asmx?WSDL";
        $ssrsProxy= New-WebServiceProxy -uri $webServiceUrl -UseDefaultCredential

        #############################
        #For each RDL file in Folder

        #Check if SSRSfolder exists
        $SSRSroot = "/ConfigMgr_" + $SiteCode
        $folderList = $ssrsProxy.ListChildren($SSRSroot, $true) | Select -Property Path, TypeName | Where-Object {$_.Path -eq "$ReportFolder"} | Select Path
        if(!$folderList)
        {Write-host "Folder does not exists on SSRS server. Exiting script." -ForegroundColor Red
        pause
        Exit
        }else{}


        $directoryInfo = Get-ChildItem $SourceDirectory -Filter *.rdl | Measure-Object
        $NumberofRDL = $directoryInfo.count

        If ($directoryInfo.count -eq 0)
        {write-host "Folder does not contains any RDL files. Exiting script." -ForegroundColor Red
        pause
        Exit
        }
        Else{
        Write-Host ""
        Write-Host "Folder contains $NumberofRDL RDL files"
        Write-Host ""
        } #Returns the count of all of the files in the directory

        foreach($rdlfile in Get-ChildItem $SourceDirectory -Filter *.rdl)
        {
        #ReportName
        $reportName = [System.IO.Path]::GetFileNameWithoutExtension($rdlFile);
        Write-host "--- Report $reportName" -ForegroundColor Yellow

        #Upload File
        try
        {
        #Get Report content in bytes
        Write-Host "Reading file : $rdlFile"
        $byteArray = gc $rdlFile.FullName -encoding byte
        $msg = "Total length: {0}" -f $byteArray.Length
        #Write-Host $msg

        Write-Host "Uploading report to:" $ReportFolder.ToUpper()

        $type = $ssrsProxy.GetType().Namespace
        $datatype = ($type + '.Property')

        $DescProp = New-Object($datatype)
        $DescProp.Name = 'Description'
        $DescProp.Value = ''
        $HiddenProp = New-Object($datatype)
        $HiddenProp.Name = 'Hidden'
        $HiddenProp.Value = 'false'
        $Properties = @($DescProp, $HiddenProp)

        #Call Proxy to upload report

        $warnings = $null

        $Results = $ssrsProxy.CreateCatalogItem("Report", $reportName,$ReportFolder, $IsOverwriteReport,$byteArray,$Properties,[ref]$warnings) 


        if($warnings.length -le 1)
        { 
        Write-Host ""
        Write-Host "--- $reportName Uploaded Successfully." -ForegroundColor Green
        }
        else
        { Write-host "--- Warnings were returned but report may have uploaded successfully" -ForegroundColor Yellow
        }

        }
        catch [System.IO.IOException]
        {
        $msg = "Error while reading rdl file : '{0}', Message: '{1}'" -f $rdlFile, $_.Exception.Message
        Write-Error msg
        }
        catch [System.Web.Services.Protocols.SoapException]
        {

        $msg = "Error uploading report: $reportName. Msg: '{0}'" -f $_.Exception.Detail.InnerText
        Write-Error $msg
        }
        }
        }
        catch{
        $Error1 = 1
        }
        Finally{
            If ($Error1 -eq 1){
        
                Write-host "-----------------"
                Write-host -ForegroundColor Red "Unable to connect to SSRS Server, Server name, Site Code or Folder Name incorrect."
                Write-host "-----------------"
        
            }
            Else{
                 Write-Host " "
                    Write-Host "Reports files downloaded to"$FullSubFolderName.ToUpper()""        
                }
                }
        }
        #####################################################################################

        '2'
        {


        ######################### 2- DOWNLOAD ###################################################

        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Xml.XmlDocument");
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.IO");

        #Remove Users Variable
        Remove-Variable * -ErrorAction SilentlyContinue

        Clear-Host
        $ErrorActionPreference= 'SilentlyContinue'
        $Error1 = 0
 
        # -------------User Variables--------------------------------------------
        #Report Server Name
        $ReportServer = Read-Host "Enter your SCCM Reporting Point server name"
        #SiteCode
        $SiteCode = Read-Host "Enter your SCCM Site Code"
        #SSRS Folder to target
        $SSRSFolder = Read-Host "Enter your SSRS folder name that contains the reports. (Leave empty for all SCCM Reports)"
        if (!$SSRSFolder)
        {$ReportFolderPath = "/ConfigMgr_" + $SiteCode + $SSRSFolder}
        else
        {$ReportFolderPath = "/ConfigMgr_" + $SiteCode +"/" + $SSRSFolder}

        #Connecting to ReportingPoint
        try{
        $ReportServerUri = "http://$($ReportServer)/reportserver/reportservice2010.asmx?WSDL";
        $Proxy = New-WebServiceProxy -uri $ReportServerUri -Namespace SSRS.ReportingService2010 -UseDefaultCredential
        #------------------------------------------------------------------------

        #Get all reports from folder
        $items = $Proxy.ListChildren("$ReportFolderPath", $true) | select Type,TypeName, Path, ID, Name | Where-Object {$_.typeName -eq "Report"};
 
        #Create a new folder where we will save the files
        $folderName = Read-Host "Enter the folder name to save the reports"
        $fullFolderName = "C:\Temp\" + $folderName;
        [System.IO.Directory]::CreateDirectory($fullFolderName) | out-null
        Write-Host " "
 
        foreach($item in $items)
        {
            #need to figure out if it has a folder name
            $subfolderName = split-path $item.Path;
            $reportName = split-path $item.Path -Leaf;
            $fullSubfolderName = $fullFolderName + $subfolderName;
            if(-not(Test-Path $fullSubfolderName))
            {
                #note this will create the full folder hierarchy
                [System.IO.Directory]::CreateDirectory($fullSubfolderName) | out-null
            }
 
            $rdlFile = New-Object System.Xml.XmlDocument;
            [byte[]] $reportDefinition = $null;
            #$reportDefinition = $Proxy.GetReportDefinition($item.Path);
            $reportDefinition = $Proxy.GetItemDefinition($item.Path)
 
            [System.IO.MemoryStream] $memStream = New-Object System.IO.MemoryStream(@(,$reportDefinition));
            $rdlFile.Load($memStream);
 
            $fullReportFileName = $fullSubfolderName + "\" + $item.Name +  ".rdl";
            #Write-Host $fullReportFileName;
            $rdlFile.Save( $fullReportFileName);
            Write-Host "--- $ReportName downloaded" -ForegroundColor Green
 
        }

        }
        catch{
        $Error1 = 1
        }
        Finally{
            If ($Error1 -eq 1){
        
                Write-host "-----------------"
                Write-host -ForegroundColor Red "Unable to connect to SSRS Server, Server name, Site Code or Folder Name incorrect."
                Write-host "-----------------"
        
            }
            Else{
                 Write-Host " "
                    Write-Host "Reports files downloaded to"$FullSubFolderName.ToUpper()""        
                }
                }

        }
        #####################################################################################

        '3'
        {
        ######################### 3 - DATA SOURCES ##############################################

        #Error Handling and output
        #Remove Users Variable
        Remove-Variable * -ErrorAction SilentlyContinue

        Clear-Host
        $ErrorActionPreference= 'SilentlyContinue'
        $Error1 = 0

        # -------------User Variables--------------------------------------------
        #Report Server Name
        $ReportServer = Read-Host "Enter your SCCM Reporting Point server name"
        $SiteCode = Read-Host "Enter your SCCM Site Code"
        #DataSource Name and Path
        $NewDataSourcePath = "/ConfigMgr_" + $SiteCode +"/{5C6358F2-4BB6-4a1b-A16E-8D96795D8602}";
        $NewDataSourceName = "{5C6358F2-4BB6-4a1b-A16E-8D96795D8602}";
        #Folder to target
        $SSRSFolder = Read-Host "Enter your SSRS folder name that contains the reports"
        $ReportFolderPath = "/ConfigMgr_" + $SiteCode +"/" + $SSRSFolder
        #------------------------------------------------------------------------

         try
         {
             $URL = "http://$($ReportServer)/reportserver/reportservice2010.asmx?WSDL";
             $SSRS = New-WebServiceProxy -uri $URL -UseDefaultCredential
 
             $Reports = $SSRS.ListChildren($ReportFolderPath, $false)
     
             $Reports | ForEach-Object {
             $ReportPath = $_.path
             Write-Host "Report: " $reportPath.ToUpper()
             $DataSources = $SSRS.GetItemDataSources($ReportPath)
             $DataSources | ForEach-Object {
             $ProxyNamespace = $_.GetType().Namespace
             $MyDataSource = New-Object ("$ProxyNamespace.DataSource")
             $MyDataSource.Name = $NewDataSourceName
             $MyDataSource.Item = New-Object ("$ProxyNamespace.DataSourceReference")
             $MyDataSource.Item.Reference = $NewDataSourcePath
 
             $_.item = $MyDataSource.Item
 
             $ssrs.SetItemDataSources($ReportPath, $_)
 
             Write-Host "Report DataSource changed to ($($_.Name.ToUpper())): $($_.Item.Reference.ToUpper())";
             }
 
             }
         }
        catch{
        $Error1 = 1
        }
        Finally{
            If ($Error1 -eq 1){
        
                Write-host "-----------------"
                Write-host -ForegroundColor Red "Unable to connect to SSRS Server, Server name, Site Code or Folder Name incorrect."
                Write-host "-----------------"
        
            }
            Else{
                Write-host "-----------------"
                Write-Host -ForegroundColor Green "Script execution completed without errors. All Reports DataSources has been changed"
                Write-host "-----------------"
        
                }
                }

        ##################################################################################### 

            }
            'q' {return}
     }
     pause
}
until ($input -eq 'q')

