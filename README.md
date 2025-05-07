barman postgresql docker setup

## Steps to perform full backup 
* access barman container
```bash
docker exec -it barman bash
```
* start ssh service
```bash
service ssh start
```
* start full backup. Server name is mentioned in barman/pg.conf (/etc/barman.d/pg.conf) file
```bash
barman backup <servername>
```

## View backups
* Server name is mentioned in barman/pg.conf (/etc/barman.d/pg.conf) file
```bash
barman list-backup <servername>
```

## Restore backup
```bash
barman recover --remote-ssh-command "ssh -o StrictHostKeyChecking=no <destDbUsername>@<destDbIP>" <sourceServername> <backupIdNumber>  <destDatabaseFolderPath> 
```
Example:
```bash
barman recover --remote-ssh-command "ssh -o StrictHostKeyChecking=no  postgres@pgd" pg 20250409T070911  /var/lib/postgresql/11/main/
```

## Steps to perform Incremental backup 
Prerequisite:-Already a full backup should be present

* access barman container
```bash
docker exec -it barman bash
```
* start ssh service
```bash
service ssh start
```
* start incremental backup. Server name is mentioned in barman/pg.conf (/etc/barman.d/pg.conf) file
```bash
barman backup --reuse=link <servername>
```
Example:-
```bash
barman backup --reuse=link pg 
```

## Explaination of the configuration files

*1 - Barman.conf file
  This is the file which is used by the barman tool to locate its server configuration file and other information required for barman operations, this file includes various parameters like - 

```bash
1.barman_user = barman  // this shows the user which will perform backups, in our case it is 'barman'.
 
2.configuration_files_directory = /etc/barman.d  // this line tells the barman tool the path of the backup server configuration file.

3.barman_home = /var/lib/barman  // this tells the barman tool the path of the barman user.

4.log_file = var/log/barman/barman.log  // This is the path specified to collect log about barman operations.

5.log_level = DEBUG  // To debug the errors.

6.compression = gzip  // this is the type of the backup file which is zip file.

7.basebackup_retry_times = 10  // Times to retry if barman fails to perform the backup.

8.barman_lock_directory = var/lib/barman/.locks  // This the path for barman to access the lock folder.
```

*2 - pg.conf file
  This is the file where all the postgresql servers are placed and connection info to connect with barman. 
  parameters - 

```bash
1. description = "PostgreSQL Source"

2. conninfo = host=pgsrc user=barman dbname=postgres password=barmanpass   //  Connection strings for regular and streaming connections using the barman user.

3. streaming_conninfo = host=pgsrc user=barman password=barmanpass dbname=postgres  //  Same as above.
  
4. slot_name = barman  //  Replication slot name used for streaming WALs.

5. backup_method = postgres    //  Uses pg_basebackup as the backup method.
  
6. streaming_archiver = on  //  Enables streaming of WAL files directly.
  
7. streaming_archiver_name = barman_receive_wal  //  Command used to receive WALs from the PostgreSQL server.
  
8. create_slot = auto  //  Automatically creates the replication slot if it doesn’t exist.
  
9. wal_retention_policy = main  //   Retains WAL files needed for the last full backup (main).
  
10.backup_directory = /var/lib/barman/backups/pgsrc   //  Where backups are stored.
  
11.immediate_checkpoint = yes  //   Forces an immediate checkpoint when taking backups.
  
12.retention_policy = REDUNDANCY 2  //   Keeps the last 2 successful backups and removes older ones.
  
13.incoming_wals_directory = /var/lib/barman/backups/incoming/       //   Directory for receiving WALs before processing.
```

*3.supervisord.conf - The supervisord.conf file is used to configure Supervisor, a process control system for UNIX-like operating systems that allows you to manage and monitor long-running processes. It runs programs in the background, restarts them if they fail, and logs their output.

```bash
[program:cron]

1.command=/usr/sbin/cron -f   // Runs the cron service in the foreground (-f keeps it in the foreground so Supervisor can manage it).
  
2.autostart=true  //  Start this program automatically when Supervisor starts.
  
3.autorestart=true  //  Restart the program if it exits unexpectedly.
  
4.stdout_logfile=/var/log/cron.log  //  Path to the log file for standard output.
  
5.stderr_logfile=/var/log/cron_err.log  //  Path to the log file for error output.

[program:barman-cron]
  
1.command=/usr/bin/barman cron  //  Runs the barman cron command, which is required to manage backup operations and sync with the PostgreSQL server.
  
2.user=barman  //  Runs the command as the barman user (important for permission/security).
  
3.autostart=true  //   Ensures the task starts and stays running.
  
4.autorestart=true  //   Ensures the task starts and stays running.
  
5.stdout_logfile=/var/log/barman/cron.log  //  Logs specific to this cron process, useful for diagnosing issues with Barman’s scheduling.
  
6.stderr_logfile=/var/log/barman/cron_err.log  //  Logs specific to this cron process, useful for diagnosing issues with Barman’s scheduling.
```

*4. pg_hba.conf - configuration to allow connection with the postgresql server

*5. postgresql.conf - contains postgres configurations we just update wal_level = replica which is the parameter we have to set to start wal archiving for postgresql backup

*init.sql - This are the set of sql commands we are using when we buid the container which contains - 

```bash
-- SET password for postgres user
ALTER USER postgres WITH PASSWORD 'secret';
```

```bash
--create user barman with replication privilages
CREATE ROLE barman WITH SUPERUSER LOGIN REPLICATION PASSWORD 'barmanpass';
```

```bash
-- CREATE DATABASE COMPANY
CREATE DATABASE company WITH OWNER postgres TEMPLATE template0 ENCODING 'UTF8';
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(100),
    age INT,
    email VARCHAR(100)
);
```

```bash
-- Insert values
INSERT INTO employees (name, department, age, email) VALUES
('Alice', 'HR', 30, 'alice@example.com'),
('Bob', 'Engineering', 28, 'bob@example.com'),
('Charlie', 'Marketing', 32, 'charlie@example.com'),
('Diana', 'Sales', 27, 'diana@example.com'),
('Eve', 'IT', 35, 'eve@example.com');

```