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


VARIABLE t_padsvc_3buff

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


\ handler for padl pad local service messages
\
DECIMAL
: t_padsvc_rcv_padl           ( n -- )
    DUP MASK_PADL_VALUE AND     ( n v )
    256 * 256 /                 ( n v ) \ extend sign
    SWAP                        ( v n )
    MASK_PADL_MSG AND           ( v pm )
    DUP PADL_RSRC = IF          ( v pm )
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

\ (1) handlers for function keys
\ handler to return to calling menu
\
: t_padsvc_return        ( -- )
    FALSE t_padsvc_active !
    t_padsvc_addr @     ( this-task )
    DUP                 ( this-task this-task )
    task_get_orig       ( this-task orig-task )
    task_start          (  )
;



\ (2) Allocate, clear, define and build the menu
menu_create t_padsvc_menu
t_padsvc_menu menu_clear

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