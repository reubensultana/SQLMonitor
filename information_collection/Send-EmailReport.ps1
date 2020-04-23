param([String]$ReportType = '')

# 
# Usage: 
#     .\Send-EmailReport.ps1 -ReportType "Daily"
#     Will run the function (if all input parameters are present and valid)
#     Depends on the external "Settings.xml" file
#

# Global params
$CurrentPath = Get-Location
. "$($CurrentPath)\Community_Functions.ps1"

#------------------------------------------------------------# 

function Send-EmailReport {
    param (
    [Parameter(Position=0, Mandatory=$true)]  [string]$SmtpServer,    # The SMTP server that sends the e-mail message. This parameter is required.
    [Parameter(Position=1, Mandatory=$true)]  [string]$Port,          # The SMTP port to use (default is 25). This parameter is required.
    
    [Parameter(Position=2, Mandatory=$true)]  [string]$FromList,      # The address from which the mail is sent. Enter a name (optional) and e-mail address, such as "Name <someone@example.com>". This parameter is required.
    [Parameter(Position=3, Mandatory=$true)]  [string]$ToList,        # The addresses to which the mail is sent. Enter names (optional) and the e-mail address, such as "Name <someone@example.com>". This parameter is required.
    [Parameter(Position=4, Mandatory=$false)] [string]$CcList,        # The e-mail addresses to which a carbon copy (CC) of the e-mail message is sent. Enter names (optional) and the e-mail address, such as "Name <someone@example.com>".
    [Parameter(Position=5, Mandatory=$true)]  [string]$Subject,       # The subject of the e-mail message. This parameter is required.
    [Parameter(Position=6, Mandatory=$true)]  [string]$BodyText,      # The body (content) of the e-mail message. This parameter is required.
    [Parameter(Position=7, Mandatory=$false)] [string]$AttachmentFile # The path and file names of files to be attached to the e-mail message.
    )
    
    # Build the Send mail options
    # technique: Splatting using Hash Tables - see https://msdn.microsoft.com/powershell/reference/5.1/Microsoft.PowerShell.Core/about/about_Splatting
    $Options = @{}
    
    $Options.Add("SmtpServer", $SmtpServer)
    $Options.Add("Port", $Port)
    $Options.Add("From", $FromList)
    $Options.Add("To", $ToList.split(','))
    $Options.Add("Subject", $Subject)
    $Options.Add("Body", $BodyText)
    $Options.Add("BodyAsHTML", $null)

    if ($CcList -ne "") {
        $Options.Add("CC", $CcList.split(','))
    }

    if ($AttachmentFile -ne "" -and $AttachmentFile -ne $null) {
        $Options.Add("Attachments", $AttachmentFile)
    }

    
    try {
        $ErrorActionPreference = "Stop";
        Send-MailMessage $Options
        # NOTE: This cmdlet does not generate any output.
        Start-Sleep -Seconds 5
        }
    catch{
        # Out-File $global:logFileName -Append
        }
    finally {
        $ErrorActionPreference = "Continue"; 
        }
}


function Build-EmailReport {
    param (
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet("Monthly", "Weekly", "Daily", "Manual", "Custom Monthly", "Custom Weekly", "Custom Daily", "Custom Test")] 
    [string]$ReportType      # the report frequency

    )

    # Import settings from config file
    # check if config file exists
    $SettingsFile = "$($CurrentPath)\Settings.xml"
    if (Test-Path($SettingsFile)) {
        [xml]$ConfigFile = Get-Content $SettingsFile

        # --------------------------------------------------------------------------------
        [string] $ServerInstance = $ConfigFile.Settings.DatabaseConnection.ServerInstance
        [string] $Database = $ConfigFile.Settings.DatabaseConnection.Database

        [string] $SmtpServer = $ConfigFile.Settings.EmailParams.SmtpServer
        [string] $Port = $ConfigFile.Settings.EmailParams.TCPPort
        
        [string] $EmailSubject = $ConfigFile.Settings.EmailParams.EmailSubject
        $EmailSubject = $EmailSubject -f $ReportType
        [string] $EmailFrom = $ConfigFile.Settings.EmailParams.EmailFrom
        
        [string] $TableStyle = $ConfigFile.Settings.ReportStyleSheet.TableStyle
        [string] $TableHeaderSyle = $ConfigFile.Settings.ReportStyleSheet.TableHeaderSyle
        [string] $TableDataSyle = $ConfigFile.Settings.ReportStyleSheet.TableDataSyle
        [string] $HTMLStyle = "
<style>
    TABLE{0}
    TH{1}
    TD{2}
</style>
" -f $TableStyle, $TableHeaderSyle, $TableDataSyle

        # --------------------------------------------------------------------------------
        # get profile (incl, script names and scripts)
        [string] $Sql = "EXEC dbo.uspGetReports '{0}';" -f $ReportType
        $Reports = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $Sql -QueryTimeout 30
        
        # store the number of rows returned in a variable for use later
        $OuterRowCount = $Reports.Table.Rows.Count

        # clear
        $Sql = $null

        if ($OuterRowCount -gt 0) {
            # initialize variables
            $EmailBody = ""
            Foreach ($Report in $Reports) {
                # get values from the current row
                $ReportName = $Report.ReportName
                $ExecuteScript = $Report.ExecuteScript
                $RecipientName = $Report.RecipientName
                $RecipientEmailAddress = $Report.RecipientEmailAddress
                $CreateChart = $Report.CreateChart
                $AttachmentFilePath = ""

                # check and append stylesheet (once) to email body
                if ($EmailBody -eq "") { $EmailBody += $HTMLStyle }

                $EmailTo = "$RecipientName <$RecipientEmailAddress>"
                $InnerRowCount = 0

                try {
                    $ReportResult = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $ExecuteScript
                    $ErrorMessage = $null

                    # check if the data retrieval was successful
                    if ([string]::IsNullOrEmpty($ErrorMessage)) {
                        $InnerRowCount = $ReportResult.Table.Rows.Count

                        # append results to email body
                        # limit to the top 500 rows
                        if ($InnerRowCount -gt 0) {
                            $EmailBody += $ReportResult | Select-Object * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors -First 500 | ConvertTo-Html -As Table -PreContent "<h2>$ReportName</h2>" | Out-String 

                            if ($CreateChart -eq 1) {
                                # call the New-ChartImage function and use the returned image path as the $AttachmentFilePath value
                                $AttachmentFilePath = New-ChartImage -ReportName $ReportName -FullDataSource $ReportResult
                            }
                        }
                    } # data retrieval check
                } #try

                catch {
                    $ErrorMessage = $_.Exception.Message

                    $EmailBody += "Could not generate report $ReportName
Error message: $ErrorMessage"
                } #catch

                # send email now, only if results were returned by the inner query
                if ($InnerRowCount -gt 0) {
                    Send-EmailReport -SmtpServer $SmtpServer -Port $Port -FromList $EmailFrom -ToList $EmailTo -Subject "$EmailSubject - $ReportName" -BodyText $EmailBody -AttachmentFile $AttachmentFilePath
                    #Write-Host "Send-EmailReport $EmailTo + $AttachmentFilePath"
                }
                
                # clear for next iteration
                $EmailBody = ""
                $ReportName = ""
                $ExecuteScript = ""
                $RecipientName = ""
                $RecipientEmailAddress = ""
                
                # delete the attachment
                if ($CreateChart -eq 1) {
                    Remove-Item -Path $AttachmentFilePath -Force
                    $CreateChart = 0
                    $AttachmentFilePath = ""
                }

            } # foreach loop

        } # table count

    } # settings file exists

}


