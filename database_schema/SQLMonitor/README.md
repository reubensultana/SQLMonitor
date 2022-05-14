# SQLMonitor Database Schema

The project database schema, including files used for the initial deployment.

## Prerequisites

1. Install the [dbatools](https://dbatools.io/) module from the PowerShell Gallery using `Install-Module dbatools`. Full instructions, troubleshooting and alternative installation methods can be found at [https://dbatools.io/](https://dbatools.io/).

2. Create a Domain User Account which will be used to run the scripts.  This account must be a member of the *sysadmin* fixed server role on all SQL Server instances being monitored.

3. Identify a Windows Server which will host the SqlMonitor scripts. This can be an Application Server shared with other applications, however network access to the target SQL Server instances must be present on the Instance Listening Port.

4. Download the latest version of the SqlMonitor from [https://github.com/reubensultana/SQLMonitor](https://github.com/reubensultana/SQLMonitor) and copy the files to a location on the server which will be doing the monitoring.

5. Modify the  following scripts so that the password used when creating the respective Server or Database objects (see scripts) is not the default one supplied with this solution.  

   * The script `\Security\encryption.sql` contains the password used to encrypt the CERTIFICATE object;
   * The script `\Security\users.sql` creates the "SqlReports" login using a default password.  
&nbsp;
6. Identify a SQL Server instance that will be used to hst the SqlMonitor database/s.

7. Open SQL Server Management Studio, connect to the target Instance and create the SqlMonitor database using the `create_database.sql` script. At this stage you can modify the script according to your standards, or add more files to the default FileGroup.

&nbsp;

## Installation - All-In-One

1. Start a PowerShell console for the directory containing the installation files;

2. If using a SQL Login to authenticate with the target Instance, create a Credential Object using `$SqlCredential = Get-Credential` and enter the name and password of the SQL Login.;

3. Enter the Login Name and Password when prompted;

4. Run the following to start the installation:  

    ``` powershell
    .\initial_deployment.ps1 `
        -MonitorSqlInstance "localhost,14330" `
        -MonitorSqlAuthCredential $SqlCredential `
        -SqlMonitorDatabaseName "SqlMonitor"
    ```  

5. This will fail with the following message:  

    ``` text
    The SqlMonitor database does not exist. Please create it using the supplied 'create_database.sql' script.
    ```

6. Create the SqlMonitor database as described in the Prerequisites section above.

7. Run the `.\initial_deployment.ps1` command again - the installation should complete successfully.

The following GIF shows the process of installing SqlMonitor using a SQL Login to authenticate with the Instance.

![/SqlMonitor-Install.gif "SqlMonitor Installation"](/database_schema/SQLMonitor/SqlMonitor-Install.gif)

You are now good to go!

&nbsp;

## Installation - Separate SqlMonitor and Archive Databases

The installation process is similar to the one described above.  In addition to creating the main database, the DBA/Operator would have to create the Archive database, for which the `create_database_archive.sql` script has been provided.

The installation can then be started using the following command:  

``` powershell
.\initial_deployment.ps1 `
    -MonitorSqlInstance "localhost,14330" `
    -MonitorSqlAuthCredential $SqlCredential `
    -SqlMonitorDatabaseName "SqlMonitor" `
    -SqlMonitorArchiveDatabaseName "SqlMonitorArchive"
```

The installer will proceed similarly to the above, however will create objects pertaining to the Archive database in the appropriate database.

On completion, the installer will show this warning message:  

``` text
Archive objects have been created in a separate SqlMonitor Archive database. 
Please create Synonyms using the supplied '\Synonyms\synonyms.sql' script to ensure that the functionality remains intact.
```

The `\Synonyms\synonyms.sql` script is also included, however has the Archive database name "hard-coded" as `SqlMonitorArchive` - you will have to change that to match the database name used when creating the Archive database.

&nbsp;

## Notes and Q&A

* *Is it possible to host the Archive database on an alternate SQL Server instance on the same or a different machine?*  
The answer to this is "yes" however you would have to set up a Linked Server and modify the Synonyms script to use the Linked Server.
The `.\initial_deployment.ps1` script does not support this functionality so one would have to create the Archive database on the same Instance as the main database, then move it to an alternate environment.
Another consideration (more of a drawback) is that Linked Servers do not perform well, and since the SqlMonitor archiving functionality is enclosed within a transaction, the use of a Linked Server will result in the "local transaction" being promoted to a "distributed transaction" which will incur in a performance penalty. Also, you will have to ensure that the **Distributed Transaction Coordinator** (MSDTC) is configured correctly; if you are unsure what this means, you might wish to drop this idea altogether.
In a nutshell, considering the above and that each SQL Server instance can support more then 32,000 databases (see *"Databases per instance of SQL Server"* at [Maximum capacity specifications for SQL Server](https://docs.microsoft.com/en-us/sql/sql-server/maximum-capacity-specifications-for-sql-server)), this scenario is not recommended.
