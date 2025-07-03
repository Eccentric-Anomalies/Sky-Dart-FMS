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

\ Initialize variables as needed
FALSE t_msg_active !

\ Set up storage for received messages

\ handler for input characters
\
DECIMAL
: t_msg_rcv               ( n -- )
    EMIT
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
PORT_MESSAGE 0 LISTEN t_msg_rcv

DECIMAL