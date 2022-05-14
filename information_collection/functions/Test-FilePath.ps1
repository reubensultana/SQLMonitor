
function Test-FilePath {
    <#
    .SYNOPSIS
        Wrapper function to check if a specific file exists.
    .DESCRIPTION
        Used to standardise the error messages when checking for files.
    .PARAMETER Path
        The full path to the file.
    .EXAMPLE
        PS C:\> Test-FilePath -Path "C:\TEMP\MyLogFile.txt"
        Will return true or false depending on if the file exists.
    .NOTES 
        Tags: Logging
        Author: Reuben Sultana (@ReubenSultana), sqlserverdiaries.com
        Website: https://sqlserverdiaries.com
        Copyright: (c) 2022 by Reuben Sultana, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/reubensultana/SQLMonitor
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $FilePath
    )
    if ( $false -eq $(Test-Path -Path $FilePath -PathType Leaf) ) { 
        Write-Error $("The required file {0} does not exist." -f $FilePath)
        return $false
    }
    return $true
}
