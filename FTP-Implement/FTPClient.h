// FTP Server Header
//========================================================================================================
// Header Guard
#ifndef CLIENT_H
#define CLIENT_H
//========================================================================================================
//Includes

//========================================================================================================
// Content

//Used to print all commands
void help();

//Used to check the input the user has entered
bool checkInput(int inputArgCount, int checkArgCount, char* inputCommand[], char* checkCommand);

//Check for authenticated from the server so some commands do not proceed
bool isAuthenticated(char* from_server, char* from_server_copy);

//Used for incoming requests from a server
bool reqReceived(char* from_server, char* from_server_copy);

//Used to parse an input from the user into the command and the content
void parseInput(char* args[], char* token, char* inputCopy);
//========================================================================================================
//Header Guard End
#endif  // CLIENT_H