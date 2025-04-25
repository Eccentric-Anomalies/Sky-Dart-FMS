\ === task_padsvc.fth ===
\
\ Definition of pad services UI task
\

\
\  xxx -90.00°-180.00°9999M
\  TO> yyy 359.9° 001.00 KM
\  TO> zzz 359.9° 9999.0 KM
\  FOOD   10.0  10.0   LIOH
\         KG    KG  
\  WATER  10.0  10.0   PROP
\         L     MT  
\  ELEC   10.0   YES REPAIR
\         KWH 
\  O2     10.0  10.0  MINED
\         L     MT  
\  <RETURN
\

\ (0) Variable to hold addr of this task
VARIABLE t_padsvc_addr

\ task state
VARIABLE t_padsvc_active

\ pad info state
VARIABLE t_padsvc_name
VARIABLE t_padsvc_alt   \ km times 10
VARIABLE t_padsvc_lat   \ degrees times 100
VARIABLE t_padsvc_lon   \ degrees times 100
VARIABLE t_padsvc_0nam
VARIABLE t_padsvc_0dir  \ degrees times 10
VARIABLE t_padsvc_0dist \ km times 100
VARIABLE t_padsvc_1nam
VARIABLE t_padsvc_1dir  \ degrees times 10
VARIABLE t_padsvc_1dist \ km times 100
\ pad resource state
VARIABLE t_padsvc_food  \ kg times 10
VARIABLE t_padsvc_water \ liters times 10
VARIABLE t_padsvc_elec  \ kwh times 10
VARIABLE t_padsvc_o2    \ liters times 10
VARIABLE t_padsvc_lioh  \ kg times 10
VARIABLE t_padsvc_prop  \ kg / 100
VARIABLE t_padsvc_repair    \ 10 or 0
VARIABLE t_padsvc_spice \ kg / 100
\ resource transfer state 1 = transferring 0 = not
VARIABLE t_padsvc_food_state
VARIABLE t_padsvc_water_state
VARIABLE t_padsvc_elec_state
VARIABLE t_padsvc_o2_state
VARIABLE t_padsvc_lioh_state
VARIABLE t_padsvc_prop_state
VARIABLE t_padsvc_repair_state
VARIABLE t_padsvc_spice_state

VARIABLE t_padsvc_3buff

\ reference to the menu
\ reference to the resource update routine
VARIABLE t_padsvc_menu_t
VARIABLE t_padsvc_rsrcupd_t

\ Initialize variables as needed
FALSE t_padsvc_active !

\ Display the pad service fixed text
\
: t_padsvc_display_fixed_text ( -- )
    3 1 AT-XY   ." LANDING PAD SERVICES"
    1 3 AT-XY   ." TO> "
    1 4 AT-XY   ." TO> "
;

\ Erase the state variables
\
HEX
: t_padsvc_erase_state      ( -- )
    00202020 t_padsvc_name !
    002D2D2D DUP
    t_padsvc_0nam !
    t_padsvc_1nam !
    0 DUP DUP 
    t_padsvc_alt !
    t_padsvc_lat !
    t_padsvc_lon !
    0 DUP DUP DUP
    t_padsvc_0dir !
    t_padsvc_0dist !
    t_padsvc_1dir !
    t_padsvc_1dist !
    \ initialize resources to -1 to reveal
    \ which values have actually been set
    0 1- DUP 2DUP 2DUP 2DUP
    t_padsvc_food !
    t_padsvc_water !
    t_padsvc_elec !
    t_padsvc_o2 !
    t_padsvc_lioh !
    t_padsvc_prop !
    t_padsvc_repair !
    t_padsvc_spice !
    0 DUP 2DUP 2DUP 2DUP
    t_padsvc_food_state !
    t_padsvc_water_state !
    t_padsvc_elec_state !
    t_padsvc_o2_state !
    t_padsvc_lioh_state !
    t_padsvc_prop_state !
    t_padsvc_repair_state !
    t_padsvc_spice_state !
;

\ Erase it now
t_padsvc_erase_state

\ Print three characters embedded in a cell at a certain
\ character position
\
HEX
: t_padsvc_print_3char      ( c r n -- )
    DUP 010000 / t_padsvc_3buff C!              ( c r n )
    DUP 00FF00 AND 100 / t_padsvc_3buff 1 + C!  ( c r n )
    0FF AND t_padsvc_3buff 2 + C!               ( c r )
    AT-XY                                       (  )
    t_padsvc_3buff 3 TYPE                       (  )
;

