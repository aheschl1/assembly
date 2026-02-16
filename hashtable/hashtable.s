# Define a hashtable which maps string keys to int32 values
    .set ARG1,  %rdi
    .set ARG2,  %rsi
    .set DARG2, %esi
    .set ARG3,  %rdx
    .set DARG3, %edx
    .set RET1,  %rax
# offsets for hashtable struct
    .set N_SLOTS, $0
    .set SLOTS,   $8

    .globl new_hashtable
    .globl free_hashtable
    .globl hash
    .globl hashtable_insert
    .globl query_hashtable
    .extern calloc
    .extern free

# in our hashtable, we hold:
#  -----------
# |  nslots   |: 8 bytes
#  -----------
# | slot_addr x nslots |: 8 bytes x nsplots
#  -----------
#
# Each slot is:
# ------------
# | key_addr | # 8 bytes
# |  next    | # 8 bytes 
# |  value   | # 4 bytes
#  ----------
new_hashtable:
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp

    # arg1 holds n slots. we need to mul by 8 which is 2^3
    mov ARG1, (%rsp) # save the slot count to top of stack
    sal $3, ARG1 # x8
    add $8, ARG1 # memory to write the length
    mov $1, ARG2 # memory to write the length
    mov $0, %rax  # variadic saftey or something
    call calloc   # alloc heap mem, initially 0s
.post_calloc:
    # now write the slot count
    mov (%rsp), %rcx
    mov %rcx, (RET1)  # first 8 bytes are the slot counts

    # RET1 holds addr, perfect
    leaveq
    retq

.set CURRBYTE, %r9b
hash:
    # stack frame not needed
    # push %rbp
    # mov %rsp, %rbp
    # sub $8, %rsp
    # arg1 holds the ptr to char.
    # we will loop over it until \0
    # the hash will be an 8 byte int
    xor RET1, RET1
    # start loop
    jmp .check
.looptop:
    # update hash note ARG1 already has the right ptr
    # also note, r13b holds the current byte, but we can use the full register to add
    # hash = hash * 131 + ingest
    imul $31, RET1
    movzbq CURRBYTE, %rax # 0 extend
    add %rax, RET1
    # increment ptr
    inc ARG1
.check:
    mov (ARG1), CURRBYTE
    cmp $0, CURRBYTE
    jne .looptop # go back to top of loop if not 0

    # leaveq
    retq

# need to save r8, r9, r10, r11
# TODO save r12, r13
hashtable_insert:
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp

    push %r12
    push %r13

    # ARG1 is table ptr, ARG2 holds key, which is char* - DARG3 holds val which is 32 bitint
    mov ARG1, %r8  # r8 = *table
    mov ARG2, %r9  # r9 = *key
    mov DARG3,%r10d # r10d holds value

    # make hash
    mov %r9, %rdi  
    callq hash

    # RET1 holds the hash, now r11 does
    mov RET1, %rdx   # holds hash
    mov (%r8), %rcx  # hold nslots
    # do a mod on the hash, put into r11 to get idx

    cqo
    idiv %rcx # now, rdx hold idx, which is hash % nslots

breakaa:
    lea 0x8(%r8, %rdx, 8), %r12 # r12 holds the ptr to the entry

    # now, we have a ptr to the entry at the index we extracted

    mov $20, %rdi # nbytes
    mov $1, %rsi  # nmemb
    
    # save caller saved registers
    push %r8
    push %r9
    push %r10 # push it all, its ok 
    callq calloc
    # restore caller saved
    pop %r10
    pop %r9
    pop %r8
    # now, the ptr to the new element is on %rax
    # write this ptr to the appropriate location. use a loop
    # goal: r12 has a ptr to a location where we will write the ptr to the new slot
    # if (%r12) is null, then this is that location
    # otherwise, traverse linked list in loop
    cmpq $0, (%r12)
    je .if_a
.else_a:
    # here, valid ptr, go through linked list
    # we need to dereference, and go there
    mov (%r12), %r12 # r12 points to the top of a node
    add $8, %r12 # move to next ptr
    jmp .check_b
.if_a:
    # here, we will simply skip the else, we have a place to go already in r12
    jmp .end_a
# start loop
.loop:
    mov (%r12), %r12 # move to next
    add $8, %r12 # move to next ptr
.check_b:
# r12 is a ptr to next node
    cmpq $0, (%r12)   # NULL ptr check
    jne .loop
.end_a:
# at this point, we have a ptr to the location to write the ptr to the new node
# it is in r12
    # first make new node
    # mov 0x14, %rdi # arg is size
    # mov $1, %rsi  # nmemb
    # push %r8
    # push %r9
    # callq calloc
    # pop %r9
    # pop %r8

    # ret1 has the address
    # mov %r9, (RET1)
    # mov %r10d, 0x10(RET1)
    # # now, we write the ptr (r12 is callee saved)
    # mov RET1, 0x8(%r12)
# 
    # pop %r13
    # pop %r12
.write:
    mov %rax, (%r12) # write the key ptr to the new node
    mov %r9, (%rax)
    movq $0, 0x8(%rax)
    mov %r10d, 0x10(%rax) # write the value to the new node
    # ponter to value in returne
    lea 0x10(%rax), %rax

    pop %r13
    pop %r12


    leaveq
    retq

free_hashtable: # TODO this is not done, we will need to free the allocated entries
    push %rbp
    mov %rsp, %rbp
    sub $8, %rbp

    # read n slots
    mov (ARG1), ARG1
    # now, we have nslots, convert to bytes
    sal $3, ARG1
    add $8, ARG1 # cover the first int
    # call the calloc
    mov $0, %rax
    callq calloc
    # now it is free
    leaveq
    retq

query_hashtable:
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp
    push %r12

    mov ARG1, %r8  # r8 = *table
    mov ARG2, %r9  # r9 = *key

    mov %r9, ARG1 # prep call to hash
    push %r9
    callq hash
    pop %r9
    mov RET1, %rdx   # holds hash
    mov (%r8), %rcx  # hold nslots
    # do a mod on the hash, put into r11 to get idx
    cqo
    idiv %rcx # now, rdx hold idx, which is hash % nslots

    lea 0x8(%r8, %rdx, 8), %r12 # r12 holds the ptr to the entry
    # now, we need to find the slot with equal key, or, return null 
    mov (%r12), %r10 # r10 holds the ptr
    cmpq $0, %r10 # if this is 0, then we ineed return null
    # return 0
    mov $0, %rax
    je .exit
# here we need to walk through the linked list
# if we dereference the ptr, and then pass the ptr to the key as well as lookup key to strcmp we see if eql
    jmp .cmp3
.loopc:
    # here we need to simply grab the ptr to next and put it in r10
    mov 0x8(%r10), %r10
    # make sure not null next
    cmp $0, %r10
    mov $0, %rax # set to 0 incase we return 
    je .exit
.cmp3:
    push %r10
    push %r9
    mov %r10, %rdi
    mov %r9, %rsi
    callq strcmp
    # now rax has the cmp result
    cmp $0, %rax
    pop %r9
    pop %r10
    je .loopc # keep traversing if not equal
    # we return value
    lea 0x10(%r10), %rax
.exit:
    pop %r12

    leaveq
    retq

.section .note.GNU-stack,"",@progbits # non executable stack
