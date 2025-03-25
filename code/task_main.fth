\ === task_main.fth ===
\
\ Definition of top level UI task
\

\ Allocate and clear a menu structure
menu_create task_main_menu
task_main_menu menu_clear

\ handler to launch the chron UI task
: task_main_chron
	task_chron task_start
;

\ Define the menu
: task_main_menu_create
    ['] task_main_chron S" >CHRON" 0 0 task_main_menu 0 0 menu_add_option
;

\ Build the menu
: task_main_menu_create

\ task_main init function
: task_main_init 			( -- )
;

\ task_main poll function
: task_main_poll			( -- )
;

\ Create the task definition: task_main
500 ' task_main_poll ' task_main_init task_create task_main

\ This is a one-shot function that will erase the "ok" and other
\ routine Forth startup messages before painting the main menu
: task_main_kickoff                         ( -- )
    TID_TASK_MAIN_INIT P-STOP        	    (  )
    \ erase the ok message
    2 1 1 erase_display_line		        (  )
    \ start the FMS UI
    task_main task_start
;

\ Start the TASK one time initialization timer
TID_TASK_MAIN_INIT 100 P-TIMER task_main_kickoff