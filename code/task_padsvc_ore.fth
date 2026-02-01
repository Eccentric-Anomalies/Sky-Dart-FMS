\ === task_padsvc_ore.fth ===
\
\ Definition of pad services ore UI task
\

\     ORE LOAD/UNLOAD
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
2000 CONSTANT T_PADSVC_ORE_MAX
1000 CONSTANT T_PADSVC_ORE_MIN

\ Variables
VARIABLE t_padsvc_ore_max
VARIABLE t_padsvc_ore_min
\ Pad resource state
VARIABLE t_padsvc_ore  \ kg / 100
\ Pad resource transfer state. 1 = transfer, 0 = no
VARIABLE t_padsvc_ore_state
\ Prop task is active
VARIABLE t_padsvc_ore_active
\ Prop transfer direction
VARIABLE t_padsvc_ore_dir


\ Initialize
FALSE t_padsvc_ore_active !
PAD_TO_SHIP t_padsvc_ore_dir !

\ Stop the ore transfer
\ Corresponding code must be remove from task_padsvc.fth
: t_padsvc_ore_stop_xfer       ( -- )
    0 PORT_ORE_XFER_STATE OUT  (  )
    FALSE t_padsvc_ore_state !
;

\ Check to see if qty is within min/max bounds
: t_padsvc_ore_in_limits   ( -- f )
    PORT_ORE_QTY IN        ( qty )
    t_padsvc_ore_dir @     ( qty dir )
    PAD_TO_SHIP = IF        ( qty )   \ to ship
        t_padsvc_ore_max @ ( qty max )
        <                   ( qty<max )
    ELSE                    ( qty )
        t_padsvc_ore_min @ ( qty min )
        >                   ( qty>min )
    THEN                    ( f )
;

\ Check to see if transfer must be automatically stopped
: t_padsvc_ore_check_auto_stop ( -- )
    t_padsvc_ore_state @  IF   (  )    \ transferring
        t_padsvc_ore_in_limits ( f )
        NOT IF                  (  )
            t_padsvc_ore_stop_xfer
        THEN
    THEN
;

\ Start the ore transfer
: t_padsvc_ore_start_xfer      ( -- )
    t_padsvc_ore_in_limits     ( f )
    IF
        1 PORT_ORE_XFER_STATE OUT  (  )
        TRUE t_padsvc_ore_state !
    THEN
;


\ Display Curr/Max and Pad quantities
DECIMAL
: t_padsvc_ore_disp_qty        ( -- )
    4                           ( 4 )
    PORT_ORE_QTY IN            ( 4 x )
    1 5 fms_ndigit              (  )
    4                           ( 4 )
    PORT_ORE_CAPACITY IN       ( 4 x )
    6 5 fms_ndigit              (  )
    t_padsvc_ore @             ( x )
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
: t_padsvc_ore_disp_limits     ( -- )
    4                           ( 4 )
    t_padsvc_ore_min @         ( 4 min )
    18 7                        ( 4 min 5 7 )
    fms_ndigit                  (  )
    4                           ( 4 )
    t_padsvc_ore_max @         ( 4 min )
    18 9                        ( 4 min 5 9 )
    fms_ndigit                  (  )
;

\ Display the pad service fixed text
\
DECIMAL
: t_padsvc_ore_display_fixed ( -- )
    2 1 AT-XY   ."    ORE LOAD/UNLOAD"
    1 3 AT-XY   ." CURR/MAX       ON PAD"
    1 4 AT-XY   horizontal_rule
    1 5 AT-XY   ." 0000/0000 KG   00000 KG"
    1 6 AT-XY   horizontal_rule
    1 7 AT-XY  ." -SET MINIMUM QTY 0000 KG"
    1 9 AT-XY  ." -SET MAXIMUM QTY 0000 KG"
    1 10 AT-XY   horizontal_rule
;


