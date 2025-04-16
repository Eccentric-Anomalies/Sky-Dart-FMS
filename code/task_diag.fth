\ === task_diag.fth ===
\
\ Definition of top level UI task
\
\  |           |           |            
\    SKY-DART DIAGNOSTICS
\           
\  >L-GEAR
\
\
\
\
\
\
\
\ 
\
\
\  <RETURN


\ (1) Allocate and clear a menu structure: t_diag_menu;
menu_create t_diag_menu
t_diag_menu menu_clear

\ (2) handlers for function keys
\ handler to launch the gear UI task
: t_diag_gear
    t_diag_addr @ task_gear task_start
;

: t_diag_return        ( -- )
    0                   ( null-orig-task)  \ returning to the top level
    t_diag_addr @       ( null-orig-task this-task )
    task_get_orig       ( null-orig-task orig-task )
    task_start          (  )
;


\ (3) Define the menu
: t_diag_menu_create
    ['] t_diag_gear S" >L-GEAR" 0 0 t_diag_menu 0 0 menu_add_option
    ['] t_diag_return S" <RETURN" 0 0 t_diag_menu 0 5 menu_add_option
;

\ (4) Build the menu
t_diag_menu_create

\ (6) t_diag poll function
: t_diag_poll            ( -- )
;

\ (5) t_diag init function
: t_diag_init                 ( -- )
    PAGE
    t_diag_menu menu_show    (  )
    3 1 AT-XY ." SKY-DART DIAGNOSTICS"
    fms_refresh_buffer_display  (  )
;

\ (7) Create the task definition: task_diag
' t_diag_poll ' t_diag_init task_create task_diag
task_diag t_diag_addr !