function New-ChartImage {
    param (
    [Parameter(Position=0, Mandatory=$true)]  [string]$ReportName,      # the report name
    [Parameter(Position=1, Mandatory=$true)]  [PSObject[]]$FullDataSource   # the data source
    )

    # reference: https://bytecookie.wordpress.com/2012/04/13/tutorial-powershell-and-microsoft-chart-controls-or-how-to-spice-up-your-reports/
    
    [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

    # chart object
    $Chart1 = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
    $Chart1.Width = 1024
    $Chart1.Height = 768
    $Chart1.BackColor = [System.Drawing.Color]::White

    # title 
    [void]$Chart1.Titles.Add($ReportName)
    $Chart1.Titles[0].Font = "Verdana,13pt"
    $Chart1.Titles[0].Alignment = "topLeft"

    # axis titles
    foreach ($DataRow in $FullDataSource) {
        $AxisYTitle = $DataRow.Table.Columns.ColumnName[2]
        $AxisXTitle = $DataRow.Table.Columns.ColumnName[3]
        # break to "loop once"
        break
    }

    # chart area 
    $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $ChartArea.Name = "ChartArea1"
    $ChartArea.AxisY.Title = $AxisYTitle
    $ChartArea.AxisX.Title = $AxisXTitle
    #$ChartArea.AxisY.Interval = 10000
    #$ChartArea.AxisX.Interval = 7  # Assuming that X is always a date; set weekly intervals
    $ChartArea.AxisY.IsStartedFromZero = $false
    $ChartArea.AxisY.LabelStyle.Format = "#,##0"  # Assuming that Y is always a number
    [void]$Chart1.ChartAreas.Add($ChartArea)

    # legend 
    $Legend = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
    $Legend.name = "Legend1"
    [void]$Chart1.Legends.Add($Legend)

    # data series
    foreach ($DataRow in $FullDataSource) {
        $SeriesName = $DataRow.Item(1)

        try { 
            [void]$Chart1.Series.Add($SeriesName) 
            $Chart1.Series[$SeriesName].ChartType = "Line"
            $Chart1.Series[$SeriesName].BorderWidth  = 3
            $Chart1.Series[$SeriesName].IsVisibleInLegend = $true
            $Chart1.Series[$SeriesName].chartarea = "ChartArea1"
            $Chart1.Series[$SeriesName].Legend = "Legend1"
            #$Chart1.Series[$SeriesName].color = "#62B5CC"
        }
        catch { 
            # do nothing except capture the error message
            # this will avoid the error escalating to the outer try...catch block
            $ErrorMessage = $_.Exception.Message
            # $ErrorNumber = $_.Exception.HResult
            # Write-Host "$ErrorNumber, $ErrorMessage"
        }
        $SeriesName = ""
    }

    # data source
    $FullDataSource | ForEach-Object { [void]$Chart1.Series[$_.Item(1)].Points.addxy( $_.Item(3), $_.Item(2)) }

    # save chart
    #$CurrentDate = (Get-Date).ToString("yyyyMMdd_hhmmss")
    #$ImageFilePath = "$CurrentPath\chart_$CurrentDate.png"

    # switched to file name using GUID to ensure uniqueness
    $Id = [GUID]::NewGuid()
    $ImageFilePath = "$CurrentPath\_trash\$Id.png"
    if (Test-Path("$CurrentPath\_trash")) {
        $Chart1.SaveImage($ImageFilePath,"png")
    }
    Return $ImageFilePath # Attachment File Path
}


Clear-Host
# run this only if the parameters have been passed to the script
# interface implemented to be called from Windows Task Scheduler or similar applications
if ($ReportType -ne '') {
    Build-EmailReport -ReportType $ReportType
}
# otherwise, do nothing
