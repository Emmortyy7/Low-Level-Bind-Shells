you can change the port in c file by changing port parameter in bind_shell.c

you can change the port in asm file by doing this steps:
->open the asm file
->go to the line that commented htons(4444)
->convert the port you want to hex
->change your hex to network byte order


  
