Backup Mysql using mysqldump:

      mysqldump -u root -p >/path/backup.sql

Create a .txt file and add input variables in that file:

      database=database_name
      table=table_name
      partitions=partitions_names (write like p1,p2,p3)
      path=path of backup file

Running the script:

      bash script.sh /mybackup/backup.sql
