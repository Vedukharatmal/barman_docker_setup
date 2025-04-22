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
barman list-backups <servername>
```

## Restore backup
```bash
barman recover --remote-ssh-command "ssh <destDbUsername>@<destDbIP>" <sourceServername> <backupIdNumber>  <destDatabaseFolderPath> 
```
Example:
```bash
barman recover --remote-ssh-command "ssh postgres@172.20.0.2" pg 20250409T070911  /var/lib/postgresql/11/main/
```