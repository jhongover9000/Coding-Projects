# FTP Implementation

Usage:

	There are two seperate programs, one for the client and one for the server. Each needs to be compiled and run seperate. These programs are configured to run together on a local network and require port 5000 by default. This can be changed in the global variables of the server file. 

	Example execution would be as follows

	Server
	>./server
	Server IP: 0.0.0.0

	Client
	>./client 0.0.0.0 5000 (Or whatever IP is printed by the server)

	Supported Commands:
	user -> sets user for a client
	pass -> sets password for the client
	ls -> list all files in current server directory
	pwd -> list current server directory
	cd -> change the server directory
	!ls -> list all files in current client directory
	!pwd -> list current client directory
	!cd -> change the client directory
	put -> upload a file from the client to the server
	get -> download a file from the server to the client

Design:

	Server

	The design is fairly straight forward. The server program listens for TCP connections and uses select to serve them simultaneously. 

	It also has a 2D array used for authentication. The index of this array coresponds to a client's fd, the first column holds the user that is associated (if any) with that client, and the second column stores whether they had verfied with a password yet. 

	There is also a second array which holds the current working directory of each user. This is needed as when cd is executed, the directory should not change for all users, only the one initiating the cd. By storing all the different client's working directory we can make sure their state in the server is maintained

	Once a client connects, server_client is called whenever a command is passed. This function returns the correct action depending on the input.

	Get and put are very similar commands but flipled. Both open a new TCP connection once basic verification is done and then begins transfering a file between a client and server.

	ls, cd, & pwd are simple commands where status about the server is fetched and sent back to the client. For each the current working directory of that client has to be switched to prior however

	Client

	First a client connects to the server. If the TCP connection is not succesful then it will end the process right there. Otherwise it will go on to accepting commands. The commands supported are user,pass,ls,!ls,pwd!pwd,cd,!cd,put,get. All commands with an ! are local commands and do not send data to the server. They are displaying information about the client's file system. All other commands use a series of messages back and forth with the server. Typically the user command is first where the username is passed to the server. The server will then adjust its authentication status to match that user for the client. Next the password is sent to the server with 'pass'. Right now we have 4 users in our system. 

	User | Pass
	cole test
	joseph password
	yasir 123
	khalid qwerty

	This is all stored in an array in server.c and can be adjusted





