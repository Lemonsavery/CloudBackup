<?php
// Replace this string with the directory of the mysql_cloud_backup.php file.
$script_dir = "../../../Scripts/";

function html_echo_safe($field, &$str){ // Maybe pass &$str instead? If it works it's more resource efficient.
	if(gettype($str) !== "string"){
		echo("0,(store_data.php) $field is not string - field must be string.");
		die();
	}

	for($index = 0; $index < strlen($str); $index++){
		switch($str[$index]){
			case chr(38): // &
				echo("0,(store_data.php) $field contains ampersand at index $index - cannot contain ampersand.");
				die();
			case chr(39): // '
				echo("0,(store_data.php) $field contains apostrophe at index $index - cannot contain apostrophe.");
				die();
			case chr(34): // "
				echo("0,(store_data.php) $field contains quotation mark at index $index - cannot contain quotation mark.");
				die();
			case chr(60): // <
				echo("0,(store_data.php) $field contains less-than sign at index $index - cannot contain less-than sign.");
				die();
			case chr(62): // >
				echo("0,(store_data.php) $field contains more-than sign character at index $index - cannot contain more-than sign.");
				die();
		}
	}

	return $str;
}

$user_id = $_GET["uid"];
// Tags and data must be checked, to make sure they can be echoed safely later.
$tag = html_echo_safe("tag", $_GET["tag"]);
$data = html_echo_safe("data", file_get_contents('php://input'));


// Connect to the database.
require_once($script_dir . 'mysql_cloud_backup.php');

// Make sure connection was successful.
if ($dbc -> connect_errno){
	echo("0,(store_data.php) failed connection to db - (ERR " . $dbc -> connect_errno . ") " . $dbc -> connect_error);
	die();
}

// Searching for whether this user_id has backed up this tag before.
if (!($search_query = $dbc -> prepare("
SELECT
	`primary_key`
FROM
	`CloudBackupTable`
WHERE
	`user_id` = ?
	AND
	`tag` = ?
LIMIT 1
"))){
	echo("0,(store_data.php) error during search prepare() - (ERR ". $dbc -> errno . ") " . $dbc -> error);
	die();
}
if (!$search_query -> bind_param("ss", $user_id, $tag)){
	echo("0,(store_data.php) error during search bind_param() - (ERR ". $dbc -> errno . ") " . $dbc -> error);
	die();
}
if (!$search_query -> execute()){
	echo("0,(store_data.php) error during search execute() - (ERR ". $dbc -> errno . ") " . $dbc -> error);
	die();
}

// Create backup_date for this whole transaction.
$backup_date = round(time() / 86400 + 2440587.5, 7);

// Store the data, either in a new record, or over the old record.
if (!$search_query -> bind_result($primary_key)){
	echo("0,(store_data.php) error during search bind_result() for primary_key - (ERR ". $dbc -> errno . ") " . $dbc -> error);
	die();
}
if ($search_query -> fetch()){
	// If this user_id has stored this tag before, store over that record.

	$search_query -> close();
	if (!($update_query = $dbc -> prepare("
	UPDATE
		`CloudBackupTable`
	SET
		`backup_date` = ?,
		`data` = ?
	WHERE
		`primary_key` = ?
	LIMIT 1
	"))){
		echo("0,(store_data.php) error during update prepare() - (ERR ". $dbc -> errno . ") " . $dbc -> error);
		die();
	}
	if (!$update_query -> bind_param("dsi", $backup_date, $data, $primary_key)){
		echo("0,(store_data.php) error during update bind_param() - (ERR ". $dbc -> errno . ") " . $dbc -> error);
		die();
	}
	if (!$update_query -> execute()){
		echo("0,(store_data.php) error during update execute() - (ERR ". $dbc -> errno . ") " . $dbc -> error);
		die();
	}

	echo("$backup_date,(store_data.php) data successfully updated");

}else{
	// If this user_id has not stored this tag before, store in a new record.

	$search_query -> close();
	if (!($insertion_query = $dbc -> prepare("
	INSERT INTO `CloudBackupTable` (
		`user_id`,
		`tag`,
		`backup_date`,
		`data`
		)
	VALUES (
		?,
		?,
		?,
		?
		)
	"))){
		echo("0,(store_data.php) error during insertion prepare() - (ERR ". $dbc -> errno . ") " . $dbc -> error);
		die();
	}
	if (!$insertion_query -> bind_param("ssds", $user_id, $tag, $backup_date, $data)){
		echo("0,(store_data.php) error during insertion bind_param() - (ERR ". $dbc -> errno . ") " . $dbc -> error);
		die();
	}
	if (!$insertion_query -> execute()){
		echo("0,(store_data.php) error during insertion execute() - (ERR ". $dbc -> errno . ") " . $dbc -> error);
		die();
	}

	echo("$backup_date,(store_data.php) data successfully inserted");

}
exit();
?>
