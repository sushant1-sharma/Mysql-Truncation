#!/bin/bash

. $1
echo -e "\n"
echo "Below are the details of input file" 
echo "database=$database"
echo "table=$table"
echo "partitions=$partitions"
echo "path=$path"

if [ "$database" == "" ];then
   echo "Write database in the form database=database_name"
   exit
fi

if [ "$table" == "" ];then
   echo "Write table in the form table=table_name"
   exit
fi

if [ "$partitions" == "" ];then
   echo "Write database in the form partitions=partition_name1,partition_name2,..."
   exit
fi

if [ "$path" == "" ];then
   echo "Write database in the form path=path of file"
   exit
fi


partitions=${partitions//,/\',\'}

echo -e "\n"

echo "Enter the docker container name containing mysql backup"; 
read docker_container

if sudo docker ps -a --format '{{.Names}}' | grep -Eq "^${docker_container}\$"; then
  echo "Docker container started"
  docker start $docker_container
else
  echo "Docker container $docker_container doesn't exist, create a mysql  docker container and start the script"
  exit; 
fi

echo -e "\n"
echo "Below is the query that will truncate all  partitions except '$partitions'"; 
echo -e "\n"
echo "use $database;
SET @P=NULL;
SELECT group_concat(partition_name) INTO @P FROM INFORMATION_SCHEMA.PARTITIONS WHERE table_schema='$database' and table_name='$table' and partition_name NOT IN ('$partitions');
SET @query1=concat('alter table $table truncate partition ',@P);"; 


echo -e "\n"
echo "Are You sure You want to continue"
read Confirmation
echo -e "\n"

if [ $Confirmation == "Yes" ]  || [ $Confirmation == "Y" ] || [ $Confirmation == "yes" ] || [ $Confirmation == "y" ];   
then

   
    docker cp $path $docker_container:/var/lib/mysql_backup.sql
    echo "Enter mysql anonymous user password"   
    docker exec -it $docker_container mysql -u '' -p -e"
   
    CREATE DATABASE IF NOT EXISTS $database;
    use $database; 
   
    source var/lib/mysql_backup.sql; 
    SET @P=NULL;
    SELECT group_concat(partition_name) INTO @P FROM INFORMATION_SCHEMA.PARTITIONS WHERE table_schema='$database' and table_name='$table' and partition_name NOT IN ('$partitions');
    select @P; 
    SELECT IF(ISNULL(@P), 'Check names of database,table and partitions again' , exit ) as '';
    SET @query1=concat('alter table $table truncate partition ',@P);
       prepare stmt1 from @query1;
       execute stmt1;
       DEALLOCATE PREPARE stmt1;
    select concat('Truncation',' Completed') as '';   
   " 
fi
