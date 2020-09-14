<?php
// Replace this string with the directory of the mysql_cloud_backup.php file.
$script_dir = "../../../Scripts/";

$user_id = $_GET["uid"];
$tag = $_GET["tag"];


// Connect to the database.
require_once($script_dir . 'mysql_cloud_backup.php');

// Make sure connection was successful.
if ($dbc -> connect_errno){
	echo("0,(get_data.php) failed connection to db - (ERR " . $dbc -> connect_errno . ") " . $dbc -> connect_error . ",");
	die();
}

// Searching for whether this user_id has backed up this tag before.
if (!($search_query = $dbc -> prepare("
SELECT
	`backup_date`,
	`data`
FROM
	`CloudBackupTable`
WHERE
	`user_id` = ?
	AND
	`tag` = ?
LIMIT 1
"))){
	echo("0,(get_data.php) error during search prepare() - (ERR ". $dbc -> errno . ") " . $dbc -> error . ",");
	die();
}
if (!$search_query -> bind_param("ss", $user_id, $tag)){
	echo("0,(get_data.php) error during search bind_param() - (ERR ". $dbc -> errno . ") " . $dbc -> error . ",");
	die();
}
if (!$search_query -> execute()){
	echo("0,(get_data.php) error during search execute() - (ERR ". $dbc -> errno . ") " . $dbc -> error . ",");
	die();
}

// Either the search found nothing, or it found the backup.
if (!$search_query -> bind_result($backup_date, $data)){
	echo("0,(get_data.php) error during search bind_result() for backup_date and data - (ERR ". $dbc -> errno . ") " . $dbc -> error . ",");
	die();
}
if ($search_query -> fetch()){
	echo("$backup_date,(get_data.php) backup found,");
	echo($data);
}else{
	echo("0,(get_data.php) no backup found,");
}
exit();
?>
