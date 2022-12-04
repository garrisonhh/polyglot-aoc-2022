// advent of code 2022 problem 3 with only linux syscalls

// helpful macros ==============================================================

// syscalls
#define SYS_READ        $0
#define SYS_WRITE       $1
#define SYS_OPEN        $2
#define SYS_CLOSE       $3
#define SYS_LSEEK       $8
#define SYS_MMAP        $9
#define SYS_MUNMAP      $11
#define SYS_EXIT        $60

// macros usually in unistd or libc
#define STDOUT          $1
#define SEEK_END        $2
#define PROT_READ       $1
#define MAP_PRIVATE     $2

// function entry
.macro begin frame_size
        push    %rbp
        mov     %rsp, %rbp
        sub     \frame_size, %rsp
.endm

// function exit
.macro end frame_size
        add     \frame_size, %rsp
        pop     %rbp
        ret
.endm

// general utilities ===========================================================

// finds length of a c string
strlen:
#define FRAME   $0
        begin   FRAME

        xor     %rax, %rax

strlen_count_loop:
        cmpb    $0, (%rdi)
        jz      strlen_count_exit
        add     $1, %rdi
        add     $1, %rax
        jmp     strlen_count_loop

strlen_count_exit:

        end     FRAME
#undef FRAME

// prints a c string
print:
#define FRAME   $16
        begin   FRAME

        mov     %rdi, (%rsp)

        // find length
        call    strlen

        // write
        mov     %rax, %rdx
        mov     SYS_WRITE, %rax
        mov     STDOUT, %rdi
        mov     (%rsp), %rsi
        syscall

        end     FRAME
#undef FRAME

endl_endl:      .ascii "\n"

endl:
#define FRAME   $0
        begin   FRAME

        // write
        mov     SYS_WRITE, %rax
        mov     STDOUT, %rdi
        mov     $endl_endl, %rsi
        mov     $1, %rdx
        syscall

        end     FRAME
#undef FRAME

// dealing with linux ==========================================================

// mmaps a file from a fd, returns pointer to data
// (hey, file length is returned secretly in %rdi)
file_map:
#define FRAME   $16
        begin   FRAME
        mov     %rbx, (%rsp)

        mov     %rdi, %rbx

        // find file length
        mov     SYS_LSEEK, %rax
        mov     $0, %rsi
        mov     SEEK_END, %rdx
        syscall

        // TODO do I need to rewind (seek start) here?

        mov     %rax, +8(%rsp)

        // map memory
        mov     %rax, %rsi
        mov     SYS_MMAP, %rax
        xor     %rdi, %rdi
        mov     PROT_READ, %rdx
        mov     MAP_PRIVATE, %r10
        mov     %rbx, %r8
        xor     %r9, %r9
        syscall

        mov     +8(%rsp), %rdi
        mov     (%rsp), %rbx
        end     FRAME
#undef FRAME

// solution ====================================================================

// entry point =================================================================

.global _start
_start:
        // get argv[1] into %rdi
        pop     %rax
        pop     %rax
        pop     %rdi

        // open file in read only mode + store fd on stack
        mov     SYS_OPEN, %rax
        xor     %rsi, %rsi
        syscall
        push    %rax

        // map file + store ptr and len on stack
        mov     %rax, %rdi
        call    file_map
        push    %rax
        push    %rdi

        // TODO do whatever...

        // (print the file as a test)
        mov     %rdi, %rdx
        mov     %rax, %rsi
        mov     SYS_WRITE, %rax
        mov     STDOUT, %rdi
        syscall

        // unmap file
        pop     %rsi
        pop     %rdi
        mov     SYS_MUNMAP, %rax
        syscall

        // close file
        mov     SYS_CLOSE, %rax
        pop     %rdi
        syscall

        // exit(0)
        mov     SYS_EXIT, %rax
        xor     %rdi, %rdi
        syscall
