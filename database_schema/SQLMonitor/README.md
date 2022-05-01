# SQLMonitor Database Schema

The project database schema, including files used for the initial deployment.

## Installation - All-In-One

1. Install the [dbatools](https://dbatools.io/) module from the PowerShell Gallery using `Install-module dbatools`. Full instructions, troubleshooting and alternative installation methods can be found at [https://dbatools.io/](https://dbatools.io/).

2. Start a PowerShell console for the directory containing the installation files;

3. If using a SQL Login to authenticate with the target Instance, create a Credential Object using `$SqlCred = Get-Credential`;

4. Enter the Login Name and Password when prompted;

5. Run the following to start the installation:  

    ``` powershell
    .\initial_deployment.ps1 -MonitorSqlInstance "localhost,14330" -MonitorSqlAuthCredential $SqlCred -SqlMonitorDatabaseName "SqlMonitor"
    ```  

6. This will fail with the following message:  

    ``` text
    The SqlMonitor database does not exist. Please create it using the supplied 'create_database.sql' script.
    ```

7. Open SQL Server Management Studio, connect to the target Instance and create the database using the `create_database.sql` script. At this stage you can modify the script according to your standards, or add more files to the default FileGroup.

8. Run the `.\initial_deployment.ps1` command again - the installation should complete successfully.

The following GIF shows the process of installing SqlMonitor using a SQL Login to authenticate with the Instance.

![/SqlMonitor-Install.gif "SqlMonitor Installation"](/SqlMonitor-Install.gif)

You are now good to go!

&nbsp;

## Installation - Separate SqlMonitor and Archive Databases

The installation process is similar to the one described above.  In addition to creating the main database, the Operator would have to create the Archive database, for which the `create_database_archive.sql` script has been provided.

The installation can then be started using the following command:  

``` powershell
.\initial_deployment.ps1 -MonitorSqlInstance "localhost,14330" -MonitorSqlAuthCredential $SqlCred -SqlMonitorDatabaseName "SqlMonitor" -SqlMonitorArchiveDatabaseName "SqlMonitorArchive"
```

The installer will proceed similarly to the above, however will create objects pertaining to the Archive database in the appropriate database.

On completion, the installer will show this warning message:  

``` text
Archive objects have been created in a separate SqlMonitor Archive database. 
Please create Synonyms using the supplied '\Synonyms\synonyms.sql' script to ensure that the SqlMonitor functionality remains intact.
```

The `\Synonyms\synonyms.sql` script is also included, however has the Archive database name "hard-coded" as `SqlMonitorArchive` - you will have to change that if you used a different database name.
