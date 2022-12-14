USING: accessors arrays assocs biassocs classes.tuple
combinators command-line formatting grouping io
io.encodings.utf8 io.files kernel math math.order math.parser
math.primes.factors namespaces prettyprint regexp sequences
sequences.n-based sorting strings system vectors ;
IN: solution

: ops ( -- assoc ) { "add" "mul" "sq" } 1 <n-based-assoc> >biassoc ;

TUPLE: operation
    { op integer read-only } ! index into ops
    { n  integer read-only } ;

TUPLE: monkey
    { n       integer   read-only }
    { items   vector    } ! `(factors: int vector) vector`
    { op      operation read-only }
    { divisor integer   read-only }
    { if-t    integer   read-only }
    { if-f    integer   read-only }
    { seen    integer   } ;

: clone-items ( items -- cloned ) [ clone ] map >vector ;

: clone-monkey ( monkey -- cloned )
    tuple>array dup dup third clone-items 2 rot set-nth >tuple ;

! solution =====================================================================

: do-op ( worry op -- worry )
    dup [ n>> factors ] dip
    op>> {
        { [ dup "add" ops value-at = ] [
            drop product [ product ] dip + factors
        ] }
        { [ dup "mul" ops value-at = ] [ drop append ] }
        { [ dup "sq"  ops value-at = ] [ 2drop dup append ] }
        [ assert ]
    } cond >vector ;

! takes a list of factors and divides it by a number
: div-item ( item divisor -- new-item )
    dup 1 = [ drop clone ] [
        factors [
            over ! ( ... items factor items )

            ! remove the first factor, or do it the hard way
            2dup [ over = ] find drop nip ! ( ... items factor items n/f )

            dup [
                ! remove the factor from the factors
                swap remove-nth! 2drop
            ] [
                ! hard way :(
                drop product swap /i factors nip
            ] if
        ] each
    ] if ;

! takes two factor lists and checks if dividend divides into divisor with no
! remainder
: divides-into? ( dividend divisor -- ? )
    !  2dup

    swap clone >vector swap ! ( ... cloned-dividend divisor )
    [
        2dup swap ! ( ... dividend factor factor dividend )
        [ over = ] find drop nip nip ! ( ... dividend factor n/f )
        dup [ swap remove-nth! t ] when
    ] map
    t [ and ] reduce
    nip ;

: throw-item-to ( elt idx monkeys -- )
    !  2over [ product ] dip "throwing %d to monkey %d\n" printf

    nth items>> push ;

: run-round ( monkeys worry-divisor -- monkeys )
    swap dup [
        ! duplicate old items list, create new list
        dup items>> over V{ } clone >>items drop

        !  over n>> "[[[MONKEY %d]]]\n" printf

        ! iterate over old list
        [
            !  "[new item]" print
            !  dup product "monkey inspecting item %d\n" printf

            ! do op
            over op>> do-op ! ( ... worry-divisor monkeys monkey item )

            !  dup product "item now %d\n" printf

            ! modify by worry
            roll dup [ -roll dup ] dip div-item nip

            !  dup product "worry decreased to %d\n" printf

            ! increment items seen
            over dup seen>> 1 + >>seen drop

            ! check divisor condition
            2dup swap divisor>> factors ! ( ... monkeys monkey n n divisor )
            divides-into? [ over if-t>> ] [ over if-f>> ] if

            ! throw item to next monkey
            roll dup [ -roll ] dip throw-item-to

            !  "" print
        ] each

        !  "" print

        drop
    ] each
    nip ;

: display-round ( monkeys n -- monkeys )
    "[round %d]\n" printf
    dup [
        dup n>> over seen>> "monkey %d (%4d seen): " printf
        items>> [
            zero? not [ ", " printf ] when
            product "%d" printf
        ] each-index
        "" print
    ] each ;

: display-round-kurz ( monkeys n -- monkeys )
    "[round %d]\n" printf
    dup [
        dup n>> over seen>> "monkey %d has seen %d\n" printf drop
    ] each ;

: calc-monkey-business ( monkeys -- monkeys score )
    ! get top 2 scores and multiply then
    dup [ seen>> ] map [ >=< ] sort
    first2 * ;

: part1 ( monkeys -- )
    20 [
        swap 3 run-round
        swap 1 + display-round flush
    ] each-integer
    calc-monkey-business "part 1) monkey business: %d\n" printf
    drop ;

: part2 ( monkeys -- )
    100 [
        swap 1 run-round
        swap dup 10 mod zero? [ 1 + display-round-kurz flush ] [ drop ] if
    ] each-integer
    calc-monkey-business "part 2) monkey business: %d\n" printf
    drop ;

! main =========================================================================

: read-ints ( str -- ints )
    R/ (\d+)/ all-matching-subseqs
    [ string>number ] map ;

: read-n-ints ( str n -- ints )
    swap read-ints
    dup length rot assert= ;

: read-1-int ( str -- int ) 1 read-n-ints first ;

: parse-op ( str -- operation )
    R/ (\S+)/ all-matching-subseqs 2 tail-slice* first2
    dup "old" = [
        2drop "sq" ops value-at 0
    ] [
        string>number swap
        {
            { [ dup "*" = ] [ drop "mul" ] }
            { [ dup "+" = ] [ drop "add" ] }
            [ assert ]
        } cond
        ops value-at swap
    ] if
    operation boa ;

: read-items ( str -- items ) read-ints [ factors >vector ] map >vector ;

! parses 6 lines into a monkey
: parse-monkey ( lines -- monkey )
    unclip read-1-int swap ! n
    unclip read-items swap ! items
    unclip parse-op   swap ! operation
    unclip read-1-int swap ! divisible test
    unclip read-1-int swap ! if true
    unclip read-1-int nip  ! if false
    0
    monkey boa ;

! reads file lines into monkeys
: read-monkeys ( filename -- monkeys )
    utf8 file-lines
    [ length 0 > ] filter
    6 group [ parse-monkey ] map ;

: solve ( filename -- )
    read-monkeys dup [ clone-monkey ] map
    part1 part2 ;

! cli ==========================================================================

command-line get dup length 1 = [
    first solve
] [
    "usage: factor soln.factor " print
    1 exit
] if
