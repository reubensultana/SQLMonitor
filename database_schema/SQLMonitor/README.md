# SqlMonitor Database Schema

The project database schema, including files used for the initial deployment.

## Table of Contents

- [SqlMonitor Database Schema](#sqlmonitor-database-schema)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Installation - All-In-One](#installation---all-in-one)
  - [Installation - Separate SqlMonitor and Archive Databases](#installation---separate-sqlmonitor-and-archive-databases)
  - [Start monitoring Instances](#start-monitoring-instances)
  - [Setting up Profiles](#setting-up-profiles)
  - [System Parameters](#system-parameters)
  - [Notes and Q\&A](#notes-and-qa)

&nbsp;

## Prerequisites

1. Install the [dbatools](https://dbatools.io/) module from the PowerShell Gallery using `Install-Module dbatools`. Full instructions, troubleshooting and alternative installation methods can be found at [https://dbatools.io/](https://dbatools.io/).

2. Create a Domain User Account which will be used to run the scripts.  This account must be a member of the *sysadmin* fixed server role on all SQL Server instances being monitored.

3. Identify a Windows Server which will host the SqlMonitor scripts. This can be an Application Server shared with other applications, however network access to the target SQL Server instances must be present on the Instance Listening Port.

4. Download the latest version of the SqlMonitor from [https://github.com/reubensultana/SQLMonitor](https://github.com/reubensultana/SQLMonitor) and copy the files to a location on the server which will be doing the monitoring.

5. Modify the  following scripts so that the password used when creating the respective Server or Database objects (see scripts) is not the default one supplied with this solution.  

   - The script `\Security\encryption.sql` contains the password used to encrypt the CERTIFICATE object;
   - The script `\Security\users.sql` creates the "SqlReports" login using a default password.  
&nbsp;
6. Identify a SQL Server instance that will be used to hst the SqlMonitor database/s.

7. Open SQL Server Management Studio, connect to the target Instance and create the SqlMonitor database using the `create_database.sql` script. At this stage you can modify the script according to your standards, or add more files to the default FileGroup.

8. Prior to actually starting the deployment you should review and modify the contents of the `\Data` directory.  This directory contains the following files:  

   - `MonitoredServers.sql`  
     This contains the SQL Server instances which will be created by default and monitored by the SqlMonitor;

   - `Profile.sql`  
     Do not change this file since it contains a mapping of when each script will be scheduled to run. You should only use it as a template for additional scripts you might create to extend the functionality of SqlMonitor.

   - `ReportRecipients.sql`  
     Modify the values in this file according to your organization.

   - `Reports.sql`  
     This too should be modified with caution as it contains the default set of reports which will be sent out (by email) to the recipients defined in the `ReportRecipients.sql` file.

   - `ReportSubscriptions.sql`  
     This is where the mapping between a Report Recipient and a Report is made.  A number of default values are provided for you.

   - `SystemParams.sql`  
    Do not change this file unless you review the contents and understand what each value is being used for.  The parameters listed here determine how often data archiving will be performed, the data retention policies, and the SQL Server build numbers - these you will have to update yourself, as and when the build numbers change. As a reference I use the *unofficial* [Microsoft SQL Server Versions List](https://www.sqlserverversions.com/). You can also use the [dbatools Build Reference](https://dataplat.github.io/builds), which is also an unofficial source and is based on the one from <https://sqlserverversions.com>. Hopefully Microsoft will release an official source in the not-too-distant future.  A CSV extract of the builds is being included in this folder (`SqlServerBuilds.csv`), however this information might be obsolete at the time of reading.

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

## Start monitoring Instances

Once the database (or databases) has/have been deployed to your target environment, the next step is to start adding the SQL Server Instances you wish to monitor.

Since SqlMonitor uses an agent-less approach, the only requirements are:

- network access to the target environment on the Instance Listening Port (NOTE: fixed ports are recommended over dynamic ports)
- the account must be able to connect to the Target Instance
- the account must be a member of the sysadmin fixed server role on the target Instance

If these requirements have been satisfied we can start putting together an `INSERT` statement to load our Instances into the database.

``` sql
INSERT INTO [dbo].[vwMonitoredServers] (
    ServerName, ServerAlias, ServerDescription, ServerIpAddress, ServerDomain, SqlTcpPort, 
    ServerOrder, SqlVersion, SqlLoginName, SqlLoginSecret, RecordStatus )
VALUES 
     (N'Server01', NULL, '', '10.11.12.10', 'CORP', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd1!', 'A')
    ,(N'Server02', NULL, '', '10.11.12.11', 'CORP', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd2!', 'A')
    ,(N'Server03', NULL, '', '10.11.12.12', 'CORP', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd3!', 'A')
    ,(N'Server04', NULL, '', '10.11.12.13', 'CORP', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd4!', 'A')
    ,(N'Server05', NULL, '', '10.11.12.14', 'CORP', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd5!', 'A')
    ,(N'Server06', NULL, '', '10.11.12.15', 'CORP', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd6!', 'A')
    ,(N'Server07', NULL, '', '10.11.12.16', 'CORP', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd7!', 'A')

GO
```

From the above we can see that for each environment being monitored we will need the following attributes:

- Server/Host Name or AG Listener Name
- IP Address
- Domain Name
- Listening Port (TCP/IP)
- SQL Login Name (only for SQL Authentication)
- SQL Login Secret (only for SQL Authentication)

The `INSERT` statement also supports a Server Alias, such as for example a different DNS CNAME, as well as the Instance Version Number. The latter is a legacy column which was used to run different scripts/commands for the different versions. This has however been superseded by placing the appropriate version checks within the scripts/commands being executed.

Although the password is in clear text here, you will notice that the `INSERT` is being done against a VIEW.  A quick look at the definition shows that the VIEW is running a `SELECT` against the `[dbo].[MonitoredServers]` table, however when reading the `[SqlLoginSecret]` column, this is being passed through the `[dbo].[udfDecryptValueByCert] ([SqlLoginSecret]` FUNCTION. This is because the values stored in the `[SqlLoginSecret]` column are encrypted using a CERTIFICATE which is in turn protected by a password. You can review the `database_schema\SQLMonitor\Security\encryption.sql` file for more details.  This was mentioned in the [Prerequisites](#prerequisites) section above.

This sample script is also available in the `database_schema\SQLMonitor\Data\MonitoredServers.sql` file.

At this point the Instances are ready to be monitored.

&nbsp;

## Setting up Profiles

The file `database_schema\SQLMonitor\Data\MonitoredServers.sql` contains the default Profiles, based on the default set of scripts provided with these solution and found at `information_collection\scripts`.

Creating Profiles is done using the following (summarised):

``` sql
INSERT INTO [dbo].[Profile] (
    ProfileName, ScriptName, ExecutionOrder, ProfileType, PreExecuteScript, ExecuteScript )
VALUES ...
```

The `[dbo].[Profile]` table has the following attributes, however not all are mandatory:

- ProfileName  
  A name for the specific Profile. The one in the default script maps to the SCHEMA for the tables in the `database_schema\SQLMonitor\Tables\Monitor` directory.

- ScriptName  
  A name for the specific Script. The one in the default script maps to the TABLE names in the `database_schema\SQLMonitor\Tables\Monitor` directory.

- ExecutionOrder  
  The order with which the scripts will be executed. Defaults to zero.

- ProfileType  
  The Type of Profile is a categorisation used for the Scheduled Jobs. The default ones are "Manual", "Minute", "Daily", "Weekly", and "Monthly".

- PreExecuteScript  
  The script/code to run before running the data collection script **for each Instance**. Most are empty however, if the TSQL executed returns a value it must be a single character-type value named "Output". This is subsequently used as a replacement value in the main script being executed.  In such cases the TSQL in this column might also expect a character-type input parameter to be used for the `@ServerName` variable. In the default configuration we can see that some queries are running a `TRUNCATE` against tables in the "Staging" SCHEMA (no input parameter necessary), others are retrieving a `MAX` date value, and another is running a `DELETE` statement (input required).

- ExecuteScript  
  The actual script being executed. Note that if this column is empty/NULL, the process will attempt to load the script code from the respective `.SQL` file in the `information_collection\scripts` directory. The code has been provided in external files as it makes it easier to read and execute in isolation to understand the inputs (if any) and outputs.
  To avoid errors and ensure a complete data collection, it is imperative that if any of the default scripts are modified, or new ones added, these are tested against all SQL Server versions in your Estate.

&nbsp;

## System Parameters

The System Parameters are stored in the `[dbo].[SystemParams]` table and control various functions of the SqlMonitor solution, as detailed below:

- Archive_Days_*  
  The number of days elapsed from the collection date when a record in the respective table is moved to the Archive table.

- Delete_Days_*  
  The number of days elapsed from the collection date when a record in the respective table is deleted from the database.

- Archive_BatchCount and Delete_BatchCount  
  The size, or number of rows, in each batch when processing records by the Archiving or Deletion processes

- SQLServer_BuildVersion_*  
  The latest supported build number for the respective SQL Server version.  This information is used to compare build numbers and identify which Instances require patching.
  Build numbers can be obtained from the [Microsoft website](https://learn.microsoft.com/en-us/troubleshoot/sql/releases/download-and-install-latest-updates), the unofficial [Microsoft SQL Server Versions List](https://www.sqlserverversions.com/), as described in my [Get-SqlServerVersions.ps1 script](https://github.com/reubensultana/DBAScripts/blob/master/PowerShell/Get-SqlServerVersions.ps1), or any other method you might adopt.

- SchemaName_Staging  
  The name of the Staging Schema.

Default values for all of the above can be reviewed in the `database_schema\SQLMonitor\Data\SystemParams.sql` script file.

&nbsp;

## Notes and Q&A

- *Is it possible to host the Archive database on an alternate SQL Server instance on the same or a different machine?*  
The answer to this is "yes" however you would have to set up a Linked Server and modify the Synonyms script to use the Linked Server.
The `.\initial_deployment.ps1` script does not support this functionality so one would have to create the Archive database on the same Instance as the main database, then move it to an alternate environment.
Another consideration (more of a drawback) is that Linked Servers do not perform well, and since the SqlMonitor archiving functionality is enclosed within a transaction, the use of a Linked Server will result in the "local transaction" being promoted to a "distributed transaction" which will incur in a performance penalty. Also, you will have to ensure that the **Distributed Transaction Coordinator** (MSDTC) is configured correctly; if you are unsure what this means, you might wish to drop this idea altogether.
In a nutshell, considering the above and that each SQL Server instance can support more then 32,000 databases (see *"Databases per instance of SQL Server"* at [Maximum capacity specifications for SQL Server](https://docs.microsoft.com/en-us/sql/sql-server/maximum-capacity-specifications-for-sql-server)), this scenario is not recommended.
