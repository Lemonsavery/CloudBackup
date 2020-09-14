# CloudBackup
 
The purpose of the CloudBackup system is to provide a simple and easy to use cloud data storage system to Gideros developers, assuming that the developer has a server to use this system on. This system could be used for backing up user’s application data in case of device failure, or if the user wants to move their data to another client application on another device. This system is meant to be highly general, so that it can be used for many purposes up to the developer’s discretion.

This is meant as a simple, quick, general, and easy method of implementing cloud data storage in a Gideros developer’s application, along with having reasonably durable error handling and security.

Details on the system can be found in the CloudBackup Design Specifications PDF.

## Setup

1. Have a functioning webserver capable of running a MySQL database and PHP script.
2. Place Backend PHP files on the server, and create a MySQL database.
3. Take the login credentials necessary to access that database, and place them at the top of mysql_cloud_backup.php.
4. Whatever the directory of mysql_cloud_backup.php is in your server, that directory must be placed at the top of every other PHP file.
5. The CloudBackup.lua defines the CloudBackup object, which serves as the tool through which the CloudBackup system can be incorperated into your Gideros program.
6. In CloudBackup.lua, the function originateTable should be executed.

## Future Improvements

- An improved README with examples.
- A demo of the system being used in a simple game. (Maybe a bare-bones clicker game about clicking cows, and you can save your score) 🐮
- Potentially creating a tutorial on how to set up the simplest server capable of running CloudBackup.
- Allowing for huge strings to be stored/handled.
- Improving the wording and format of error messages, and adding error codes.
- Add an API function to encode/decode for characters [&,’,”,<,>], using the substring of the developer’s choice.
- Restructuring the files such that installation of backend is easier.
