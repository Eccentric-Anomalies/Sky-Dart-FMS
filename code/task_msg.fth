\ === task_msg.fth ===
\
\ Definition of message receiver task
\

\  RECEIVE TIME: 0000:00:00
\  ========================
\  PAD 0:0 AUTOMSG
\  SAFE LANDING 
\
\
\
\
\
\  ========================
\  PREV     *END*      NEXT
\  ------------------------
\  <RETURN  UP/DN TO SCROLL
\


\ task state
VARIABLE t_msg_active

\ message reception state machine states
0 CONSTANT T_MSG_IDLE
1 CONSTANT T_MSG_DATA
VARIABLE t_msg_state
VARIABLE t_msg_count
VARIABLE t_msg_buffer_block     \ index of block being written
VARIABLE t_msg_curr_block       \ index of block being viewed

\ Initialize variables as needed
FALSE t_msg_active !
T_MSG_IDLE t_msg_state !
0 t_msg_count !
-1 t_msg_buffer_block !
-1 t_msg_curr_block !

\ Set up storage for received messages
DECIMAL
100 CONSTANT T_MSG_QTY_MAX
2 CELLS CONSTANT T_OVR_SZ     \ size of overhead block, bytes
LEN_MSG_MAX T_OVR_SZ + CONSTANT T_MSG_LEN_BLK  \ msg length + overhead
0 CONSTANT T_OVR_LEN    \ overhead block, first byte is msg length
1 CONSTANT T_OVR_NXT    \ overhead block, offset to next pointer
2 CONSTANT T_OVR_PRV    \ overhead block, offset to prev pointer
3 CONSTANT T_OVR_ALLOC  \ overhead block, offset to allocated flag (1 = allocated)
4 CONSTANT T_OVR_TSTAMP \ overhead block, offset to timestamp word

\ allocate a static message store and clear it
CREATE t_msg_store
T_MSG_LEN_BLK T_MSG_QTY_MAX * DUP ALLOT ( l )
ALIGN                                   ( l )
t_msg_store SWAP 0                      ( c-addr l )
FILL

\ Queue definition blocks
\ Free message queue block
CREATE t_msg_free 3 CELLS ALLOT                     \ index of first free block or -1 for none
t_msg_free 1 CELLS + CONSTANT T_MSG_LAST_FREE       \ index of last free block or -1 for none
T_MSG_LAST_FREE 1 CELLS + CONSTANT T_MSG_FREE_QTY   \ qty of blocks in queue
\ Used message queue block
CREATE t_msg_used 3 CELLS ALLOT                     \ index of first free block or -1 for none
t_msg_used 1 CELLS + CONSTANT T_MSG_LAST_USED       \ index of last free block or -1 for none
T_MSG_LAST_USED 1 CELLS + CONSTANT T_MSG_USED_QTY   \ qty of blocks in queue

\ initialize the message store
: t_msg_init_store      ( -- )
    0 t_msg_free !          (  )
    T_MSG_QTY_MAX T_MSG_FREE_QTY !  (  )
    -1 t_msg_used !         (  )
    0 T_MSG_USED_QTY !      (  )
    T_MSG_QTY_MAX 1-        ( l )
    T_MSG_LAST_FREE !       (  )
    -1 T_MSG_LAST_USED !    (  )
    T_MSG_QTY_MAX 0 DO      (  )
        I T_MSG_LEN_BLK *   ( offs )
        t_msg_store +       ( a )
        DUP                 ( a a )
        T_OVR_PRV +         ( a prv-ptr )
        I 1- SWAP C!        ( a )
        T_OVR_NXT +         ( nxt-ptr )
        I 1+                ( nxt-ptr n )
        T_MSG_QTY_MAX <> IF ( nxt-ptr )
            I 1+ SWAP C!    (  )
        ELSE                ( nxt-ptr )
            -1 SWAP C!      (  )
        THEN
    LOOP
;

\ Queue utilities

