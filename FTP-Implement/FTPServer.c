// FTP Server (Server)
// Description: This is the C file for the FTP server-side host. It uses select() to
//              switch between different clients.
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
#include<sys/time.h>
#include<pthread.h>
#include "FTPServer.h"

#define SERVER_IP "0.0.0.0"         // server IP address
#define PORT 5000                   // server port #
#define BACKLOG 10                  // max number of clients that can backlog 
#define MAX_BUFFER_SIZE 2048    // max transfer buffer size

// ==========================================================================================
// ==========================================================================================
// Functions

// Check Input for Commands
bool checkInput(int inputArgCount, int checkArgCount, char* inputCommand[], char* checkCommand){
    if( (inputArgCount == checkArgCount) && (strcmp(inputCommand[0], checkCommand) == 0) ){
        return true;
    }
    return false;
}

// Check User Authentication (for commands)
bool checkAuth(int client_fd, int authenticated[][2], char* to_client){
    // if username is authenticated
    if(authenticated[client_fd][0] > -1){
        // if password is authenticated
        if(authenticated[client_fd][1] != 0){
            // continue doing whatever was happening
            return true;
        }
        else{
            sprintf(to_client, "%s\n", "Password authentication pending.");
            printf("%s",to_client);
        }
    } 
    else{
        // save output to send error to client
        sprintf(to_client, "%s\n", "Username authentication pending.");
        printf("%s",to_client);
    }
    // if auth failed, send error message to client
    send(client_fd, to_client, strlen(to_client), 0);
    return false;
}

// Function for "put"
int receive_file(char* filename, int client_fd){
    char from_client[256];  
    char to_client[256];
    bzero(&from_client, sizeof(from_client));
    bzero(&to_client, sizeof(to_client));
    // send ack
    sprintf(to_client, "%s", "Request Acknowledged. Opening new socket.\n");
    if(send(client_fd, to_client, strlen(to_client), 0) < 0){
        perror("send");
        return -1;
    }
    printf("%s",to_client);
    // receive message seen
    bzero(&from_client, sizeof(from_client));
    if(recv(client_fd, from_client, sizeof(from_client), 0) < 0){
        perror("recv");
        return -1;
    }

    // Create Data Socket
    int data_sd;
    // for reusing address
    if((data_sd = socket(AF_INET, SOCK_STREAM, 0)) < 0 ){
        perror("socket");
        return -1;
    }
    if(setsockopt(data_sd,SOL_SOCKET,SO_REUSEADDR,&(int){1},sizeof(int)) < 0) {
        perror("setsockopt");
        exit(EXIT_FAILURE);
    }
    struct sockaddr_in data_addr;
    int sin_size = sizeof(data_addr);
    int portNum = PORT;
    // buffer with 0s
    bzero(&data_addr, sizeof(data_addr));
    // connection port is the port of server PLUS ONE
    data_addr.sin_family = AF_INET;
    // data_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    data_addr.sin_port = htons(portNum + 1);
    // look for unused port
    while(bind(data_sd, (struct sockaddr*)&data_addr, sizeof(data_addr)) < 0 ){
        portNum++;
        data_addr.sin_port = htons(portNum);
    }
    printf("Created data transfer socket %d for IP %s and Port Number %d.\n", data_sd, inet_ntoa(data_addr.sin_addr), htons(data_addr.sin_port));
    
    // listen
    if(listen(data_sd, BACKLOG)<0){
        perror("Listen Error:");
        return -1;
    }
    // let client know port number to signifiy ready to connect
    sprintf(to_client, "%s %d\n", inet_ntoa(data_addr.sin_addr), htons(data_addr.sin_port));
    send(client_fd, to_client, strlen(to_client), 0);
    // accept incoming connection
    int data_fd = accept(data_sd, (struct sockaddr*)&data_addr, (socklen_t*)&sin_size);
    if(data_fd<0)
        perror("Connection failed..!");
    else
    {
        // Receive file
        char buffer[MAX_BUFFER_SIZE];
        int bytesTotal;
        int bytesReceived;
        FILE *fp;
        if(!(fp = fopen(filename,"w"))){
            perror("fopen");
            return -1;
        }
        else
        {
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
            // close file
            fclose(fp);
            printf("File '%s' Received. Total bytes received: %d.\n", filename, bytesTotal);
            // close data socket
            close(data_fd);
        }
    }
    return 0;
}

