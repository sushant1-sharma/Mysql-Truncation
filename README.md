The purpose of this project is to maintain storage space in Mysql Server where data is stored in partitions.
We will backup mysql using mysqldump. Now we can truncate some partitions to manage space. Now we will only store these partitions in Mysql Docker Container and delete rest all partitions to manage space in Docker Container as well.
For this we need to mount the mysqldump backup to a mysql docker container.



Backup Mysql using mysqldump:

      mysqldump -u root -p >/path/backup.sql

Create a .txt file and add input variables in that file:

database=database_name
#write database name of your database backuped.

table=table_name
#write table name of your table backuped

partitions=partitions_names (write like p1,p2,p3)
#write partitions that you have truncated in your mysql server. We will store these in docker container.

path=path of backup file
#This is the path of your backup file


Running the script:

      bash script.sh /mybackup/backup.sql
