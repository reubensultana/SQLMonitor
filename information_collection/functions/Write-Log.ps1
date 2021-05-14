
function Write-Log {
    <#
    .SYNOPSIS
        Writes log records to the file specified.
    .DESCRIPTION
        Used to keep track of information used for debugging.
    .PARAMETER LogFilePath
        The full path to the log file.
    .PARAMETER LogEntry
        The text containing the details that need to be logged.
        The date and time will be retrieved and appended to the entry at runtime.
        Date and time will be stored as UTC, formatted according to the ISO 8601 guidelines (https://www.iso.org/iso-8601-date-and-time-format.html), and with a precision of 1 nanosecond.
    .NOTES 
        Tags: Logging
        Author: Reuben Sultana (@ReubenSultana), sqlserverdiaries.com
        Website: https://sqlserverdiaries.com
        Copyright: (c) 2021 by Reuben Sultana, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        
    .EXAMPLE
        PS C:\> Write-Log -LogFilePath "C:\LOGS\MyLogFile.log" -LogEntry "Hello World"
        Will write the following to the file mentioned:
            2021-05-08T10:11:11:9990455 Z : Hello World
    .EXAMPLE
        PS C:\> Write-Log -LogFilePath "C:\LOGS\MyLogFile.log" -LogEntry "Hello World" -Verbose
        Will write the following to the file mentioned as well as to the console:
            2021-05-08T10:11:11:9990455 Z : Hello World
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)] [string] $LogFilePath,
        [Parameter(Mandatory=$true, Position=1)] [string] $LogEntry
    )
    try {
        [IO.StreamWriter] $fileWriter = $null

        $LogEntry = "$(Get-Date -AsUTC -Format 'yyyy-MM-ddTHH:mm:ss:fffffff K') : $LogEntry"
        # $LogEntry | Out-File -FilePath $LogFilePath -Append
        $fileWriter = [IO.File]::AppendText("{0}" -f ($LogFilePath))
        $fileWriter.WriteLine($LogEntry);

        # output whatever is logged if -Verbose is defined when calling the script
        if ($VerbosePreference -eq [System.Management.Automation.ActionPreference]::Continue) { Write-Verbose $LogEntry }
    }
    catch { <# do nothing #> }
    finally {
        $fileWriter.Dispose();
    }
}
