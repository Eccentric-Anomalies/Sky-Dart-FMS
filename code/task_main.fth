\ === task_main.fth ===
\
\ Definition of top level UI task
\

\ (0) Variable to hold addr of this task
VARIABLE task_main_addr

\ (1) Allocate and clear a menu structure: task_main_menu;
menu_create task_main_menu
task_main_menu menu_clear

\ (2) handlers for function keys
\ handler to launch the chron UI task
: task_main_chron
    task_main_addr @ task_chron task_start
;

\ (3) Define the menu
: task_main_menu_create
    ['] task_main_chron S" >CHRON" 0 0 task_main_menu 0 0 menu_add_option
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