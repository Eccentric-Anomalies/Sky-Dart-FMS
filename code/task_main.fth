\ === task_main.fth ===
\
\ Definition of top level UI task
\
\  |           |          |
\         SKY-DART FMS
\            v1.0.0
\  >MESSAGES          >DIAG
\
\  >CHRON 
\
\  >PADSVC
\
\
\
\ 
\
\
\


\ (1) Allocate and clear a menu structure: task_main_menu;
menu_create task_main_menu
task_main_menu menu_clear

\ (2) handlers for function keys
\ handler to launch the chron UI task
: task_main_chron
    task_main_addr @ task_chron task_start
;

: task_main_padsvc
    task_main_addr @ task_padsvc task_start
;

: task_main_diag
    task_main_addr @ task_diag task_start    
;

: task_main_messages
    task_main_addr @ task_msg task_start
;

\ (3) Define the menu
: task_main_menu_create
    ['] task_main_messages S" >MESSAGES" 0 0 task_main_menu 0 0 menu_add_option
    ['] task_main_chron S" >CHRON" 0 0 task_main_menu 0 1 menu_add_option
    ['] task_main_padsvc S" >PADSVC" 0 0 task_main_menu 0 2 menu_add_option
    ['] task_main_diag S" >DIAG" 0 0 task_main_menu 1 0 menu_add_option
;

\ (4) Build the menu
task_main_menu_create

\ (6) task_main poll function
: task_main_poll            ( -- )
;

\ (5) task_main init function
: task_main_init                ( -- )
    PAGE
    task_main_menu menu_show    (  )
    version_title               (  )
    version_number              (  )
    fms_refresh_buffer_display  (  )
;

\ (7) Create the task definition: task_main
' task_main_poll ' task_main_init task_create task_main
task_main task_main_addr !


\ This is a one-shot function that will erase the "ok" and other
\ routine Forth startup messages before painting the main menu
: task_main_kickoff                         ( -- )
    TID_TASK_MAIN_INIT P-STOP               (  )
    \ erase the ok message
    2 1 1 erase_display_line                (  )
    \ start the FMS UI
    0 task_main task_start
;

\ Start the TASK one time initialization timer
TID_TASK_MAIN_INIT 100 P-TIMER task_main_kickoff