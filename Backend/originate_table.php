<?php
// Replace this string with the directory of the mysql_cloud_backup.php file.
$script_dir = "../../../Scripts/";

// Connect to the database.
require_once($script_dir . 'mysql_cloud_backup.php');

// Make sure connection was successful.
if ($dbc -> connect_errno){
	echo("failed connection to db - " . $dbc -> connect_error);
	die();
}

// Originate the table.
$query_result = $dbc -> query("
CREATE TABLE
  `CloudBackupTable` (
    `primary_key` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` varchar(255) NOT NULL,
    `tag` varchar(255),
    `backup_date` DOUBLE,
    `data` MEDIUMTEXT
    )
");

// Make sure origination was successful.
if ($dbc -> errno){
  if ($dbc -> errno == 1050){
    echo("table is already originated");
  }else{
    echo("error during table origination - " . $dbc -> error);
  }
}else{
  echo("table originated successfully");
}
exit();
?>