// Function for "get"
int send_file(char* filename, int client_fd, int bytesReceived){
    char from_client[256];  
    char to_client[256];
    bzero(&from_client, sizeof(from_client));
    bzero(&to_client, sizeof(to_client));

    FILE *fp = fopen(filename, "r");
    // if file doesn't exist, send error
    if(fp == NULL){
        sprintf(to_client, "Error: File '%s' not found.\n", filename);
        if(send(client_fd, to_client, strlen(to_client), 0) < 0){
            perror("send");
            return -1;
        }
        printf("%s",to_client);
    }
    // if file exists
    else{
        // send ack
        sprintf(to_client, "%s", "Request Acknowledged. Opening new socket.\n");
        if(send(client_fd, to_client, strlen(to_client), 0) < 0){
            perror("send");
            return -1;
        }
        printf("%s",to_client);

        // receive message seen
        bzero(&from_client, sizeof(from_client));
        if((bytesReceived = recv(client_fd, from_client, sizeof(from_client), 0) ) < 0){
            perror("recv");
            return -1;
        }

        // Create Data Transfer Socket
        int data_sd;
        // for reusing address
        if((data_sd = socket(AF_INET, SOCK_STREAM, 0)) < 0 ){
            perror("socket");
            return -1;
        }
        if(setsockopt(data_sd,SOL_SOCKET,SO_REUSEADDR,&(int){1},sizeof(int)) < 0) {
            perror("setsockopt");
            exit(EXIT_FAILURE);
        }


        struct sockaddr_in data_addr;
        int sin_size = sizeof(data_addr);
        int portNum = PORT;

        // buffer with 0s
        bzero(&data_addr, sizeof(data_addr));
        // connection port is the port of server PLUS ONE
        data_addr.sin_family = AF_INET;
        // data_addr.sin_addr.s_addr = htonl(INADDR_ANY);
        data_addr.sin_port = htons(portNum+1);
        // look for unused port
        while(bind(data_sd, (struct sockaddr*)&data_addr, sizeof(data_addr)) < 0 ){
            portNum++;
            data_addr.sin_port = htons(portNum);
        }
        printf("Created data transfer socket %d for IP %s and Port Number %d.\n", data_sd, inet_ntoa(data_addr.sin_addr), htons(data_addr.sin_port));
        // send socket details to client
        sprintf(to_client, "%s %d\n", inet_ntoa(data_addr.sin_addr), htons(data_addr.sin_port));
        if(send(client_fd, to_client, strlen(to_client), 0) < 0){
            perror("send");
            return -1;
        }
        // receive the ok to start listening
        bzero(&from_client, sizeof(from_client));
        if((bytesReceived = recv(client_fd, from_client, sizeof(from_client), 0) ) < 0){
            perror("recv");
            return -1;
        }
        // start listening
        if(listen(data_sd, BACKLOG) < 0 ){
            perror("listen");
            return -1;
        }
        // send that data socket is listening to client (just an empty message from before is fine)
        sprintf(to_client, "%s\n", "Listening.");
        if(send(client_fd, to_client, strlen(to_client), 0) < 0){
            perror("send");
            return -1;
        }
        // accept connection from data socket
        int data_fd;
        if((data_fd = accept(data_sd, (struct sockaddr*)&data_addr, (socklen_t*)&sin_size)) < 0){
            perror("accept");
            return -1;
        }
        // check ready
        bzero(&from_client, sizeof(from_client));
        if((bytesReceived = recv(client_fd, from_client, sizeof(from_client), 0) ) < 0){
            perror("recv");
            return -1;
        }
        // send files (reused code from lab)
        int bytesTotal = 0;
        char buffer[MAX_BUFFER_SIZE];
        do{
            int i;
            for(i = 0; i < MAX_BUFFER_SIZE; i++){
                char ch = fgetc(fp);
                if(feof(fp)) break;
                buffer[i] = ch;
            }
            bytesTotal +=i;
            if(send(data_fd, buffer, i, 0) < 0){
               perror("send");
               return -1;
            }
        } while(!feof(fp));
        printf("File '%s 'Sent. Total bytes sent: %d \n", filename, bytesTotal);
        // close data socket
        fclose(fp);
        close(data_fd);
    }
    return 0;
}

