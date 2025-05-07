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

## TODOS
* explain the configuration options used in barman pg.conf, barman.conf, supervisord.conf in readme
* explain the configuration options used in pgd and pgsrc init.sql, pg_hba.conf, postgresql.conf

## Explaination of the configuration files

*   1 - Barman.conf file
  This is the file which is used by the barman tool to locate its server configuration file and other information required for barman operations, this file includes various parameters like - 

  1.barman_user = barman  // this shows the user which will perform backups, in our case it is 'barman'.
 
  2.configuration_files_directory = /etc/barman.d  // this line tells the barman tool the path of the backup server configuration file.

  3.barman_home = /var/lib/barman  // this tells the barman tool the path of the barman user.

  4.log_file = var/log/barman/barman.log  // This is the path specified to collect log about barman operations.

  5.log_level = DEBUG  // To debug the errors.

  6.compression = gzip  // this is the type of the backup file which is zip file.

  7.basebackup_retry_times = 10  // Times to retry if barman fails to perform the backup.

  8.barman_lock_directory = var/lib/barman/.locks  // This the path for barman to access the lock folder.

*   2 - pg.conf file
  This is the file where all the postgresql servers are placed and connection info to connect with barman. 
  parameters - 
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

*   3.supervisord.conf - The supervisord.conf file is used to configure Supervisor, a process control system for UNIX-like operating systems that allows you to manage and monitor long-running processes. It runs programs in the background, restarts them if they fail, and logs their output.

  