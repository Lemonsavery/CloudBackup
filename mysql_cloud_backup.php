<?php
/*
These four definitions must be given the specific login credentials associated
with the MySQL database you created.
*/
define ('DB_USER', 'example_username');
define ('DB_PASSWORD', 'example_password');
define ('DB_HOST', 'localhost');
define ('DB_NAME', 'example_database_name');

// Connect to database
$dbc = @mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD) or
  die ('Could not connect to MySQL:' . mysqli_error($dbc));

// Select database
@mysqli_select_db($dbc, DB_NAME) or
  die ('Could not select the database: ' . mysqli_error($dbc));
?>