// Serving Client (based on code from lab)
int serve_client(int client_fd, const char *users[4][2], int authenticated[][2], char** wds){

    // Get Client Info
    struct sockaddr_in client_addr;
    int sin_size = sizeof(client_addr);
    if(getpeername(client_fd, (struct sockaddr*)&client_addr, (socklen_t*)&sin_size) < 0){
        perror("getpeername");
        return -1;
    }
	
    // Receive Input From Client
    int bytesReceived;
	char from_client[256];	
    char to_client[256];
	bzero(&from_client,sizeof(from_client));
    bzero(&to_client,sizeof(to_client));
	if( (bytesReceived = recv(client_fd,from_client,sizeof(from_client),0)) <= 0)
	{
        if(bytesReceived == 0){
            printf("Socket %d was closed.\n", client_fd);
            return -1;
        }
        else{
            perror("recv");
		    return -1;
        }
	}

    // Parse Client Input
    char from_client_cpy[strlen(from_client)];
    // remove newline at end and create copy
    from_client[strcspn(from_client, "\n")] = 0;
    strcpy(from_client_cpy, from_client);
    // use strtok to split input
    int argCount = 0;
    char* args[2];                   // maximum # of arguments is 2
    char* token = strtok(from_client_cpy, " ");
    while(token != NULL){
        args[argCount] = token;
        token = strtok(NULL, " ");
        argCount++;
    }
    
    // Set the directory to whereever the client left off
    chdir(wds[client_fd]);
    printf("Current Directory: %s\n", wds[client_fd]);
    // User identification sent
    if(checkInput(argCount,2,args,"user")){
        // Check what user name was sent aganst list of users
        int userNum = 0;
        while(userNum < 4 && strcmp(users[userNum][0], args[1]) != 0){
            userNum++;
        }
        // User was not found
        if(userNum == 4){
            // Send back no user found
            sprintf(to_client, "Invalid username. '%s' was not found.\n", args[1]);
            printf("%s",to_client);
            send(client_fd, to_client, strlen(to_client), 0);
        }
        else{
            authenticated[client_fd][1] = 0;    // Make sure to invalidate password when setting user
            authenticated[client_fd][0] = userNum;
            sprintf(to_client, "Valid username. '%s' validated for clientfd %d.\n", args[1], client_fd);
            printf("%s",to_client);
            send(client_fd, to_client, strlen(to_client), 0);
        }
    }
    // User password passed, compare that to the set username
    else if(checkInput(argCount,2,args,"pass")){
        int userNum = authenticated[client_fd][0];
        // Check to make sure a username has been passed first
        if(userNum != -1){
            // Check to see if right password
            if(strcmp(args[1],users[userNum][1])==0){
                sprintf(to_client, "Valid password. Authentication complete.\n");
                printf("%s",to_client);
                authenticated[client_fd][1] = 1;    // Authenticated for this user on this fd
                send(client_fd, to_client, strlen(to_client), 0);
            }
            else{
                sprintf(to_client, "Invalid password. Please try again.\n");
                printf("%s",to_client);
                send(client_fd, to_client, strlen(to_client), 0);
            }
        }
        else{
            sprintf(to_client, "Username must be validated first.\n");
            send(client_fd, to_client, strlen(to_client), 0);
        }
    }
	else if(checkInput(argCount,1,args,"quit"))
	{
		printf("Client with IP %s and Port Number %d disconnected.\n",inet_ntoa(client_addr.sin_addr), (client_addr.sin_port));
		return -1;
	}
    // if username and password have BOTH been authenticated, access to other commands
    // checkAuth will AUTOMATICALLY send a response to the client if authentication isn't complete
    else if(checkAuth(client_fd, authenticated, to_client)){
        // Upload a file to the server
        if(checkInput(argCount,2,args,"put")){
            receive_file(args[1], client_fd);
        }
        // Download a file from the server
        else if(checkInput(argCount,2,args,"get")){
            send_file(args[1], client_fd, bytesReceived);   
        }
        // List all files in current file directory
        else if(checkInput(argCount,1,args,"ls")){
                FILE *fp;
                char entries[500];
                fp = popen("ls", "r");
                if (fp == NULL){
                    sprintf(to_client, "Error opening FP.\n");
                }
                while (fgets(entries, 500, fp) != NULL){
                    strcat(to_client, entries);
                }
                printf("%s\n", to_client);
                pclose(fp);
                send(client_fd, to_client, strlen(to_client), 0);
        }
        // Change to a different directory on the server
        else if(checkInput(argCount,2,args,"cd")){
                chdir(args[1]);
                sprintf(to_client, "\n");
                // send(client_fd, to_client, strlen(to_client), 0);
                // Save new working directory for future use
                char buffer[256];
                getcwd(buffer, 256);
                strcpy(wds[client_fd], buffer);
                sprintf(to_client, "%s\n",wds[client_fd]);
                send(client_fd, to_client, strlen(to_client), 0);
        }
        // Displays current server directory
        else if(checkInput(argCount,1,args,"pwd")){
                getcwd(to_client, 256);
                char newLine = '\n';
                strncat(to_client, &newLine, 1);
                send(client_fd, to_client, strlen(to_client), 0);
        }
    }
	return 0;
}

