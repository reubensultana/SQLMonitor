# A Work List for this Project

A collection of items, thoughts and suggestions that I have for this project. Feel free to contact me if you have any suggestions or questions.

## Functionality

* [x] Modify functionality to use [DBA Tools](https://dbatools.io) module instead of writing my own;
* [x] Split main code functionality to use PoSh Runspaces;
* [x] Enhance logging, writing to text files in a specific folder;
* [ ] Functionality to load log files into the database (?);
* [ ] Functionality to clear log files older than N days/weeks/months;
* [x] Modify deployment scripts to avoid hard-coding the Database Name;
* [x] Check and install DBA Tools as part of the deployment (manual installation is always possible for servers not connected to the Internet);
* [x] Merge the Audit/History objects back into the main database, or make it a parameter/choice in the deployment scripts;
* [x] Split `.\initial_data_set.sql` into multiple files for better manageability;
* [ ] Write PoSh functions to support and maintain SqlMonitor functionality, e.g.:  
  * Get-SMConfig
  * Set-SMConfig
  * Get-SMMonitoredServer
  * New-SMMonitoredServer
  * Set-SMMonitoredServer
  * Get-SMSystemParam
  * New-SMSystemParam
  * Set-SMSystemParam
  * Other:  
    * Recipients
    * Reports
    * Subscriptions
    * Run Collection
    * Run Script

* [ ] Compile Posh functions as a SqlMonitor Module;
* [x] Deployment instructions: Add `Import-Module dbatools` to the `$Profile` of the account running this solution;
* [ ] Option to write collected information to CSV or Excel files (use `ImportExcel` module) instead of the SQLMonitor database;
* [x] Securely store SQL authentication parameters for each server in the database;
* [ ] Convert embedded TSQL code to stored procedures;

## Scripts

* [ ] Collect WAIT stats;
* [ ] Collect PWDHASH value for SQL Logins, store centrally, and compare against a predefined list of weak/known passwords. Will also have to build a Dictionary table of sorts;
* [ ] Include output from [sp_WhoIsActive](http://whoisactive.com/);
* [ ] Check for SQL Server Instances that are/are not running (similar to the one written in 2012);

## Documentation

*This deserves it's own section.*

* [ ] Write a better GitHub landing page;
* [x] Write better deployment instructions, possibly including a GIF file of the deployment process;
* [ ] Write documentation for this project;
* [ ] Provide inline documentation (i.e. within the Project folder structure) as Markdown files;
* [ ] Evaluate [Read the Docs](https://readthedocs.org/) - this might have to be it's own project;
* [ ] Important: Emphasize that all dates are stored in UTC time zone;

## Reporting

* [ ] Create PowerBI report, or set of reports, based on the database structure. Include Version numbering and add to repo for free download;
* [ ] Real-time monitoring reports;
* [ ] Statistical/Historical reports;

## Testing

* [ ] Run tests against multiple environments on Docker or Kubernetes.

## Nice To Have

* [ ] Compile PowerShell scripts into an EXE and deploy as a Windows Service. This would be running continuously so the design might have to be changed to avoid overruns and hogging the machine resources;
* [ ] Adapt SQL Monitor for the Cloud (e.g. as an Azure Runbook, AWS Lambda Function, etc.). The database will also need refactoring to support Azure SQL DB for example;
* [ ] Create a UI for manual running/testing, possibly using something like [PoshGUI](https://poshgui.com/);
