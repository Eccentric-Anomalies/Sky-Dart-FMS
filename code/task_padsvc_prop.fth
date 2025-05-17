\ === task_padsvc_prop.fth ===
\
\ Definition of pad services propellent UI task
\

\   PROPELLENT LOAD/UNLOAD
\  
\  CURR/MAX       ON PAD
\  ------------------------
\  0000/0000 KG   00000 KG
\  ------------------------
\  SET MINIMUM QTY  0000 KG
\  
\  SET MAXIMUM QTY  0000 KG 
\  ------------------------
\  STOP                LOAD
\  
\  <STOP/RETURN      UNLOAD
\     ~ scratch ~

\ Constants
DECIMAL
2500 CONSTANT T_PADSVC_PROP_MAX
1000 CONSTANT T_PADSVC_PROP_MIN

\ Variables
VARIABLE t_padsvc_prop_max
VARIABLE t_padsvc_prop_min
\ Pad resource state
VARIABLE t_padsvc_prop  \ kg / 100
\ Pad resource transfer state. 1 = transfer, 0 = no
VARIABLE t_padsvc_prop_state
\ Prop task is active
VARIABLE t_padsvc_prop_active


\ Initialize
FALSE t_padsvc_prop_active !

\ Stop the propellent transfer
\ Corresponding code must be remove from task_padsvc.fth
: t_padsvc_prop_stop_xfer       ( -- )
    0 PORT_PROP_XFER_STATE OUT  (  )
    FALSE t_padsvc_prop_state !
;

\ Start the propellent transfer
: t_padsvc_prop_start_xfer      ( -- )
    1 PORT_PROP_XFER_STATE OUT  (  )
    TRUE t_padsvc_prop_state !
;


\ Display Curr/Max and Pad quantities
DECIMAL
: t_padsvc_prop_disp_qty        ( -- )
    4                           ( 4 )
    PORT_PROP_QTY IN            ( 4 x )
    1 5 fms_ndigit              (  )
    4                           ( 4 )
    PORT_PROP_CAPACITY IN       ( 4 x )
    6 5 fms_ndigit              (  )
    t_padsvc_prop @             ( x )
    DUP 0 1- = IF               ( x )
        DROP                    (  )
        16 5 AT-XY              (  )  
        ." -----"               (  )
    ELSE                        ( x )
        5 SWAP                  ( 5 x )
        100 *                   ( 5 100x )
        16 5 fms_ndigit         (  )
    THEN
;

\ Display min and max propellent load values
: t_padsvc_prop_disp_limits     ( -- )
    4                           ( 4 )
    t_padsvc_prop_min @         ( 4 min )
    18 7                        ( 4 min 5 7 )
    fms_ndigit                  (  )
    4                           ( 4 )
    t_padsvc_prop_max @         ( 4 min )
    18 9                        ( 4 min 5 9 )
    fms_ndigit                  (  )
;

\ Display the pad service fixed text
\
DECIMAL
: t_padsvc_prop_display_fixed ( -- )
    2 1 AT-XY   ." PROPELLENT LOAD/UNLOAD"
    1 3 AT-XY   ." CURR/MAX       ON PAD"
    1 4 AT-XY   horizontal_rule
    1 5 AT-XY   ." 0000/0000 KG   00000 KG"
    1 6 AT-XY   horizontal_rule
    1 7 AT-XY  ." -SET MINIMUM QTY 0000 KG"
    1 9 AT-XY  ." -SET MAXIMUM QTY 0000 KG"
    1 10 AT-XY   horizontal_rule
;

\ Receive notification of grounding state
: t_padsvc_prop_grounded        ( gf -- )
    NOT                         ( !gf )
    t_padsvc_prop_active @      ( !gf s )
    t_padsvc_prop_state @       ( !gf s s )
    AND                         ( !gf f )
    AND                         ( f )
    IF                          (  )
        t_padsvc_prop_stop_xfer (  )
    THEN                        (  )
;


\ (1) Allocate and clear a menu structure: t_padsvc_prop_menu
menu_create t_padsvc_prop_menu
t_padsvc_prop_menu menu_clear


\ (2) handlers for function keys

: t_padsvc_prop_setmin          ( -- )
    0 fms_get_buffer_value      ( x )
    t_padsvc_prop_min !         (  )
    t_padsvc_prop_disp_limits   (  )
;

: t_padsvc_prop_setmax          ( -- )
    0 fms_get_buffer_value      ( x )
    DUP PORT_PROP_CAPACITY IN   ( x x max )
    > NOT IF                    ( x )
        t_padsvc_prop_max !         (  )
        t_padsvc_prop_disp_limits   (  )
    ELSE                        ( x )
        DROP                    (  )
    THEN
;

: t_padsvc_prop_stop            ( -- )
    t_padsvc_prop_stop_xfer     (  )
;

: t_padsvc_prop_load            ( -- )
    PAD_TO_SHIP                 ( x )
    PORT_RSRC_DIRECTION OUT     (  )
    t_padsvc_prop_start_xfer    (  )
;

: t_padsvc_prop_unload          ( -- )
    SHIP_TO_PAD                 ( x )
    PORT_RSRC_DIRECTION OUT     (  )
    t_padsvc_prop_start_xfer    (  )
;

: t_padsvc_prop_return      ( -- )
    FALSE t_padsvc_prop_active !
    t_padsvc_prop_stop
    task_main_addr @        ( parent-orig-task )
    t_padsvc_prop_addr @    ( parent-orig-task this-task )
    task_get_orig           ( parent-orig-task orig-task )
    task_start              (  )
;

\ (3) Define the menu
: t_padsvc_prop_menu_create
    ['] t_padsvc_prop_setmin S" " 0 0 t_padsvc_prop_menu 0 2 menu_add_option
    ['] t_padsvc_prop_setmax S" " 0 0 t_padsvc_prop_menu 0 3 menu_add_option
    ['] t_padsvc_prop_stop S" -STOP" 0 0 t_padsvc_prop_menu 0 4 menu_add_option
    ['] t_padsvc_prop_load S" LOAD-" 0 0 t_padsvc_prop_menu 1 4 menu_add_option
    ['] t_padsvc_prop_return S" <STOP/RETURN" 0 0 t_padsvc_prop_menu 0 5 menu_add_option
    ['] t_padsvc_prop_unload S" UNLOAD-" 0 0 t_padsvc_prop_menu 1 5 menu_add_option
;

\ (4) Build the menu
t_padsvc_prop_menu_create

\ (5) init function
: t_padsvc_prop_init        ( -- )
    PAGE
    TRUE t_padsvc_prop_active !
    t_padsvc_prop_display_fixed
    t_padsvc_prop_menu menu_show
    T_PADSVC_PROP_MAX t_padsvc_prop_max !
    T_PADSVC_PROP_MIN t_padsvc_prop_min !
    t_padsvc_prop_disp_limits
    fms_refresh_buffer_display
;

\ (6) poll function 
: t_padsvc_prop_poll        ( -- )
    CURSOR-HIDE
    t_padsvc_prop_disp_qty
    CURSOR-SHOW
    fms_park_cursor
;

\ (7) Create the task definition: task_padsvc_prop
    ' t_padsvc_prop_poll ' t_padsvc_prop_init task_create task_padsvc_prop
    task_padsvc_prop t_padsvc_prop_addr !
;