\ === task_.fth ===
\
\ Definition of top level UI task
\
\  |           |           |            
\     LANDING GEAR STATUS
\
\       OK         OK
\     XX.X KN   XX.X KN   
\          \     /
\           *---*   
\           |   |
\           *---*
\          /     \
\     XX.X KN   XX.X KN   
\     DAMAGED   DAMAGED
\
\
\  <RETURN

\ (0) Variable to hold addr of this task
VARIABLE t_gear_addr

\ (1) Allocate and clear a menu structure: t_gear_menu;
menu_create t_gear_menu
t_gear_menu menu_clear

\ (2) handlers for function keys

: t_gear_return        ( -- )
    task_main_addr @    ( parent-orig-task )
    t_gear_addr @       ( parent-orig-task this-task )
    task_get_orig       ( parent-orig-task orig-task )
    task_start          (  )
;


\ (3) Define the menu
: t_gear_menu_create
    ['] t_gear_return S" <RETURN" 0 0 t_gear_menu 0 5 menu_add_option
;

\ (4) Build the menu
t_gear_menu_create

\ (6) t_gear poll function
: t_gear_poll            ( -- )
;

\ (5) t_gear init function
: t_gear_init                 ( -- )
    PAGE
    t_gear_menu menu_show    (  )
    4 1 AT-XY ." LANDING GEAR STATUS"
    fms_refresh_buffer_display  (  )
;

\ (7) Create the task definition: task_gear
' t_gear_poll ' t_gear_init task_create task_gear
task_gear t_gear_addr !
