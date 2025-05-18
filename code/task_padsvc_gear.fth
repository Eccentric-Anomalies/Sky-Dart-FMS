\ === task_padsvc_gear.fth ===
\
\ Definition of pad services gear repair UI task
\

\    LANDING GEAR REPAIR
\  
\   CURRENT HEALTH STATUS
\  ------------------------
\  [######################]
\  [######################]
\  [######################]
\  [######################]
\   FAIL              GOOD
\  ------------------------
\  -START REPAIR
\  
\  <STOP/RETURN
\     ~ scratch ~

\ Repair task is active
VARIABLE t_padsvc_gear_active

\ Initialize
FALSE t_padsvc_gear_active !

\ Stop repairing
: t_padsvc_gear_stop        ( -- )
    0 PORT_REPAIR_XFER_STATE OUT  (  )
;

\ Display a blank health bar
: t_padsvc_gear_blank           ( row -- )
    DUP 1 SWAP AT-XY ." ["      ( row )
    24 SWAP AT-XY ." ]"         (  )
;

\ Display the repair service fixed text
\
DECIMAL
: t_padsvc_gear_display_fixed ( -- )
    3 1 AT-XY   ." LANDING GEAR REPAIR"
    2 3 AT-XY   ." CURRENT HEALTH STATUS"
    1 4 AT-XY   horizontal_rule
    5 t_padsvc_gear_blank
    6 t_padsvc_gear_blank
    7 t_padsvc_gear_blank
    8 t_padsvc_gear_blank
    2 9 AT-XY   ." FAIL              GOOD"
    1 10 AT-XY   horizontal_rule
;


\ Display the health bars
: t_padsvc_gear_disp_health         ( -- )
    4 0 DO
        I DUP                       ( i i )
        2 SWAP 5 + AT-XY            ( i )
        CELLS t_gear_damage + @     ( x )
        10 MIN                      ( x )
        22 * 10 / DUP               ( d d )
        22 SWAP - 0                 ( d h 0 )
        ?DO                         ( d )
            ." #"
        LOOP                        ( d )
        SPACES                      (  )
    LOOP                            (  )
;

\ (1) Allocate and clear a menu structure: t_padsvc_gear_menu
menu_create t_padsvc_gear_menu
t_padsvc_gear_menu menu_clear


\ (2) handlers for function keys

: t_padsvc_gear_start               ( -- )
    PAD_TO_SHIP                     ( x )
    PORT_RSRC_DIRECTION OUT         (  )
    1 PORT_REPAIR_XFER_STATE OUT    (  )
;

: t_padsvc_gear_return      ( -- )
    FALSE t_padsvc_gear_active !
    t_padsvc_gear_stop
    task_main_addr @        ( parent-orig-task )
    t_padsvc_gear_addr @    ( parent-orig-task this-task )
    task_get_orig           ( parent-orig-task orig-task )
    task_start              (  )
;

\ (3) Define the menu
: t_padsvc_gear_menu_create
    ['] t_padsvc_gear_start S" -START REPAIR" 0 0 t_padsvc_gear_menu 0 4 menu_add_option
    ['] t_padsvc_gear_return S" <STOP/RETURN" 0 0 t_padsvc_gear_menu 0 5 menu_add_option
;

\ (4) Build the menu
t_padsvc_gear_menu_create

\ (5) init function
: t_padsvc_gear_init        ( -- )
    PAGE
    TRUE t_padsvc_gear_active !
    t_padsvc_gear_display_fixed
    t_padsvc_gear_menu menu_show
    fms_refresh_buffer_display
;

\ (6) poll function 
: t_padsvc_gear_poll        ( -- )
    CURSOR-HIDE
    t_padsvc_gear_disp_health
    fms_park_cursor
    CURSOR-SHOW
    \ t_padsvc_gear_check_auto_stop FIXME
;

\ (7) Create the task definition: task_padsvc_gear
    ' t_padsvc_gear_poll ' t_padsvc_gear_init task_create task_padsvc_gear
    task_padsvc_gear t_padsvc_gear_addr !
;