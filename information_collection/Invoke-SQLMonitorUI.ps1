param([String]$ServerName = '',
	  [String]$DatabaseName = '',
      [String]$MonitorProfile = '',
      [String]$MonitorProfileType = '')

# 
# Usage: 
#     .\Invoke-SQLMonitorUI.ps1
#     Will display the menu
#
#     .\Invoke-SQLMonitorUI.ps1 -ServerName "Server Name" -DatabaseName "SQL Monitor Database" -MonitorProfile "Monitor Profile" -MonitorProfileType "Profile Type"
#     Will run the function (if all input parameters are present and valid)
#

# set properties on the console window
$Console = $host.UI.RawUI
$Console.ForegroundColor = "white"
$Console.BackgroundColor = "darkblue"
$Console.WindowTitle = "SQL Monitor Data Collection Processes"
<#
$Size = $Console.WindowSize
$Size.Width = 120
$Size.Height = 40
$Console.WindowSize = $Size

$Buffer = $Console.BufferSize
$Buffer.Width = 120
$Buffer.Height = 2000
$Console.BufferSize = $Buffer
#>
# end properties

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force -WarningAction SilentlyContinue
Clear-Host

# Global params
$CurrentPath = $PSScriptRoot
#. "$($CurrentPath)\SqlMon_Functions.ps1"

#------------------------------------------------------------# 

#AreYouSure function. Allows user to select y or n when asked to exit. Y exits and N returns to main menu.  
function AreYouSure {
    [string] $AreYouSure = Read-Host "Are you sure you want to exit? (y/n)"
    if     ($AreYouSure -eq "y"){Clear-Host; Exit}
    elseif ($AreYouSure -eq "n"){MainMenu}
    else {Write-Host -ForegroundColor Red "Invalid Selection";
          AreYouSure
         }
}

#------------------------------------------------------------# 

#MainMenu function. Contains the screen output for the menu and waits for and handles user input.  
function MainMenu {
    # Import settings from config file
    # check if config file exists
    [string] $SettingsFile = "$($CurrentPath)\Settings.xml"
    if (Test-Path($SettingsFile)) {
        [xml]$ConfigFile = Get-Content $SettingsFile

        [string] $ServerInstance = $ConfigFile.Settings.DatabaseConnection.ServerInstance
        [string] $Database = $ConfigFile.Settings.DatabaseConnection.Database
        [string] $ProfileName = $ConfigFile.Settings.DatabaseConnection.ProfileName
		[int] $QueryTimeout = $ConfigFile.Settings.DatabaseConnection.QueryTimeout

        Clear-Host
        
        Write-Host ""
        Write-Host "---------------------------------------------------------"
        Write-Host "  SQL Monitor Data Collection Processes ($ServerInstance)"
        Write-Host "" 
        Write-Host "  0.  Exit"
        Write-Host "  1.  Test Network Access"
        Write-Host "  2.  Annual"
        Write-Host "  3.  Monthly"
        Write-Host "  4.  Weekly"
        Write-Host "  5.  Daily"
        Write-Host "  6.  Hourly"
        Write-Host "  7.  Minute"
        Write-Host "  8.  Manual"
        Write-Host "  9.  "
        Write-Host "  10. Maintain Archive"
        Write-Host ""
        Write-Host "---------------------------------------------------------"
        $Answer = Read-Host "Please choose an option"

        if     ($Answer -eq 0) {AreYouSure}
        elseif ($Answer -eq 1) {.\Test-NetworkConnection.ps1 -ServerName $ServerInstance -DatabaseName $Database;  Pause; MainMenu}
        elseif ($Answer -eq 2) {.\Get-ServerInfo.ps1 -ServerName $ServerInstance -DatabaseName $Database -MonitorProfile $ProfileName -MonitorProfileType "Annual" -QueryTimeout $QueryTimeout;  Pause; MainMenu}
        elseif ($Answer -eq 3) {.\Get-ServerInfo.ps1 -ServerName $ServerInstance -DatabaseName $Database -MonitorProfile $ProfileName -MonitorProfileType "Monthly" -QueryTimeout $QueryTimeout; Pause; MainMenu}
        elseif ($Answer -eq 4) {.\Get-ServerInfo.ps1 -ServerName $ServerInstance -DatabaseName $Database -MonitorProfile $ProfileName -MonitorProfileType "Weekly" -QueryTimeout $QueryTimeout;  Pause; MainMenu}
        elseif ($Answer -eq 5) {.\Get-ServerInfo.ps1 -ServerName $ServerInstance -DatabaseName $Database -MonitorProfile $ProfileName -MonitorProfileType "Daily" -QueryTimeout $QueryTimeout;   Pause; MainMenu}
        elseif ($Answer -eq 6) {.\Get-ServerInfo.ps1 -ServerName $ServerInstance -DatabaseName $Database -MonitorProfile $ProfileName -MonitorProfileType "Hourly" -QueryTimeout $QueryTimeout;  Pause; MainMenu}
        elseif ($Answer -eq 7) {.\Get-ServerInfo.ps1 -ServerName $ServerInstance -DatabaseName $Database -MonitorProfile $ProfileName -MonitorProfileType "Minute" -QueryTimeout $QueryTimeout;  Pause; MainMenu}
        elseif ($Answer -eq 8) {.\Get-ServerInfo.ps1 -ServerName $ServerInstance -DatabaseName $Database -MonitorProfile $ProfileName -MonitorProfileType "Manual" -QueryTimeout $QueryTimeout;  Pause; MainMenu}
        elseif ($Answer -eq 9) {Pause; MainMenu}
        elseif ($Answer -eq 10) {.\Invoke-ArchiveMaintenance.ps1 -ServerName $ServerInstance -DatabaseName $Database; Pause; MainMenu}
        else {
            Write-Host -ForegroundColor Red "Invalid selection"
            Start-Sleep 3
            MainMenu
        }
        # $ProfileType = $null
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
        Write-Host "        <QueryTimeout>TimeoutAmountInSeconds</QueryTimeout>"
        Write-Host "    </DatabaseConnection>"
        Write-Host "</Settings>"
        Write-Host ""
    }
}

