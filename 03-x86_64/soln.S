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
#define FRAME   $8
        begin   FRAME
        push    %rcx

        mov     %rdi, -8(%rbp)

        // find length
        call    strlen

        // write
        mov     %rax, %rdx
        mov     SYS_WRITE, %rax
        mov     STDOUT, %rdi
        mov     -8(%rbp), %rsi
        syscall

        pop     %rcx
        end     FRAME
#undef FRAME

endl_endl:      .ascii "\n"

endl:
#define FRAME   $0
        begin   FRAME
        push    %rcx

        // write
        mov     SYS_WRITE, %rax
        mov     STDOUT, %rdi
        mov     $endl_endl, %rsi
        mov     $1, %rdx
        syscall

        pop     %rcx
        end     FRAME
#undef FRAME

print_decimal:
#define FRAME   $64
        begin   FRAME
        mov     %rcx, -8(%rbp)

        // zero is a special case
        cmp     $0, %rdi
        jnz     print_decimal_nonzero

        mov     $'0', %dil
        call    putchar

        jmp     print_decimal_return

print_decimal_nonzero:

        // store each decimal point in order on stack
        xor     %rcx, %rcx
        mov     %rdi, %rax
        mov     %rsp, %rdi
print_decimal_extrude_loop:
        // divide by 10
        xor     %rdx, %rdx
        mov     $10, %rsi
        div     %rsi

        // store mod 10 + iterate
        movb    %dl, (%rdi)
        add     $1, %rdi
        add     $1, %rcx

        cmp     $0, %rax
        jnz     print_decimal_extrude_loop

        // actually print the numbers
        mov     %rdi, %rax
print_decimal_print_loop:
        sub     $1, %rax
        mov     (%rax), %dil
        add     $'0', %dil
        push    %rax
        push    %rcx
        call    putchar
        pop     %rcx
        pop     %rax
        loop    print_decimal_print_loop

print_decimal_return:
        mov     -8(%rbp), %rcx
        end     FRAME
#undef FRAME

// mmaps a file from a fd, returns pointer to data in %rax and len in %rdi
// file string is EOF-terminated
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

// prints an error and calls exit(1)
// error: [*:0]u8 -> ()
panic:
        call    print
        call    endl

        mov     SYS_EXIT, %rax
        mov     $1, %rdi
        syscall

// u8 -> ()
putchar:
#define FRAME   $1
        begin   FRAME
        push    %rcx

        mov     %dil, -1(%rbp)

        mov     SYS_WRITE, %rax
        mov     STDOUT, %rdi
        mov     %rbp, %rsi
        sub     $1, %rsi
        mov     $1, %rdx
        syscall

        pop     %rcx
        end     FRAME
#undef FRAME

// solution ====================================================================

// custom callconv; takes mask in %rax and bit in %sil, modifies mask to
// include bit. all other registers are preserved.
set_bit:
        push    %rdi
        push    %rcx

        mov     %sil, %cl
        mov     $1, %rdi
        shl     %cl, %rdi
        or      %rdi, %rax

        pop     %rcx
        pop     %rdi
        ret

gen_bitset_unrecognized: .asciz "unrecognized character in gen_bitset"

// str: [*]u8, len: usize -> u64
// generate a bitmask representing the set of alpha characters this contains
// lowercase are stored at bits 0-25 and uppercase at 26-51
gen_bitset:
#define FRAME   $0
        begin   FRAME
        push    %rcx

        xor     %rax, %rax
        mov     %rsi, %rcx
gen_bitset_loop:
        // get *rdi++ into dl
        movb    (%rdi), %dl
        add     $1, %rdi

        // test for lowercase or uppercase
        sub     $'A', %dl
        mov     %dl, %sil
        sub     $26, %dl
        jl      gen_bitset_uppercase

        sub     $['a' - 26 - 'A'], %dl
        mov     %dl, %sil
        sub     $26, %dl
        jl      gen_bitset_lowercase

        // bad char
        mov     $gen_bitset_unrecognized, %rdi
        call    panic

gen_bitset_lowercase:
        call    set_bit
        jmp     gen_bitset_loop_continue

gen_bitset_uppercase:
        add     $26, %sil
        call    set_bit
        jmp     gen_bitset_loop_continue

gen_bitset_loop_continue:
        loop    gen_bitset_loop

        pop     %rcx
        end     FRAME
#undef FRAME

todo: .asciz "TODO\n"

// u64 -> ()
print_bitset:
#define FRAME   $0
        begin   FRAME
        push    %rcx

        mov     %rdi, %rax

        // lowercase loop
        mov     $26, %rcx
print_bitset_lower:
        mov     %rax, %rdi
        and     $1, %rdi
        cmp     $0, %rdi
        jz      print_bitset_lower_continue

        // letter is set
        push    %rax

        mov     $['a' + 26], %dil
        sub     %cl, %dil
        call    putchar

        pop     %rax

print_bitset_lower_continue:
        shr     $1, %rax
        loop    print_bitset_lower

        // uppercase loop
        mov     $26, %rcx