\ get queue control block from index
: t_msg_q_ctrl              ( n -- a )
    T_MSG_LEN_BLK *         ( offs )
    t_msg_store +           ( a )
;

\ get queue buffer address from index
: t_msg_q_buffer            ( n -- a )
    t_msg_q_ctrl            ( a )
    T_OVR_SZ +              ( a )
;

\ get queue buffer len address from index
: t_msg_q_len               ( n -- a )
    t_msg_q_ctrl            ( a )
    T_OVR_LEN +             ( a )
;

\ get queue buffer timestamp address from index
: t_msg_q_tstamp            ( n -- a )
    t_msg_q_ctrl            ( a )
    T_OVR_TSTAMP +          ( a )
;

\ is queue empty - argument is t_msg_xxx address
: t_msg_q_empty             ( a -- f )
    2 CELLS + @             ( qty )
    0= 
;

\ pop from front of queue
\ argument is address of queue control block
\ returns index of msg, -1 if none
\
DECIMAL
: t_msg_q_pop               ( a -- frnt-n )
    DUP                     ( a a )
    >R                      ( a )           \ save the queue address
    @                       ( frnt-n )
    DUP                     ( frnt-n frnt-n )
    0< NOT IF               ( frnt-n )      \ queue has elements
        DUP                     ( frnt-n frnt-n )   \ save returned n
        t_msg_q_ctrl            ( frnt-n frnt-a )
        T_OVR_NXT + C@          ( frnt-n nxt-n )
        R@                      ( frnt-n nxt-n a )      \ store new first ref
        !                       ( frnt-n  )
        -1                      ( frnt-n -1 )
        R@                      ( frnt-n -1 a )         \ queue address
        @                       ( frnt-n -1 frnt-n )
        DUP                     ( frnt-n -1 frnt-n frnt-n )
        0< NOT IF               ( frnt-n -1 frnt-n )
            t_msg_q_ctrl        ( frnt-n -1 frnt-a )
            T_OVR_PRV +         ( frnt-n -1 prv-a )
            !                   ( frnt-n  )             \ first element prev = -1
        ELSE                    ( frnt-n -1 frnt-n )    \ queue is empty
            2DROP               ( frnt-n  )
            R@                  ( frnt-n a )            \ queue address
            1 CELLS +           ( frnt-n a )            \ address or last n
            -1 SWAP             ( frnt-n -1 a )
            !                   ( frnt-n )              \ store -1 in last n
        THEN                    ( frnt-n )
        R>                      ( frnt-n a )
        2 CELLS +               ( frnt-n qty-a )
        -1 SWAP                 ( frnt-n -1 qty-a )
        +!                      ( frnt-n )              \ decrement q qty
    ELSE                    ( frnt-n )
        DROP                (  )        \ queue was empty
        R> DROP             (  )        \ clear the return stack
        -1                  ( -1 )      \ frnt-n is invalid (empty)
    THEN                    ( frnt-n )
;