#------------------------------------------------------------# 

Clear-Host
# display the menu
MainMenu



# SAMPLE 1: dynamic menu, based on an array
<#
Clear-Host
$array1 = @(
    ("1","First"),
    ("2","Second"),
    ("3","Third"),
    ("4","Fourth"),
    ("5","Fifth"),
    ("6","Sixth")
    )
$list = 0
Write-Host "0. Exit" 
foreach ($arr in $array1) {
    $list += 1
    Write-Host $list"." $arr[1]
}
$choice1 = Read-Host "Choose and option 1-$list"
if ($choice1 -eq 0) {Exit}
else {
    $selection = $array1[$choice1][1]
    Write-Host "Option $selection was chosen"
}
#>

# SAMPLE 2: Menu and Sub-Menu
<#
Function Main-Menu {
    Clear-Host
    Write-Host "My Main Menu" -ForegroundColor Green
    Write-Host ""
    "[1] Do something"
    "[2] Do another thing"
    "[3] Go to the Sub-Menu"
    "[4] Exit"
    ""
    $selection = Read-Host "Please select an option from above"
    Switch ($selection) {
        1 {"Do something";      Pause; Main-Menu}
        2 {"Do another thing";  Pause; Main-Menu}
        3 {Sub-Menu}
        4 {break}
        default {Write-Warning "Invalid choice!"; Pause}
    }
}

Function Sub-Menu {
    Clear-Host
    Write-Host "My Sub-Menu" -ForegroundColor Green
    Write-Host ""
    "[1] Do some stuff"
    "[2] Do some other stuff"
    "[3] Go back to the Main Menu"
    "[4] Exit"
    ""
    $selection = Read-Host "Please select an option from above"
    Switch ($selection) {
        1 {"Do some stuff";        Pause; Sub-Menu}
        2 {"Do some other stuff";  Pause; Sub-Menu}
        3 {Main-Menu}
        4 {break}
        default {Write-Warning "Invalid choice!"; Pause}
    }
}

Main-Menu
#>
