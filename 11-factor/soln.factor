USING:
    kernel prettyprint arrays strings grouping regexp
    io io.encodings.utf8 io.files
    math math.parser
    sequences sequences.windowed ;

IN: solution

TUPLE: monkey
    { n integer read-only }
    { items array }
    operation ! TODO figure out how to type/parse this
    { test-divis integer read-only }
    { if-t integer read-only }
    { if-f integer read-only } ;

! solution =====================================================================

! main =========================================================================

: read-ints ( str -- ints )
    R/ (\d+)/ all-matching-subseqs
    [
        string>number
        ! [ dup not ] [ "failed to parse string" throw ] if
    ] map ;
: read-n-ints ( str n -- ints )
    swap read-ints
    dup length rot assert= ;
: read-1-int ( str -- int ) 1 read-n-ints first ;

! parses 6 lines into a monkey
: parse-monkey ( lines -- monkey )
    unclip read-1-int swap ! n
    unclip read-ints  swap ! items
    unclip            swap ! operation
    unclip read-1-int swap ! divisible test
    unclip read-1-int swap ! if true
    unclip read-1-int nip  ! if false
    monkey boa ;

! reads file lines into monkeys
: read-monkeys ( filename -- monkeys )
    utf8 file-lines
    [ length 0 > ] filter
    6 group [ parse-monkey ] map ;

: solve ( -- ) "~/dev/aoc2022/11-factor/test.txt" read-monkeys . ;

: MAIN ( -- ) solve ;
