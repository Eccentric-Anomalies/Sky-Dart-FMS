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

VARIABLE t_msg_free     \ index of first free block or -1 for none
VARIABLE t_msg_used     \ index of first used block or -1 for none
VARIABLE t_msg_last_free \ index of last free block or -1 for none
VARIABLE t_msg_last_used \ index of last used block or -1 for none

\ initialize the message store
: t_msg_init_store      ( -- )
    0 t_msg_free !          (  )
    -1 t_msg_used !         (  )
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
            t_msg_count !   (  )
            T_MSG_DATA t_msg_state ! (  )
        ELSE                (  )   \ length packet invalid
            DROP            (  )    \ remain in MASK_MSG_LEN
        THEN
    ELSE                    ( n )   \ T_MSG_DATA 
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