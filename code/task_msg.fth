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

\ Initialize variables as needed
FALSE t_msg_active !
T_MSG_IDLE t_msg_state !
0 t_msg_count !

\ Set up storage for received messages
DECIMAL
100 CONSTANT T_MSG_QTY_MAX
2 CELLS CONSTANT T_OVR_SZ     \ size of overhead block, bytes
LEN_MSG_MAX T_OVR_SZ + CONSTANT T_MSG_LEN_BLK  \ msg length + overhead
1 CONSTANT T_OVR_NXT    \ overhead block, offset to next pointer
2 CONSTANT T_OVR_PRV    \ overhead block, offset to prev pointer
3 CONSTANT T_OVR_ALLOC  \ overhead block, offset to allocated flag (1 = allocated)
4 CONSTANT T_OVR_TSTAMP \ overhead block, offset to timestamp word

\ allocate a static message store and clear it
CREATE t_msg_store
T_MSG_LEN_BLK T_MSG_QTY_MAX * DUP ALLOT ( l )
ALIGN                                   ( l )
t_msg_store SWAP                        ( c-addr l )
ERASE

\ Queue definition blocks - must appear in this order
\ Free message queue block
VARIABLE t_msg_free         \ index of first free block or -1 for none
VARIABLE t_msg_last_free    \ index of last free block or -1 for none
VARIABLE t_msg_free_qty     \ qty of blocks in queue
\ Used message queue block
VARIABLE t_msg_used         \ index of first used block or -1 for none
VARIABLE t_msg_last_used    \ index of last used block or -1 for none
VARIABLE t_msg_used_qty     \ qty of blocks in queue

\ initialize the message store
: t_msg_init_store      ( -- )
    0 t_msg_free !          (  )
    T_MSG_QTY_MAX t_msg_free_qty !  (  )
    -1 t_msg_used !         (  )
    0 t_msg_used_qty !      (  )
    T_MSG_QTY_MAX 1-        ( l )
    t_msg_last_free !       (  )
    -1 t_msg_last_used !    (  )
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
            !                   ( frnt-n )`             \ store -1 in last n
        THEN                    ( frnt-n )
        R>                      ( frnt-n a )
        2 CELLS +               ( frnt-n qty-a )
        -1 SWAP                 ( frnt-n -1 qty-a )
        +!                      ( frnt-n )              \ decrement q qty
    ELSE                    ( frnt-n )
        DROP                (  )        \ queue was empty
        R> DROP             (  )        \ clear the return stack
        0 1-                ( -1 )      \ frnt-n is invalid (empty)
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
        ROLL                ( n n last-n )
        DUP                 ( n n last-n last-n )
        ROLL                ( n last-n last-n n )
        t_msg_q_ctrl        ( n last-n last-n n-a )
        T_OVR_PRV +         ( n last-n last-n n-prev ) 
        C!                  ( n last-n )                \ set prev ptr in n
        SWAP DUP            ( last-n n n )
        ROLL                ( n n last-n )
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
        -1 -1 ROLL          ( -1 -1 n )
        DUP                 ( -1 -1 n )
        t_msg_q_ctrl        ( -1 -1 n-a )
        DUP                 ( -1 -1 n-a n-a )
        ROLL SWAP           ( -1 n-a -1 n-a )
        T_OVR_NXT + C!      ( -1 n-a )
        T_OVR_PRV + C!      (  )                \ element's prv and nxt = -1
    THEN                    (  )
    R>                      ( a )
    2 CELLS +               ( qty-a )
    1 SWAP                  ( 1 qty-a )
    +!                      (  )                \ increment q qty

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
            T_MSG_DATA t_msg_state ! (  )
        ELSE                (  )   \ length packet invalid
            DROP            (  )   \ remain in T_MSG_IDLE
        THEN
    ELSE                    ( n )   \ T_MSG_DATA 
    \ TODO allocate a used block to write into
    THEN
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
    1 2   AT-XY horizontal_double_rule
    1 10  AT-XY horizontal_double_rule
    1 12  AT-XY horizontal_rule
    10 13 AT-XY ." UP/DN TO SCROLL"
    fms_refresh_buffer_display  (  )
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