\ Prepare to print latitude or longitude
\
: t_padsvc_prep_latlon      ( c r n -- n +n 0  )
    ROT ROT                 ( n c r )
    AT-XY                   ( n )
    DUP 0> IF               ( n )
        ."  "               ( n )
    THEN                    ( n )
    DUP ABS 0               ( n +n 0 )
;

\ Print latitude to two decimal places 
: t_padsvc_print_lat        ( c r n -- )
    t_padsvc_prep_latlon    ( n +n 0 )
    <# 7 HOLD # # [CHAR] . HOLD # # ROT SIGN #> TYPE
;

\ Print longitude to two decimal places 
: t_padsvc_print_lon        ( c r n -- )
    t_padsvc_prep_latlon    ( n +n 0 )
    <# 7 HOLD # # [CHAR] . HOLD # # # ROT SIGN #> TYPE
;

\ Print altitude in meters 
: t_padsvc_print_alt        ( c r n -- )
    ROT ROT AT-XY 0         ( d )
    <# [CHAR] M HOLD # # # # #> TYPE
;

\ Print distance (in m/10 ) in km to one or two dp
DECIMAL
: t_padsvc_print_dist       ( c r n -- )
    ROT ROT AT-XY           ( n )
    DUP 100000 < IF         ( n )
        0 <# # # [CHAR] . HOLD # # # #> TYPE
    ELSE                    ( n )
        10 /                ( n/10 )
        0 <# # [CHAR] . HOLD # # # # #> TYPE
    THEN                    (  )
    ."  KM"                  (  )
;

\ Print direction (in degrees*10) in degrees to one dp
: t_padsvc_print_dir        ( c r n --  )
    ROT ROT AT-XY 0         ( d )
    <# 7 HOLD # [CHAR] . HOLD # # # #> TYPE
;


\ Display all of the acquired data for the pad (if menu active)
\
DECIMAL
: t_padsvc_update           ( -- )
    t_padsvc_active @ IF
        DECIMAL
        1 2 t_padsvc_name @ t_padsvc_print_3char    (  )
        5 2 t_padsvc_lat @ t_padsvc_print_lat       (  )
        12 2 t_padsvc_lon @ t_padsvc_print_lon      (  )
        20 2 t_padsvc_alt @ t_padsvc_print_alt      (  )
        5  3 t_padsvc_0nam @ t_padsvc_print_3char   (  )
        9  3 t_padsvc_0dir @ t_padsvc_print_dir     (  )
        16 3 t_padsvc_0dist @ t_padsvc_print_dist   (  )
        5  4 t_padsvc_1nam @ t_padsvc_print_3char   (  )
        9  4 t_padsvc_1dir @ t_padsvc_print_dir     (  )
        16 4 t_padsvc_1dist @ t_padsvc_print_dist   (  )
        fms_park_cursor                             (  )
    THEN
;

\ Function key handlers 
\
\ Generic handler takes port ID, and state address,
\ toggles the state and sends it to the port
\ update the resource display afterwards
: t_padsvc_state_toggle     ( p saddr -- )
    DUP                         ( p saddr saddr )
    @                           ( p saddr s )
    1 = IF                      ( p saddr )
        0                       ( p saddr ns )
    ELSE                        ( p saddr )
        1                       ( p saddr ns )
    THEN                        ( p saddr ns )
    DUP                         ( p saddr ns ns )
    ROT                         ( p ns ns saddr )
    !                           ( p ns )
    SWAP                        ( ns p )
    OUT                         (  )
    t_padsvc_rsrcupd_t @        ( faddr )
    EXECUTE                     (  )
;

: t_padsvc_food_key
;

: t_padsvc_water_key
;

: t_padsvc_elec_key
;

: t_padsvc_o2_key
;

: t_padsvc_lioh_key
;

: t_padsvc_prop_key             ( -- )
    PORT_PROP_XFER_STATE t_padsvc_prop_state t_padsvc_state_toggle
;

: t_padsvc_repair_key           ( -- )
    PORT_REPAIR_XFER_STATE t_padsvc_repair_state t_padsvc_state_toggle
;

: t_padsvc_spice_key
;



