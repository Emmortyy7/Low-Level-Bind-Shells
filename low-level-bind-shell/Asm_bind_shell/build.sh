nasm -f elf32 bind_shell.asm -o bind_shell.o 
ld -m elf_i386 bind_shell.o -o bind_shell
