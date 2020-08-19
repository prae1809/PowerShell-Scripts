This Powershell script will let you manage your report on an SCCM Reporting Point.

Based on your SCCM Reporting Point and SCCM site code, the tool allows to :

Upload multiple reports from a specific folder --- Useful if you have multiple RDL files to upload at once.
Download all report from a specific SSRS folder -- Useful if you have multiple custom reports and are doing a migration to a new reporting point
Change data source of all reports from a specific SSRS folder -- Useful if you upload multiple new reports and need to change their data sources
The script needs PowerShell 2.0 and has been tested on SQL 2012 and SQL 2016 Reporting Point.