\ push to back of queue
\ arguments are index of message block, 
\ address of queue control block
\
DECIMAL
: t_msg_q_push              ( n a -- )
    DUP                     ( n a a )
    >R                      ( n a )             \ save the queue address
    1 CELLS +               ( n last-a )
    @                       ( n last-n )
    DUP                     ( n last-n last-n )
    0< NOT IF               ( n last-n )               \ queue has elements
        SWAP                ( last-n n )
        DUP                 ( last-n n n )
        ROT                 ( n n last-n )
        DUP                 ( n n last-n last-n )
        ROT                 ( n last-n last-n n )
        t_msg_q_ctrl        ( n last-n last-n n-a )
        T_OVR_PRV +         ( n last-n last-n n-prev ) 
        C!                  ( n last-n )                \ set prev ptr in n
        SWAP DUP            ( last-n n n )
        ROT                 ( n n last-n )
        t_msg_q_ctrl        ( n n last-n-a )
        T_OVR_NXT +         ( n n last-n-next )
        C!                  ( n )                       \ set next ptr in prev
        DUP                 ( n n )
        R@                  ( n n a )
        1 CELLS +           ( n n a-end )
        !                   ( n )                       \ set end of queue ptr
        DROP                (  )
    ELSE                    ( n last-n )                \ queue is empty
        DROP                ( n )
        DUP                 ( n n )
        R@                  ( n n a )
        !                   ( n )               \ first element is n
        DUP                 ( n n )
        R@ 1 CELLS +        ( n n a-end )       \ ref. to last element
        !                   ( n )               \ last is n
        -1 -1 ROT           ( -1 -1 n )
        t_msg_q_ctrl        ( -1 -1 n-a )
        DUP                 ( -1 -1 n-a n-a )
        ROT  SWAP           ( -1 n-a -1 n-a )
        T_OVR_NXT + C!      ( -1 n-a )
        T_OVR_PRV + C!      (  )                \ element's prv and nxt = -1
    THEN                    (  )
    R>                      ( a )
    2 CELLS +               ( qty-a )
    1 SWAP                  ( 1 qty-a )
    +!                      (  )                \ increment q qty
;


\ allocate a new message
\ returns the index of the returned message (0 .. T_MSG_QTY_MAX-1)
\
DECIMAL
: t_msg_alloc               ( -- n )
    t_msg_free t_msg_q_empty    ( f )
    IF                                  \ no free blocks
        t_msg_used              ( q-a ) \ reuse oldest message
    ELSE
        t_msg_free              ( q-a ) \ use the next free block    
    THEN
    t_msg_q_pop                 ( n )
    DUP                         ( n n )
    t_msg_curr_block @          ( n n curr-n )
    = IF                        ( n )   \ just allocated the current block
        -1 t_msg_curr_block !   ( n )   \ invalidate the current block
    THEN                        ( n )
;

\ handler for input message data
\
DECIMAL
: t_msg_rcv                 ( n -- )
    t_msg_state @           ( n s )
    T_MSG_IDLE = IF         ( n )
        DUP                 ( n n )
        MASK_MSG_LEN INVERT ( n n m )
        AND 0=              ( n f )
        SWAP                ( f n )
        OFS_MSG_LEN 8 *     ( f n s )
        RSHIFT              ( f l )
        DUP                 ( f l l )
        LEN_MSG_MAX         ( f l l max )
        > NOT               ( f l f )
        ROT                 ( l f f )
        AND                 ( l f )
        IF                  ( l )   \ valid 
            t_msg_count !   (  )    \ set the running count
            T_MSG_DATA t_msg_state ! (  )   \ set state to DATA
            t_msg_alloc     ( n )   \ get a free message block
            DUP t_msg_q_len ( n a-len )
            0 SWAP C!       ( n )   \ set msg length to zero
            DUP             ( n n )
            t_msg_buffer_block !    ( n )    \ save the buffer block index
            t_msg_q_tstamp  ( a-tstamp )    \ get timestamp address
            clock_msec_count 2@     ( a-tstmp 2msec )
            1000 M/         ( a_tstmp sec ) \ save the message timestamp
            SWAP !          (  )
        ELSE                (  )   \ length packet invalid
            DROP            (  )   \ remain in T_MSG_IDLE
        THEN                (  )
    ELSE                    ( n )   \ T_MSG_DATA 
        t_msg_buffer_block @    ( n n-b )
        DUP                 ( n n-b n-b )
        t_msg_q_buffer      ( n n-b n-txt )
        t_msg_count @ DUP   ( n n-b n-txt n-rem n-rem )
        4 > IF              ( n n-b n-txt n-rem )
            DROP 4          ( n n-b n-txt 4 )
        THEN                ( n n-b n-txt n-chars )
        DUP                 ( n n-b n-txt n-chars n-chars )
        t_msg_count @ SWAP  ( n n-b n-txt n-chars n-rem n-chars )
        - t_msg_count !     ( n n-b n-txt n-chars )     \ update t_msg_count
        0 ?DO               ( n n-b n-txt )
            SWAP            ( n n-txt n-b )
            DUP             ( n n-txt n-b n-b )
            t_msg_q_len     ( n n-txt n-b a-len )
            C@              ( n n-txt n-b len )
            2 PICK +        ( n n-txt n-b addr )
            3 PICK SWAP     ( n n-txt n-b n addr )
            C!              ( n n-txt n-b )
            ROT             ( n-txt n-b n )
            8 RSHIFT        ( n-txt n-b n )             \ shift in the next char
            SWAP DUP        ( n-txt n n-b n-b )
            t_msg_q_len     ( n-txt n n-b a-len )
            DUP             ( n-txt n n-b a-len a-len )
            C@ 1+ SWAP C!   ( n-txt n n-b )             \ increment length
            ROT             ( n n-b n-txt )
        LOOP                ( n n-b n-txt )
        ROT 2DROP           ( n-b )
        t_msg_count @       ( n-b rem )
        0= IF               ( n-b )    \ message complete
            T_MSG_IDLE t_msg_state !    ( n-b )    \ state is IDLE
            t_msg_used      ( n-b q-a )
            t_msg_q_push    (  )        \ add it to the used queue
        ELSE                ( n-b )
            DROP            (  )
        THEN                (  )
    THEN                    (  )