\ (1) Allocate and clear a menu structure: t_padsvc_ore_menu
menu_create t_padsvc_ore_menu
t_padsvc_ore_menu menu_clear


\ (2) handlers for function keys

: t_padsvc_ore_setmin          ( -- )
    0 fms_get_buffer_value      ( x )
    t_padsvc_ore_min !         (  )
    t_padsvc_ore_disp_limits   (  )
;

: t_padsvc_ore_setmax          ( -- )
    0 fms_get_buffer_value      ( x )
    DUP PORT_ORE_CAPACITY IN   ( x x max )
    > NOT IF                    ( x )
        t_padsvc_ore_max !         (  )
        t_padsvc_ore_disp_limits   (  )
    ELSE                        ( x )
        DROP                    (  )
    THEN
;

: t_padsvc_ore_stop            ( -- )
    t_padsvc_ore_stop_xfer     (  )
;

: t_padsvc_ore_load            ( -- )
    PAD_TO_SHIP DUP             ( x x )
    PORT_RSRC_DIRECTION OUT     ( x )
    t_padsvc_ore_dir !         (  )
    t_padsvc_ore_start_xfer    (  )
;

: t_padsvc_ore_unload          ( -- )
    SHIP_TO_PAD DUP             ( x x )
    PORT_RSRC_DIRECTION OUT     ( x )
    t_padsvc_ore_dir !         (  )
    t_padsvc_ore_start_xfer    (  )
;

: t_padsvc_ore_return      ( -- )
    FALSE t_padsvc_ore_active !
    t_padsvc_ore_stop
    task_main_addr @        ( parent-orig-task )
    t_padsvc_ore_addr @    ( parent-orig-task this-task )
    task_get_orig           ( parent-orig-task orig-task )
    task_start              (  )
;

\ (3) Define the menu
: t_padsvc_ore_menu_create
    ['] t_padsvc_ore_setmin S" " 0 0 t_padsvc_ore_menu 0 2 menu_add_option
    ['] t_padsvc_ore_setmax S" " 0 0 t_padsvc_ore_menu 0 3 menu_add_option
    ['] t_padsvc_ore_stop S" -STOP" 0 0 t_padsvc_ore_menu 0 4 menu_add_option
    ['] t_padsvc_ore_load S" LOAD-" 0 0 t_padsvc_ore_menu 1 4 menu_add_option
    ['] t_padsvc_ore_return S" <STOP/RETURN" 0 0 t_padsvc_ore_menu 0 5 menu_add_option
    ['] t_padsvc_ore_unload S" UNLOAD-" 0 0 t_padsvc_ore_menu 1 5 menu_add_option
;

\ (4) Build the menu
t_padsvc_ore_menu_create

\ (5) init function
: t_padsvc_ore_init        ( -- )
    PAGE
    TRUE t_padsvc_ore_active !
    t_padsvc_ore_display_fixed
    t_padsvc_ore_menu menu_show
    T_PADSVC_ORE_MAX t_padsvc_ore_max !
    T_PADSVC_ORE_MIN t_padsvc_ore_min !
    t_padsvc_ore_disp_limits
    fms_refresh_buffer_display
;

\ (6) poll function 
: t_padsvc_ore_poll        ( -- )
    CURSOR-HIDE
    t_padsvc_ore_disp_qty
    fms_park_cursor
    CURSOR-SHOW
    t_padsvc_ore_check_auto_stop
;

\ (7) Create the task definition: task_padsvc_ore
    ' t_padsvc_ore_poll ' t_padsvc_ore_init task_create task_padsvc_ore
    task_padsvc_ore t_padsvc_ore_addr !
;

\ Receive notification of grounding state
: t_padsvc_ore_grounded        ( gf -- )
    NOT                         ( !gf )
    t_padsvc_ore_active @      ( !gf s )
    AND                         ( f )
    IF                          (  )
        t_padsvc_ore_return    (  )
    THEN                        (  )
;
