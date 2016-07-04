param([String]$ServerName = '',
	  [String]$DatabaseName = '',
      [String]$MonitorProfile = '',
      [String]$MonitorProfileType = '')

# 
# Usage: 
#     .\invoke_monitor_sql.ps1
#     Will display the menu
#
#     .\invoke_monitor_sql.ps1 -ServerName "Server Name" -DatabaseName "SQL Monitor Database" -MonitorProfile "Monitor Profile" -MonitorProfileType "Profile Type"
#     Will run the function (if all input parameters are present and valid)
#

# set properties on the console window
$console = $host.UI.RawUI
$console.ForegroundColor = "white"
$console.BackgroundColor = "darkblue"
$console.WindowTitle = "SQL Monitor Data Collection Processes"

$size = $console.WindowSize
$size.Width = 120
$size.Height = 40
$console.WindowSize = $size

$buffer = $console.BufferSize
$buffer.Width = 120
$buffer.Height = 2000
$console.BufferSize = $buffer
# end properties

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force -WarningAction SilentlyContinue
Clear-Host

# Global params
$CurrentPath = $PSScriptRoot
. "$($CurrentPath)\SqlMon_Functions.ps1"

#AreYouSure function. Alows user to select y or n when asked to exit. Y exits and N returns to main menu.  
function AreYouSure {
    $areyousure = Read-Host "Are you sure you want to exit? (y/n)"
    if     ($areyousure -eq "y"){Clear-Host; Exit}
    elseif ($areyousure -eq "n"){MainMenu}
    else {Write-Host -ForegroundColor Red "Invalid Selection";
          AreYouSure
         }
}


#MainMenu function. Contains the screen output for the menu and waits for and handles user input.  
function MainMenu {
    # Import settings from config file
    # check if config file exists
    $SettingsFile = "$($CurrentPath)\Settings.xml"
    if (Test-Path($SettingsFile)) {
        [xml]$ConfigFile = Get-Content $SettingsFile

        $ServerInstance = $ConfigFile.Settings.DatabaseConnection.ServerInstance
        $Database = $ConfigFile.Settings.DatabaseConnection.Database
        $ProfileName = $ConfigFile.Settings.DatabaseConnection.ProfileName

        Clear-Host
        Write-Host "---------------------------------------------------------"
        Write-Host "    SQL Monitor Data Collection Processes"
        Write-Host ""
        Write-Host "    0. Exit"
        Write-Host "    1. Annual"
        Write-Host "    2. Monthly"
        Write-Host "    3. Weekly"
        Write-Host "    4. Daily"
        Write-Host "    5. Hourly"
        Write-Host "    6. Minute"
        Write-Host "    7. Manual"
        Write-Host ""
        Write-Host "---------------------------------------------------------"
        $answer = Read-Host "Please choose an option"

        if     ($answer -eq 0) {AreYouSure}
        elseif ($answer -eq 1) {Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType "Annual";  Pause; MainMenu}
        elseif ($answer -eq 2) {Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType "Monthly"; Pause; MainMenu}
        elseif ($answer -eq 3) {Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType "Weekly";  Pause; MainMenu}
        elseif ($answer -eq 4) {Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType "Daily";   Pause; MainMenu}
        elseif ($answer -eq 5) {Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType "Hourly";  Pause; MainMenu}
        elseif ($answer -eq 6) {Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType "Minute";  Pause; MainMenu}
        elseif ($answer -eq 7) {Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType "Manual";  Pause; MainMenu}
        else {
            Write-Host -ForegroundColor Red "Invalid selection"
            Start-Sleep 3
            MainMenu
        }
        $ProfileType = $null
        $ServerInstance = $null
        $Database = $null
        $ProfileName = $null
    }
    else {
        Write-Host "Settings file could not be found in current location."
        Write-Host "Kindly ensure that the current folder contains a ""Settings.xml"" file with the following format:"
        Write-Host ""
        Write-Host "<?xml version=""1.0""?>"
        Write-Host "<Settings>"
        Write-Host "    <DatabaseConnection>"
        Write-Host "        <ServerInstance>ConfigServer</ServerInstance>"
        Write-Host "        <Database>ConfigDatabase</Database>"
        Write-Host "        <ProfileName>MonitoringProfile</ProfileName>"
        Write-Host "    </DatabaseConnection>"
        Write-Host "</Settings>"
        Write-Host ""
    }
}

Clear-Host
# run this only if the parameters have been passed to the script
# interface implemented to be called from Windows Task Scheduler or similar applications
if (($ServerName -ne '') -and ($DatabaseName -ne '') -and ($MonitorProfile -ne '') -and ($MonitorProfileType -ne '')) {
    Get-ServerInfo -ServerInstance $ServerName -Database $DatabaseName -ProfileName $MonitorProfile -ProfileType $MonitorProfileType
}
# otherwise display the menu
else { MainMenu }
