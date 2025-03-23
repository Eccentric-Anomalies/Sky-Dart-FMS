\ === TASK.FTH ===

\ Definitions and tools for defining tasks on the FMS

\ Code for testing menu display

menu_create my_test_menu
my_test_menu menu_clear

: test_xt
    6 6 AT-XY
    S" HI!" TYPE
;

: test_menu_create
    ['] test_xt S" TEXT" S" item label" my_test_menu 0 2 menu_add_option
    ['] test_xt S" TEXT2" S" item label 2" my_test_menu 0 3 menu_add_option
;

\ Build the menu
test_menu_create


: task_init                         ( -- )
    TID_TASK_INIT P-STOP            (  )
    \ erase the ok message
    2 1 1 erase_display_line        (  )
    \ start managing the FMS
    my_test_menu  menu_show         (  )
    park_cursor
;


\ Start the TASK one time initialization timer
TID_TASK_INIT 100 P-TIMER task_init