print_bitset_upper:
        mov     %rax, %rdi
        and     $1, %rdi
        cmp     $0, %rdi
        jz      print_bitset_upper_continue

        // letter is set
        push    %rax

        mov     $['A' + 26], %dil
        sub     %cl, %dil
        call    putchar

        pop     %rax

print_bitset_upper_continue:
        shr     $1, %rax
        loop    print_bitset_upper

        pop     %rcx
        end     FRAME
#undef FRAME

score_bitset_err: .asciz "error: can't score empty bitset"

// u64 -> u64
score_bitset:
        bsf     %rdi, %rdi
        jnz     score_bitset_success

        // empty bitset :(
        mov     $score_bitset_err, %rdi
        call    panic

score_bitset_success:
        add     $1, %rdi
        mov     %rdi, %rax
        ret

// [*]u8 -> usize
// counts until next newline in a string
line_length:
#define FRAME   $0
        begin   FRAME

        // count length of next line
        xor     %rax, %rax
line_length_loop:
        cmpb    $'\n', (%rdi)
        je      line_length_return
        add     $1, %rdi
        add     $1, %rax
        jmp     line_length_loop

line_length_return:
        end     FRAME
#undef FRAME

part1_msg0: .asciz "got "
part1_msg1: .asciz " from bitsets "
part1_msg3: .asciz "; score: "
part1_msg4: .asciz "part 1) final score: "

// str: [*]u8, len: usize -> ()
part1:
#define FRAME   $40
        begin   FRAME

        // %rbx stores running sum
        mov     $0, %rbx

part1_loop:
        // test for EOF
        cmpb    $0, (%rdi)
        je      part1_loop_exit

        // store current start of string
        mov     %rdi, (%rsp)

        // count length of next line
        call    line_length

        // I actually need length/2, store this
        shr     $1, %rax
        mov     %rax, +8(%rsp)

        // generate the bit sets and store
        mov     (%rsp), %rdi
        mov     %rax, %rsi
        call    gen_bitset
        mov     %rax, +16(%rsp)

        mov     (%rsp), %rdi
        mov     +8(%rsp), %rsi
        add     %rsi, %rdi
        call    gen_bitset
        mov     %rax, +24(%rsp)

        // final bitset
        mov     +16(%rsp), %rax
        and     +24(%rsp), %rax
        mov     %rax, +32(%rsp)

        // print bit sets
#if 0
        mov     $part1_msg0, %rdi
        call    print

        mov     +32(%rsp), %rdi
        call    print_bitset

        mov     $part1_msg1, %rdi
        call    print

        mov     +16(%rsp), %rdi
        call    print_bitset

        mov     $' ', %dil
        call    putchar

        mov     +24(%rsp), %rdi
        call    print_bitset

        mov     $part1_msg3, %rdi
        call    print

        mov     %rbx, %rdi
        call    print_decimal
        call    endl
#endif

        // store score
        mov     +32(%rsp), %rdi
        call    score_bitset
        add     %rax, %rbx

        // iterate
        mov     (%rsp), %rdi
        add     +8(%rsp), %rdi
        add     +8(%rsp), %rdi
        add     $1, %rdi
        jmp     part1_loop
part1_loop_exit:

        // print final score
        mov     $part1_msg4, %rdi
        call    print

        mov     %rbx, %rdi
        call    print_decimal
        call    endl

        end     FRAME
#undef FRAME

part2_msg0: .asciz "part 2) final score: "

XXX: .asciz "next inventory is:\n"

// str: [*]u8, len: usize -> ()
part2:
#define FRAME   $40
        begin   FRAME

        mov     %rdi, +24(%rsp)
        mov     %rsi, +32(%rsp)

        // %rbx stores running sum
        mov     $0, %rbx

part2_loop:
        mov     %rdi, (%rsp)

        // test for EOF
        cmpb    $0, (%rdi)
        je      part1_loop_exit

        // score thrice
        movq    $[(1 << 52) - 1], %rax
        mov     %rax, +16(%rsp)
        mov     $3, %rcx
part2_inv_loop:
        mov     %rdi, (%rsp)
        call    line_length
        mov     %rax, +8(%rsp)

        // generate bitset with str + len
        mov     (%rsp), %rdi
        mov     +8(%rsp), %rsi
        call    gen_bitset

        // and with prev sets
        and     +16(%rsp), %rax
        mov     %rax, +16(%rsp)

        // iterate
        mov     (%rsp), %rdi
        add     +8(%rsp), %rdi
        add     $1, %rdi
        mov     %rdi, (%rsp)
        loop    part2_inv_loop

        // score this inventory
        mov     +16(%rsp), %rdi
        call    score_bitset
        add     %rax, %rbx

        // iterate
        mov     (%rsp), %rdi
        jmp     part2_loop

part2_loop_exit:
        // display final status
        mov     $part2_msg0, %rdi
        call    print

        mov     %rbx, %rdi
        call    print_decimal
        call    endl

        end     FRAME
#undef FRAME

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

        // solutions
#if 1
        mov     +8(%rsp), %rdi
        mov     (%rsp), %rsi
        call    part1
#endif

#if 1
        mov     +8(%rsp), %rdi
        mov     (%rsp), %rsi
        call    part2
#endif

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
