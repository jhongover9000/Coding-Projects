// FTP Server (Client)
// Description: This is the C file for the FTP client-side host.
// ==========================================================================================
// ==========================================================================================
// Includes and Defines
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<stdbool.h>
#include<sys/socket.h>
#include<sys/types.h>
#include<arpa/inet.h>
#include<unistd.h>
#include "FTPClient.h"

#define MAX_BUFFER_SIZE 2048

// ==========================================================================================
// ==========================================================================================
// Functions

// Print Available Commands
void help(){
    printf("\e[1;1H\e[2J");
    printf("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n");
    printf("                           Commands Available\n\n");
    printf("- user <username>: authenticate username\n");
    printf("- pass <password>: authenticate password\n");
    printf("- Note: Authentication is needed for following commands.\n");
    printf("- get <filename>: download a specific file\n");
    printf("- put <filename>: upload a specific file\n");
    printf("- ls: view all files in the current directory (server)\n");
    printf("- !ls: view all files in the current directory (client)\n");
    printf("- cd <directory>: change the current directory (server)\n");
    printf("- !cd <directory>: change the current directory (client)\n");
    printf("- pwd: display the current directory (server)\n");
    printf("- !pwd: display the current directory (client)\n");
    printf("- quit: exit the FTP session and close the connection\n");
    printf("- help: display the available commands\n");
    printf("- clear: clear screen\n");
    printf("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n");
}

// Check Input for Commands
bool checkInput(int inputArgCount, int checkArgCount, char* inputCommand[], char* checkCommand){
    if( (inputArgCount == checkArgCount) && (strcmp(inputCommand[0], checkCommand) == 0) ){
        return true;
    }
    return false;
}

// Receive Validation of Input from Server
bool isAuthenticated(char* from_server, char* from_server_copy){
    char* serverToken;
    strcpy(from_server_copy, from_server);
    from_server_copy[strcspn(from_server_copy, "\n")] = 0;
    serverToken = strtok(from_server_copy, " ");
    // if valid
    if(strcmp(serverToken, "Valid") == 0){
        printf("Server: %s", from_server);
        return true;
    }
    // if invalid
    printf("Server: %s", from_server);
    return false;
}

// Check Request Accept from Server
// : meant for every request that is sent from the client; server checks and responds if
//   the request is valid (i.e. if the file exists, or if the directory exists, etc.)
bool reqReceived(char* from_server, char* from_server_copy){
    char* serverToken;
    strcpy(from_server_copy, from_server);
    from_server_copy[strcspn(from_server_copy, "\n")] = 0;
    serverToken = strtok(from_server_copy, " ");
    // if received and accepted from server, will start with "Request acknowledged."
    if(strcmp(serverToken, "Request") == 0){
        printf("Server: %s", from_server);
        return true;
    }
    // if received but not accepted
    printf("Server: %s", from_server);
    return false;
}

// Parse input
void parseInput(char* args[], char* token, char* inputCopy){
    int argCount = 0;
    while(token != NULL){
        // save string
        args[argCount] = token;
        // get next token
        token = strtok(NULL, " ");
        argCount++;
    }
}

