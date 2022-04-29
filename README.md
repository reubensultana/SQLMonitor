# SQLMonitor

## The Short Version

SQL Server monitoring tool based on PowerShell v3 and TSQL scripts only

## The Longer Version

SqlMonitor is more of a monitoring solution. This allows DBAs to run preset scripts or TSQL code against a number of SQL Server instances, according to time-based rules defined by what I called "Profiles". The monitoring part allows DBAs to execute the scripts and store the results in a central location for reporting, and trend analysis, etc.

SqlMonitor also performs data collection of key information from the Instances, hence providing DBAs with a centralised Configuration Management Database (CMDB) of the estate being managed. This, in my opinion, is crucial for the smooth running of an organisation and allows the DBA to answer questions such as:

* "how many SQL Servers doe we have?"
* "what licences are in use?"
* "when was the last time a specific database was backed up?"
* "is this SQL Server instance running?"
* "how many logins have not reset their password for more than 90/120/etc. days?"

Obtaining the information to be able to answer these questions has been a key part of the development of this solution. The standard set of scripts available by default are those which I would have used, on more than one occasion, to help me answer questions from Management, Auditors, a Data Owner, or simply to help me do my job better.

Since the SqlMonitor is not bound to these scripts, you can write your own code (test it, of course) and add it to the solution. The only other requirement is that you'd have to build
the table structure/s which will be storing the data being collected. A guide to perform this task is (or will be) included in the final version of the solution.
