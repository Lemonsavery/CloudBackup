<?php
// Replace this string with the directory of the mysql_cloud_backup.php file.
$script_dir = "../../../Scripts/";

$user_id = $_GET["uid"];


// Connect to the database.
require_once($script_dir . 'mysql_cloud_backup.php');

// Make sure connection was successful.
if ($dbc -> connect_errno){
	echo("(get_tags.php) failed connection to db - (ERR " . $dbc -> connect_errno . ") " . $dbc -> connect_error . ",");
	die();
}

// Searching for whether this user_id has backed up tags before.
if (!($search_query = $dbc -> prepare("
SELECT
	`tag`
FROM
	`CloudBackupTable`
WHERE
	`user_id` = ?
"))){
	echo("(get_tags.php) error during search prepare() - (ERR ". $dbc -> errno . ") " . $dbc -> error . ",");
	die();
}
if (!$search_query -> bind_param("s", $user_id)){
	echo("(get_tags.php) error during search bind_param() - (ERR ". $dbc -> errno . ") " . $dbc -> error . ",");
	die();
}
if (!$search_query -> execute()){
	echo("(get_tags.php) error during search execute() - (ERR ". $dbc -> errno . ") " . $dbc -> error . ",");
	die();
}

// Either the search found tags, or it found nothing.
if (!$search_query -> bind_result($tags)){
	echo("(get_tags.php) error during search bind_result() for tag - (ERR ". $dbc -> errno . ") " . $dbc -> error . ",");
	die();
}
if ($search_query -> fetch()){
	echo("(get_tags.php) tags found");
	echo("<" . $tags);

	while($search_query -> fetch()){
		echo("<" . $tags);
	}
}else{
	echo("(get_tags.php) no tags found,");
}
exit();
?>
