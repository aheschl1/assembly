    .section .rodata
fmt:
    .string "Hello, World!\n"

    .text
    .globl main
    .extern printf

main:
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp       # align

    mov $0, %rax            # how many float registers
    lea fmt(%rip), %rdi     # addr of ro data, relative to ip

    callq printf

    leaveq
    retq

.section .note.GNU-stack,"",@progbits # non executable stack
