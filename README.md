# SQLMonitor

## The Short Version

SQL Server monitoring tool based on PowerShell v3 and TSQL scripts only

&nbsp;

## The (Slightly) Longer Version

SqlMonitor is more than a "monitoring solution". This tool allows DBAs to run preset scripts or TSQL code against a number of SQL Server instances, according to time-based rules defined by what have been named "Profiles". The monitoring part allows DBAs to execute the scripts and store the results in a central location for reporting, trend analysis, etc.

SqlMonitor also performs data collection of key information from the Instances, hence providing DBAs with a centralised Configuration Management Database (CMDB) of the organisations' estate being managed. This, in my opinion, is crucial for the smooth running of an organisation and allows the DBA to answer questions such as:

* how many SQL Servers doe we have?
* what licences are in use?
* when was the last time a specific database was backed up?
* is this SQL Server instance running?
* how many logins have not reset their password for more than 90/120/etc. days?

Obtaining the information to be able to answer these questions has been a key part of the development of this solution. The standard set of scripts available by default are those which I would have used, on more than one occasion, to help me answer questions from Management, Auditors, a Data Owner, or simply to help me do my job better.

Since the SqlMonitor is not bound to these scripts, you can write your own code (test it, of course) and add it to the solution. The only other requirement is that you'd have to build
the table structure/s which will be storing the data being collected. A guide to perform this task is (or will be) included in the final version of the solution.

&nbsp;

## Support

The current implementation of SqlMonitor has been tested on Windows 2016 and later operating systems only. A future version might be supported Linux machines however there are no immediate plans to do so.

The SqlMonitor database/s can be hosted on SQL Server 2012 and later environments, including SQL Server on Linux.

If this is a new deployment, it is recommended that you use the latest and full patched versions of Windows Server and SQL Server.

&nbsp;