\ Display a single potentially available resource 
\    units text, units c r, fkey c r, fkey xt, vaddr, staddr, label, label c r 
: t_padsvc_print_rsrc   ( addr l c r fc fr f sa va addr l c r -- )
    AT-XY               ( addr l c r fc fr f sa va addr l )
    TYPE                ( addr l c r fc fr f sa va )
    @                   ( addr l c r fc fr f sa v )
    DUP 0 1- = IF       ( addr l c r fc fr f sa v ) 
        ." ----" 2DROP  ( addr l c r fc fr f )
        DROP 0          ( addr l c r fc fr xt=0 )
    ELSE
        \ display in bold, assign the function key
        SWAP @          ( addr l c r fc fr f v s )
        1 = IF          ( addr l c r fc fr f v )
            REVERSEV    ( addr l c r fc fr f v )
        ELSE            ( addr l c r fc fr f v )
            UNDERLINEV      ( addr l c r fc fr f v )
        THEN
        0 <# # [CHAR] . HOLD # # #> TYPE    ( addr l c r fc fr f )
        NOMODEV         ( addr l c r fc fr f )
    THEN
    ROT ROT             ( addr l c r f fc fr )
    t_padsvc_menu_t @   ( addr l c r f fc fr m )
    ROT ROT             ( addr l c r f m fc fr )
    menu_set_item_xt    ( addr l c r )
    AT-XY TYPE          (  )
;



