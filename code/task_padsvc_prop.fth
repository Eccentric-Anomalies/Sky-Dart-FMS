\ === task_padsvc_prop.fth ===
\
\ Definition of pad services propellent UI task
\

\        PROPELLENT
\  
\  CURR/MAX       ON PAD
\  ------------------------
\  0000/0000 KG   00000 KG
\  ------------------------
\  SET 0000 KG TRANSFER QTY
\  
\  SET 0000 KG TRANSFER TGT
\  ------------------------
\  STOP                LOAD
\  
\  <STOP/RETURN      UNLOAD
\     ~ scratch ~


\ Display the pad service fixed text
\
DECIMAL
: t_padsvc_prop_display_fixed ( -- )
    7 1 AT-XY   ." PROPELLENT"
    1 3 AT-XY   ." CURR/MAX       ON PAD"
    1 4 AT-XY   horizontal_rule
    1 6 AT-XY   horizontal_rule
    13 7 AT-XY  ." TRANSFER QTY"
    13 9 AT-XY  ." TRANSFER TGT"
    1 10 AT-XY   horizontal_rule
;


\ (1) Allocate and clear a menu structure: t_padsvc_prop_menu
menu_create t_padsvc_prop_menu
t_padsvc_prop_menu menu_clear


\ (2) handlers for function keys

: t_padsvc_prop_return      ( -- )
    task_main_addr @        ( parent-orig-task )
    t_padsvc_prop_addr @    ( parent-orig-task this-task )
    task_get_orig           ( parent-orig-task orig-task )
    task_start              (  )
;

: t_padsvc_prop_stop        ( -- )
;

: t_padsvc_prop_load        ( -- )
;

: t_padsvc_prop_unload      ( -- )
;

\ (3) Define the menu
: t_padsvc_prop_menu_create
    ['] t_padsvc_prop_stop S" STOP" 0 0 t_padsvc_prop_menu 0 4 menu_add_option
    ['] t_padsvc_prop_load S" LOAD" 0 0 t_padsvc_prop_menu 1 4 menu_add_option
    ['] t_padsvc_prop_return S" <STOP/RETURN" 0 0 t_padsvc_prop_menu 0 5 menu_add_option
    ['] t_padsvc_prop_unload S" UNLOAD" 0 0 t_padsvc_prop_menu 1 5 menu_add_option
;

\ (4) Build the menu
t_padsvc_prop_menu_create

\ (5) init function
: t_padsvc_prop_init        ( -- )
    PAGE
    t_padsvc_prop_display_fixed
    t_padsvc_prop_menu menu_show
    fms_refresh_buffer_display
;

\ (6) poll function 
: t_padsvc_prop_poll        ( -- )
;

\ (7) Create the task definition: task_padsvc_prop
    ' t_padsvc_prop_poll ' t_padsvc_prop_init task_create task_padsvc_prop
    task_padsvc_prop t_padsvc_prop_addr !
;