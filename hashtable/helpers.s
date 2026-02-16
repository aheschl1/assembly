
    .globl allocate

# replacement for calloc, using mmap syscall
allocate:
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp

    mov $9, %rax # set the syscall id
    # length
    mov %rdi, %rsi # we do the second arg, nbytes first
    mov $0, %rdi # no *adrr, choose for us
    mov $3, %rdx # READ | WRITE
    mov $0x22, %r10 # MAP_PRIVATE | MAP_ANONYMOUS
    mov $-1, %r8              # fd = -1, cause no file (anon map)
    mov $0, %r9               # offset = 0
    syscall

    leaveq
    retq

.section .note.GNU-stack,"",@progbits # non executable stack
