\ === task_chron.fth ===
\
\ Definition of chronometer/stopwatch UI task
\

\ (0) Variable to hold addr of this task
VARIABLE task_chron_addr

\ (1) Allocate and clear a menu structure
menu_create task_chron_menu
task_chron_menu menu_clear

\ (2) handlers for function keys
\ handler to launch a function key action
: task_chron_reset
    \ do something to reset the stopwatch
;

\ handler to return to calling menu
: task_chron_return
    task_chron_addr @            ( this-task )
    DUP                          ( this-task this-task )
    task_get_orig                ( this-task orig-task )
    task_start                   (  )
;


\ (3) Define the menu
: task_chron_menu_create
    ['] task_chron_return S" <RETURN" 0 0 task_chron_menu 0 5 menu_add_option
    ['] task_chron_reset S" RESET" 0 0 task_chron_menu 1 0 menu_add_option
;

\ (4) Build the menu
task_chron_menu_create

\ (5) task_main init function
: task_chron_init               ( -- )
    PAGE
    task_chron_menu menu_show   (  )
;

\ (6) task_chron poll function
: task_chron_poll             ( -- )
;

\ (7) Create the task definition: task_chron
' task_chron_poll ' task_chron_init task_create task_chron
task_chron task_chron_addr !