;


\ (1) Allocate and clear a menu structure: t_msg_menu
menu_create t_msg_menu
t_msg_menu menu_clear

\ (2) handlers for function keys

: t_msg_return        ( -- )
    FALSE t_msg_active !
    task_main_addr @    ( parent-orig-task )
    t_msg_addr @        ( parent-orig-task this-task )
    task_get_orig       ( parent-orig-task orig-task )
    task_start          (  )
;

: t_msg_prev            ( -- )
;

: t_msg_next            ( -- )
;

\ (3) Define the menu
: t_msg_menu_create
    ['] t_msg_return S" <RETURN" 0 0 t_msg_menu 0 5 menu_add_option
    ['] t_msg_prev S" -PREV" 0 0 t_msg_menu 0 4 menu_add_option
    ['] t_msg_next S" NEXT-" 0 0 t_msg_menu 1 4 menu_add_option
;

\ (4) Build the menu
t_msg_menu_create

\ (5) t_msg init function
DECIMAL
: t_msg_init                 ( -- )
    t_msg_init_store            (  )
    PAGE
    TRUE t_msg_active !         (  )
    t_msg_menu menu_show        (  )
    1 1   AT-XY ." RECEIVE TIME:"
    1 2   AT-XY horizontal_double_rule
    1 10  AT-XY horizontal_double_rule
    1 12  AT-XY horizontal_rule
    10 13 AT-XY ." UP/DN TO SCROLL"
    fms_refresh_buffer_display  (  )
    \ FIXME TESTING
    1 3 AT-XY
    768     \ 00000300
    t_msg_rcv
    4407873 \ 00434241
    t_msg_rcv
    t_msg_used t_msg_q_empty NOT IF
        t_msg_used t_msg_q_pop  ( n )
        DUP                     ( n n )
        DUP t_msg_q_buffer      ( n n c-addr )
        SWAP t_msg_q_len C@     ( n c-addr l )
        TYPE                    ( n )
        15 1 AT-XY              ( n )
        t_msg_q_tstamp @        ( tstamp )
        clock_stst              (  )    \ emit a timestamp
    THEN
    \ FIXME END TESTING
;

\ (6) t_msg poll function
: t_msg_poll                  ( -- )
;

\ (7) Create the task definition: task_msg (no polling)
' t_msg_poll ' t_msg_init task_create task_msg
task_msg t_msg_addr !


\ Listen for characters (DO queue duplicate messages)
PORT_MSG 0 LISTEN t_msg_rcv

DECIMAL