// ==========================================================================================
// ==========================================================================================
// Execution

int main(){

    // duplicate clients with the same username/passwords are allowed.
    const char *users[4][2]={
        {"cole", "test"},
        {"joseph", "password"},
        {"yasir", "aSupers0phisticatedpa55worD"},
        {"khalid", "aPa55w0rdjustass0phisticated"}
    };

    // Socket Setup
    int server_fd = socket(AF_INET, SOCK_STREAM, 0);
    // printf("server_fd = %d\n", server_fd);
    if(server_fd < 0){
        perror("socket");
        exit(EXIT_FAILURE);
    }
    // for reusing address
    if(setsockopt(server_fd,SOL_SOCKET,SO_REUSEADDR,&(int){1},sizeof(int)) < 0) {
        perror("setsockopt");
        exit(EXIT_FAILURE);
    }
    
    // Address Setup
    struct sockaddr_in server_address, client_addr;
    int sin_size = sizeof(client_addr);
    // buffer with 0s
    bzero(&server_address, sizeof(server_address));
    // connection family (IPV4)
    server_address.sin_family = AF_INET;
    // connection port
    server_address.sin_port = htons(PORT);
    // saving IP address
    server_address.sin_addr.s_addr = inet_addr(SERVER_IP);
    // bind after setting up
    if(bind(server_fd, (struct sockaddr*)&server_address, sizeof(server_address)) < 0 ){
        perror("bind");
        exit(EXIT_FAILURE);
    }

    // check IP address for validity (using text-to-binary) (debug) 
    printf("Server IP: %s | Port Num: %d \n", SERVER_IP, PORT);
    
    // Listen for Connection
    if( listen(server_fd, BACKLOG) < 0){
        perror("listen");
        exit(EXIT_FAILURE);
    }
    fd_set full_fdset,ready_fdset;
	FD_ZERO(&full_fdset);
	FD_SET(server_fd,&full_fdset);
	int max_fd = server_fd;

    struct timeval timer;
    timer.tv_sec = 2;
    timer.tv_usec = 0;

    // Status for user authentication and which fd has been authenticated for it
    int (*authenticated)[2] = malloc((max_fd+1) * sizeof(int) * 2);
    // Index coresponds to fd, number for first col corresponds to user authenticated, number in 2nd row is if pass has authenticated
    for(int i = 0; i <= max_fd; i++){
        authenticated[i][0]=-1;
        authenticated[i][1]=0;
    }

    char serverDirectory[256];

    //Array for storing working directories of each client
    char** wds = malloc((max_fd+1) * 256);
    //Initialize all with the current working directory
    for(int i = 0; i <= max_fd; i++){
        wds[i] = (char *)malloc(256);
        getcwd(serverDirectory, 256);
        strcpy(wds[i], serverDirectory);
    }

    // Start Connections Using Select() (modified code from lab)
	while(1){   
        // Sync full_fdset and ready_set
        ready_fdset = full_fdset;
        if(select(max_fd+1,&ready_fdset, NULL, NULL, NULL)<0){
            perror("select");
            exit(EXIT_FAILURE);
        }
        for(int fd = 0; fd <= max_fd; fd++){
            // printf("%d, ", FD_ISSET(fd,&ready_fdset));
            if(FD_ISSET(fd, &ready_fdset)){
                if(fd == server_fd){
                    // Displays IP and port number of client, as well as descriptor for select()
                    int new_fd = accept(server_fd,(struct sockaddr*)&client_addr, (socklen_t*)&sin_size);
                    printf("Client with IP address %s connected from port %d.\n", inet_ntoa(client_addr.sin_addr), (client_addr.sin_port) );
                    // printf("client fd = %d \n",new_fd);

                    FD_SET(new_fd, &full_fdset);
                    if(new_fd > max_fd){
                        max_fd = new_fd;
                        // Resize authentication array to fit new user
                        int (*tmp)[2] = realloc(authenticated, (max_fd+1) * sizeof(int) * 2);
                        if (tmp){
                            authenticated = tmp;
                            authenticated[new_fd][0]=-1;
                            authenticated[new_fd][1]=0;
                        }
                        //Resize working directories array for new user
                        char** wdsTemp = realloc(wds, (max_fd+1) * sizeof(*wds));
                        if (wdsTemp){
                            wds = wdsTemp;
                            wds[new_fd] = malloc(256);
                            strcpy(wds[new_fd], serverDirectory);
                        }
                    }
                }
                else{
                    if(serve_client(fd, users, authenticated, wds) == -1){
                        // Client has disconnected, clear bit from set
                        close(fd);
                        FD_CLR(fd,&full_fdset);

                        // Clear authentication for that disconnected
                        authenticated[fd][0] = -1;
                        authenticated[fd][1] = 0;

                        //Reset working dir of wds
                        strcpy(wds[fd],serverDirectory);

                        // Find next lowest fd
                        if(max_fd == fd){
                            for(int i = max_fd-1; i >= 0; i--){
                                if(FD_ISSET(i,&full_fdset)){
                                    max_fd = i;
                                    break;
                                }
                            }

                            // Reallocate for authentication
                            int (*tmp)[2] = realloc(authenticated, (max_fd+1) * sizeof(int) * 2);
                            if (tmp){
                                authenticated = tmp;
                            }

                            //Reallocate for working dir
                            char** wdsTemp = realloc(wds, (max_fd+1) * 256);
                            if (wdsTemp){
                                wds = wdsTemp;
                            }
                        }


                    }
                }
            }
        }
    }

    free(authenticated);

    // Free array of working directories of clients
    for(int i = 0; i <= max_fd; i++){
        free(wds[i]);
    }
    free(wds);

    // Close Server Socket
	close(server_fd);

	exit(EXIT_SUCCESS);
}
// ==========================================================================================
// ==========================================================================================