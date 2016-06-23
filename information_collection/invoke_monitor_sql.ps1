# required when using PSRemoting: 
# Set-Item wsman:\\localhost\Client\TrustedHosts -value *

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
    [xml]$ConfigFile = Get-Content "$($CurrentPath)\Settings.xml"

    $ServerInstance = $ConfigFile.Settings.DatabaseConnection.ServerInstance
    $Database = $ConfigFile.Settings.DatabaseConnection.Database
    $ProfileName = $ConfigFile.Settings.DatabaseConnection.ProfileName

    Clear-Host
    Write-Host "---------------------------------------------------------"
    Write-Host "    SQL Monitor Data Collection Processes"
    Write-Host ""
    Write-Host "    1. Annual"
    Write-Host "    2. Monthly"
    Write-Host "    3. Weekly"
    Write-Host "    4. Daily"
    Write-Host "    5. Hourly"
    Write-Host "    6. Minute"
    Write-Host "    7. Manual"
    Write-Host "    8. Exit"
    Write-Host ""
    Write-Host "---------------------------------------------------------"
    $answer = Read-Host "Please choose an option"

    if     ($answer -eq 1) {Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType "Annual";  Pause; MainMenu}
    elseif ($answer -eq 2) {Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType "Monthly"; Pause; MainMenu}
    elseif ($answer -eq 3) {Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType "Weekly";  Pause; MainMenu}
    elseif ($answer -eq 4) {Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType "Daily";   Pause; MainMenu}
    elseif ($answer -eq 5) {Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType "Hourly";  Pause; MainMenu}
    elseif ($answer -eq 6) {Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType "Minute";  Pause; MainMenu}
    elseif ($answer -eq 7) {Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType "Manual";  Pause; MainMenu}
    elseif ($answer -eq 8) {AreYouSure}
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

Clear-Host
MainMenu