// ==========================================================================================
// ==========================================================================================
// Execution
int main(int argc, char* argv[]){

    // Initialization Variables
    bool isRunning = true;
    unsigned char buffer[sizeof(struct in_addr)];
    char ipAddress[INET_ADDRSTRLEN];
    int portNum;
    bool userAuthenticated = false;
    bool passAuthenticated = false;
    char ready[10] = "ready";

    // Validation of Command Line Arguments
    // i.e. ./FTPClient 0.0.0.0 5000
    if(argc != 3){
        // If not than 3 arguments, return error and exit.
        printf("Usage is './FTPClient <ftp server IP address> <ftp server port number>'.\n");
        exit(EXIT_FAILURE);
    }
    // check IP address for validity (using text-to-binary)
    int s;
    s = inet_pton(AF_INET, argv[1], buffer);
    // inet_pton returns negative if there is an error, 0 if format is incorrect, 1 if converted
    if (s < 0){
        perror("inet_pton");
        exit(EXIT_FAILURE);
    }
    else if (s == 0){
        fprintf(stderr, "Usage: IP address format is incorrect. (ddd.ddd.ddd.ddd where d is an integer)\n");
        exit(EXIT_FAILURE);
    }
    if (inet_ntop(AF_INET, buffer, ipAddress, INET_ADDRSTRLEN) == NULL){
        perror("inet_ntop");
        exit(EXIT_FAILURE);
    }
    // printf("Server IP: %s \n", ipAddress);

    // Save Port Number
    if(atoi(argv[2]) == 0){
        // check if input is number
        fprintf(stderr,"Usage: Port number is an integer.");
    }
    sscanf(argv[2], "%d", &portNum);
    // printf("Connecting to Port Number: %d \n", portNum);

    // Server Address Setup
    struct sockaddr_in server_address, transfer_address;
    bzero(&server_address, sizeof(server_address));
    // connection family (IPV4)
    server_address.sin_family = AF_INET;
    // connection port
    server_address.sin_port = htons(portNum);
    // saving IP address (works but for testing use local server)
    server_address.sin_addr.s_addr = inet_addr(ipAddress);
    // server_address.sin_addr.s_addr = htonl(INADDR_ANY);
        
    // Socket Creation
    int server_fd = socket(AF_INET, SOCK_STREAM, 0);
    printf("server_fd = %d\n", server_fd);
    if(server_fd < 0){
        perror("socket");
        exit(EXIT_FAILURE);
    }

    // Connect to Server
    if(connect(server_fd, (struct sockaddr*)&server_address, sizeof(server_address)) < 0){
        perror("connect");
        exit(EXIT_FAILURE);
    }

    // Print Server Details
    printf("\e[1;1H\e[2J");
    printf("Server IP: %s \n", inet_ntoa(server_address.sin_addr));
    printf("Connected to Port Number: %u \n", ntohs(server_address.sin_port));
    printf("Welcome to Cole and Joseph's FTP Server!\n");
    help();


    // Start Receiving Inputs
    while(isRunning){

        // Variables for command line (after startup)
        char user_input[256];                           // user input
        char inputCopy[sizeof(user_input)];
        char from_server[256];                          // server message
        char from_server_copy[sizeof(from_server)];
        int strLen, bytesSent, bytesReceived;
        char data_ipAddress[INET_ADDRSTRLEN];           // for connection
        int data_portNum;

        // Display User Input
        printf("ftp> ");
        fgets(user_input,sizeof(user_input),stdin);
        user_input[strcspn(user_input, "\n")] = 0;
        strcpy(inputCopy, user_input);
        inputCopy[strcspn(inputCopy, "\n")] = 0;

        // Parse Input
        int argCount = 0;
        char* args[2];                   // maximum # of arguments is 2
        char* token = strtok(inputCopy, " ");
        while(token != NULL){
            // save string
            args[argCount] = token;
            // printf("%s\n", args[argCount]);
            // printf("%s\n", token);
            // get next token
            token = strtok(NULL, " ");
            argCount++;
        }

        // Input Validation
        // : since the max number of arguments is 2, if there's more the input is invalid
        if(argCount >= 3){
            printf("Invalid input: too many arguments.\n");
        }
        else{

            // Quit
            if(checkInput(argCount,1,args,"quit")){
                printf("Client: quitting.\n");
                close(server_fd);
                isRunning = false;
                break;
            } 
            // Check available commands
            else if(checkInput(argCount,1,args,"help")){
                help();
            }
            // Clear screen
            else if(checkInput(argCount,1,args,"clear")){
                printf("\e[1;1H\e[2J");
            }
            // Authenticate username
            else if(checkInput(argCount,2,args,"user")){
                // to prevent unneccesary 'user' command sending
                if(userAuthenticated){
                    printf("Username has already been authenticated.\n");
                }
                else{
                    // send username to server
                    if((bytesSent = send(server_fd, user_input, strlen(user_input), 0) ) < 0){
                        perror("send");
                        exit(EXIT_FAILURE);
                    }
                    // receive validation from server
                    bzero(&from_server, sizeof(from_server));
                    if((bytesReceived = recv(server_fd, from_server, sizeof(from_server), 0) ) < 0){
                        perror("recv");
                        exit(EXIT_FAILURE);
                    }
                    // display validity, set username authentication to true if valid
                    if(isAuthenticated(from_server, from_server_copy)){
                        userAuthenticated = true;
                    }
                }
            }
            // Authenticate password
            else if(checkInput(argCount,2,args,"pass")){
                // to prevent unneccesary 'pass' command sending
                if(passAuthenticated){
                    printf("Password has already been authenticated.\n");
                }
                else{
                    // send password to server
                    if((bytesSent = send(server_fd, user_input, strlen(user_input), 0) ) < 0){
                        perror("send");
                        exit(EXIT_FAILURE);
                    }
                    // receive validation from server
                    bzero(&from_server, sizeof(from_server));
                    if((bytesReceived = recv(server_fd, from_server, sizeof(from_server), 0) ) < 0){
                        perror("recv");
                        exit(EXIT_FAILURE);
                    }
                    // display validity, set password authentication to true if valid
                    if(isAuthenticated(from_server, from_server_copy)){
                        passAuthenticated = true;
                    }
                }
            }
            // Upload file to server
            else if(checkInput(argCount,2,args,"put")){
                if((bytesSent = send(server_fd, user_input, strlen(user_input), 0) ) < 0){
                    perror("send");
                    exit(EXIT_FAILURE);
                }
                // receive acknowledgement/rejection from server
                bzero(&from_server, sizeof(from_server));
                if((bytesReceived = recv(server_fd, from_server, sizeof(from_server), 0) ) < 0){
                    perror("recv");
                    exit(EXIT_FAILURE);
                }
                // check message to see if file exists
                if(reqReceived(from_server, from_server_copy)){
                    // send message seen
                    if((bytesSent = send(server_fd, ready, strlen(ready), 0) ) < 0){
                        perror("send");
                        exit(EXIT_FAILURE);
                    }
                    FILE* fp = fopen(args[1],"r");
                    // Check if valid file to upload
                    if(fp == NULL){
                        printf("Error: File '%s' not found.\n", args[1]);
                    }
                    else{
                        // receive socket details from server
                        bzero(&from_server, sizeof(from_server));
                        bzero(&from_server_copy, sizeof(from_server_copy));
                        if((bytesReceived = recv(server_fd, from_server, sizeof(from_server), 0) ) < 0){
                            perror("recv");
                            exit(EXIT_FAILURE);
                        }
                        // parse input
                        strcpy(from_server_copy, from_server);
                        char* socketArgs[2];
                        char* socketToken = strtok(from_server_copy, " ");
                        parseInput(socketArgs, socketToken, from_server_copy);
                        // create data socket
                        int data_fd;
                        if((data_fd = socket(AF_INET, SOCK_STREAM, 0))< 0){
                            perror("socket");
                            exit(EXIT_FAILURE);
                        }
                        struct sockaddr_in temp;
                        bzero(&temp, sizeof(temp));
                        temp.sin_family = AF_INET;
                        temp.sin_addr.s_addr = inet_addr(socketArgs[0]);
                        temp.sin_port = htons(atoi(socketArgs[1]));
                        // Connect to Server
                        if(connect(data_fd, (struct sockaddr*)&temp, sizeof(temp)) < 0){
                            perror("connect");
                            exit(EXIT_FAILURE);
                        }
                        // Send file
                        int bytesTotal = 0;
                        char buffer[MAX_BUFFER_SIZE];
                        do{
                            int i;
                            for(i = 0; i < MAX_BUFFER_SIZE; i++){
                                char ch = fgetc(fp);
                                if(feof(fp)) break;
                                buffer[i] = ch;
                            }
                            bytesTotal+=i;
                            if(send(data_fd, buffer, i, 0) < 0){
                                perror("send");
                                exit(EXIT_FAILURE);
                            }
                        } while(!feof(fp));
                        // close file
                        fclose(fp);
                        printf("File '%s' Sent. Total bytes sent: %d.\n", args[1], bytesTotal);
                        // close data socket
                        close(data_fd);
                    }
                }
            }
            // Download file from server
            else if(checkInput(argCount,2,args,"get")){
                // printf("Client: downloading file %s.\n", args[1]);
                if((bytesSent = send(server_fd, user_input, strlen(user_input), 0) ) < 0){
                    perror("send");
                    exit(EXIT_FAILURE);
                }
                // receive acknowledgement/rejection from server
                bzero(&from_server, sizeof(from_server));
                if((bytesReceived = recv(server_fd, from_server, sizeof(from_server), 0) ) < 0){
                    perror("recv");
                    exit(EXIT_FAILURE);
                }
                // check message to see if file exists
                if(reqReceived(from_server, from_server_copy)){
                    // send message seen
                    if((bytesSent = send(server_fd, ready, strlen(ready), 0) ) < 0){
                        perror("send");
                        exit(EXIT_FAILURE);
                    }
                    // if exists, receive socket details from server
                    bzero(&from_server, sizeof(from_server));
                    bzero(&from_server_copy, sizeof(from_server_copy));
                    if((bytesReceived = recv(server_fd, from_server, sizeof(from_server), 0) ) < 0){
                        perror("recv");
                        exit(EXIT_FAILURE);
                    }
                    // parse input
                    strcpy(from_server_copy, from_server);
                    char* socketArgs[2];
                    char* socketToken = strtok(from_server_copy, " ");
                    parseInput(socketArgs, socketToken, from_server_copy);
                    // create data socket
                    int data_fd;
                    if((data_fd = socket(AF_INET, SOCK_STREAM, 0))< 0){
                        perror("socket");
                        exit(EXIT_FAILURE);
                    }
                    // send ready for connect
                    if((bytesSent = send(server_fd, ready, strlen(ready), 0) ) < 0){
                        perror("send");
                        exit(EXIT_FAILURE);
                    }
                    struct sockaddr_in temp;
                    bzero(&temp, sizeof(temp));
                    temp.sin_family = AF_INET;
                    temp.sin_addr.s_addr = inet_addr(socketArgs[0]);
                    temp.sin_port = htons(atoi(socketArgs[1]));
                    // receive the ok to connect to socket from server
                    bzero(&from_server, sizeof(from_server));
                    if((bytesReceived = recv(server_fd, from_server, sizeof(from_server), 0) ) < 0){
                        perror("recv");
                        exit(EXIT_FAILURE);
                    }
                    // make connection to data socket (modified lab code)
                    if(connect(data_fd, (struct sockaddr*)&temp, sizeof(temp)) < 0){
                        perror("connect");
                        exit(EXIT_FAILURE);
                    }
                    // create file and write into it
                    char buffer[MAX_BUFFER_SIZE];
                    FILE *fp = fopen(args[1], "w");
                    int bytesTotal = 0;
                    if(fp == NULL){
                        perror("fopen");
                    }
                    else{
                        // send ready
                        if((bytesSent = send(server_fd, ready, strlen(ready), 0) ) < 0){
                            perror("send");
                            exit(EXIT_FAILURE);
                        }
                        printf("Requesting file %s.\n", args[1]);
                        do{
                            bzero(&buffer, sizeof(buffer));
                            bytesReceived = recv(data_fd, buffer, sizeof(buffer), 0);
                            if(bytesReceived > 0){
                                fwrite(buffer, 1, bytesReceived, fp);
                            }
                            bytesTotal += bytesReceived;
                        } while(bytesReceived > 0);
                        if(bytesReceived < 0){
                            perror("recv");
                            exit(EXIT_FAILURE);
                        }
                        fclose(fp);
                    }
                    // close data socket
                    close(data_fd);
                    printf("File '%s' Received. Total bytes received: %d.\n", args[1], bytesTotal);
                }
            }
            // List files in current server directory
            else if(checkInput(argCount,1,args,"ls")){
                if((bytesSent = send(server_fd, user_input, strlen(user_input), 0) ) < 0){
                    perror("send");
                    exit(EXIT_FAILURE);
                }
                // receive from server
                bzero(&from_server,sizeof(from_server));
                if((bytesReceived = recv(server_fd, from_server, sizeof(from_server), 0) ) < 0){
                    perror("recv");
                    exit(EXIT_FAILURE);
                }
                printf("Server: %s", from_server);
            }
            // List files in current client directory
            else if(checkInput(argCount,1,args,"!ls")){
                FILE *fp;
                char entries[500];
                fp = popen("ls", "r");
                if (fp == NULL){
                    printf("Error opening FP\n");
                }
                while (fgets(entries, 500, fp) != NULL){
                    printf("%s", entries);
                }
                pclose(fp);
            }
            // Change server directory
            else if(checkInput(argCount,2,args,"cd")){
                if((bytesSent = send(server_fd, user_input, strlen(user_input), 0) ) < 0){
                    perror("send");
                    exit(EXIT_FAILURE);
                }
                // receive from server
                bzero(&from_server,sizeof(from_server));
                if((bytesReceived = recv(server_fd, from_server, sizeof(from_server), 0) ) < 0){
                    perror("recv");
                    exit(EXIT_FAILURE);
                }
                printf("Server: %s", from_server);
            }
            // Change client directory
            else if(checkInput(argCount,2,args,"!cd")){
                char buffer[256];
                chdir(args[1]);
                printf("%s\n", getcwd(buffer, 256));
            }
            // Display current server directory
            else if(checkInput(argCount,1,args,"pwd")){
                if((bytesSent = send(server_fd, user_input, strlen(user_input), 0) ) < 0){
                    perror("send");
                    exit(EXIT_FAILURE);
                }
                // receive from server
                bzero(&from_server,sizeof(from_server));
                if((bytesReceived = recv(server_fd, from_server, sizeof(from_server), 0) ) < 0){
                    perror("recv");
                    exit(EXIT_FAILURE);
                }
                printf("Server: %s", from_server);
            }
            // Display current client directory
            else if(checkInput(argCount,1,args,"!pwd")){
                char buffer[256];
                printf("%s\n", getcwd(buffer, 256));
            }
            // Otherwise command is invalid
            else{
                printf("Invalid input: command '%s' not recognized, or was used incorrectly.\nUse 'help' for details on command usage.\n", args[0]);
            }
        }
    }

    // Close Socket
    close(server_fd);

    exit(EXIT_SUCCESS);
}