\ Display all of the resource data for the pad (if menu active)
\
DECIMAL
: t_padsvc_rsrcupd           ( -- )
    t_padsvc_active @ IF
        DECIMAL
        \ unit, unit position, fkey position, fkey handler, state addr, 
        \   qty addr, qty name, name position
        S" KG"  10 6  0 1 ['] t_padsvc_food_key   t_padsvc_food_state   
            t_padsvc_food   S" FOOD   " 1 5   t_padsvc_print_rsrc
        S" L"   11 8  0 2 ['] t_padsvc_water_key  t_padsvc_water_state  
            t_padsvc_water  S" WATER  " 1 7   t_padsvc_print_rsrc
        S" KWH" 9 10  0 3 ['] t_padsvc_elec_key   t_padsvc_elec_state   
            t_padsvc_elec   S" ELEC   " 1 9   t_padsvc_print_rsrc
        S" L"   11 12 0 4 ['] t_padsvc_o2_key     t_padsvc_o2_state     
            t_padsvc_o2     S" O2     " 1 11  t_padsvc_print_rsrc
        S" KG"  23 6  1 1 ['] t_padsvc_lioh_key   t_padsvc_lioh_state   
            t_padsvc_lioh   S" LIOH   " 14 5  t_padsvc_print_rsrc
        S" MT"  23 8  1 2 ['] t_padsvc_prop_key   t_padsvc_prop_state   
            t_padsvc_prop   S" PROP   " 14 7  t_padsvc_print_rsrc
        S" 1/0" 22 10 1 3 ['] t_padsvc_repair_key t_padsvc_repair_state 
            t_padsvc_repair S" REPAIR " 14 9  t_padsvc_print_rsrc
        S" MT"  23 12 1 4 ['] t_padsvc_spice_key  t_padsvc_spice_state  
            t_padsvc_spice  S" MINED  " 14 11 t_padsvc_print_rsrc
        fms_park_cursor                             (  )
    THEN
;

\ preserve a reference to it
' t_padsvc_rsrcupd t_padsvc_rsrcupd_t !

\ handler for resource qty message: | rsrc | v hi | v lo |
\
HEX
: t_padsvc_rcv_resrc            ( v3 -- )
    DUP                         ( v3 v3 )
    MASK_RSRC_VALUE AND SWAP    ( v v3 )
    PADL_RSRC_POS /             ( v r )
    DUP PADL_FOOD = IF          ( v r )
        DROP t_padsvc_food !    (  )
    ELSE DUP PADL_WATER = IF    ( v r )
        DROP t_padsvc_water !   (  )
    ELSE DUP PADL_ELEC = IF     ( v r )
        DROP t_padsvc_elec !    (  )
    ELSE DUP PADL_O2 = IF       ( v r )
        DROP t_padsvc_o2 !      (  )
    ELSE DUP PADL_LIOH = IF     ( v r )
        DROP t_padsvc_lioh !    (  )
    ELSE DUP PADL_PROP = IF     ( v r )
        DROP t_padsvc_prop !    (  )
    ELSE DUP PADL_REPAIR = IF   ( v r )
        DROP                    ( v )
        0A * t_padsvc_repair !  (  )
    ELSE DUP PADL_SPICE = IF    ( v r )
        DROP t_padsvc_spice !   (  )
    ELSE 2DROP                  (  ) \ no matches
    THEN    \ PADL_SPICE
    THEN    \ PADL_REPAIR
    THEN    \ PADL_PROP
    THEN    \ PADL_LIOH
    THEN    \ PADL_O2
    THEN    \ PADL_ELEC
    THEN    \ PADL_WATER
    THEN    \ PADL_FOOD
    t_padsvc_rsrcupd
;


\ handler for padl pad local service messages
\
DECIMAL
: t_padsvc_rcv_padl           ( n -- )
    DUP MASK_PADL_VALUE AND     ( n v )
    256 * 256 /                 ( n v ) \ extend sign
    SWAP                        ( v n )
    MASK_PADL_MSG AND           ( v pm )
    DUP PADL_RSRC = IF          ( v pm )
        DROP                    ( v )
        t_padsvc_rcv_resrc      (  )
    ELSE DUP PADL_NAME = IF     ( v pm )
        DROP                    ( v )
        t_padsvc_erase_state    ( v )
        t_padsvc_name !         (  )
    ELSE DUP PADL_ALT = IF      ( v pm )
        DROP                    ( v )
        t_padsvc_alt !          (  )
    ELSE DUP PADL_LON = IF      ( v pm )
        DROP                    ( v )
        10 /                    ( v/10 )
        t_padsvc_lon !          (  )
    ELSE DUP PADL_LAT = IF      ( v pm )
        DROP                    ( v )
        10 /                    ( v/10 )
        t_padsvc_lat !          (  )
    ELSE DUP PADL_PAD_0_NAME = IF   ( v pm )
        DROP                    ( v )
        t_padsvc_0nam !         (  )
    ELSE DUP PADL_PAD_0_DIR = IF    ( v pm )
        DROP                    ( v )
        100 /                   ( v/100 )
        t_padsvc_0dir !         (  )
    ELSE DUP PADL_PAD_0_DIST = IF   ( v pm )
        DROP                    ( v )
        10 /                    ( v/10 )
        t_padsvc_0dist !        (  )
    ELSE DUP PADL_PAD_1_NAME = IF   ( v pm )
        DROP                    ( v )
        t_padsvc_1nam !         (  )
    ELSE DUP PADL_PAD_1_DIR = IF    ( v pm )
        DROP                    ( v )
        100 /                   ( v/100 )
        t_padsvc_1dir !         (  )
    ELSE DUP PADL_PAD_1_DIST = IF   ( v pm )
        DROP                    ( v )
        10 /                    ( v/10 )
        t_padsvc_1dist !        (  )
    ELSE DUP PADL_DONE = IF     ( v pm )
        2DROP                   (  )
        t_padsvc_update         (  )
\ FIXME        t_padsvc_rsrcupd        (  )
    ELSE 2DROP                  (  )    \ no matches
    THEN    \ PADL_DONE
    THEN    \ PADL_PAD_1_DIST
    THEN    \ PADL_PAD_1_DIR
    THEN    \ PADL_PAD_1_NAME
    THEN    \ PADL_PAD_0_DIST
    THEN    \ PADL_PAD_0_DIR
    THEN    \ PADL_PAD_0_NAME
    THEN    \ PADL_LAT
    THEN    \ PADL_LON
    THEN    \ PADL_ALT
    THEN    \ PADL_NAME
    THEN    \ PADL_RSRC
;

\ Notification handler for ground state change
: t_padsvc_grounded_notify  ( gf -- )
    NOT IF              (  )
        t_padsvc_erase_state
        t_padsvc_rsrcupd
    THEN                (  )
;

\ Place a reference to the notification function
' t_padsvc_grounded_notify t_gear_padsvc_grounded_notify !

\ (1) handlers for function keys
\ handler to return to calling menu
\
: t_padsvc_return        ( -- )
    FALSE t_padsvc_active !
    0                   ( null-orig-task)  \ returning to the top level
    t_padsvc_addr @     ( null-orig-task this-task )
    task_get_orig       ( null-orig-task orig-task )
    task_start          (  )
;



\ (2) Allocate, clear, define and build the menu
menu_create t_padsvc_menu
t_padsvc_menu menu_clear
\ save its address
t_padsvc_menu t_padsvc_menu_t !

: t_padsvc_menu_create
    ['] t_padsvc_return S" <RETURN" 0 0 t_padsvc_menu 0 5 menu_add_option
;

t_padsvc_menu_create

\ (3) task init and poll functions
\ init
: t_padsvc_init               ( -- )
    PAGE
    TRUE t_padsvc_active !           (  )
    t_padsvc_menu menu_show          (  )
    t_padsvc_display_fixed_text      (  )
    t_padsvc_update                  (  )
    t_padsvc_rsrcupd                 (  )
    fms_refresh_buffer_display       (  )
;

\ poll
: t_padsvc_poll             ( -- )
;

\ (4) Create the task definition: task_padsvc
' t_padsvc_poll ' t_padsvc_init task_create task_padsvc
task_padsvc t_padsvc_addr !


\ Listen for pad service messages
PORT_PADL_RECV 0 LISTEN t_padsvc_rcv_padl

DECIMAL