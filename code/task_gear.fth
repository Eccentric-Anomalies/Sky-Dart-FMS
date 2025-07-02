\ === task_.fth ===
\
\ Definition of top level UI task
\
\  |           |           |            
\     LANDING GEAR STATUS
\
\      GOOD     FAILIMM
\     XX.X KN   XX.X KN   
\          \     /
\           *---*   
\           |   |
\           *---*
\          /     \
\     XX.X KN   XX.X KN   
\     MINOR     SEVERE 
\
\
\  <RETURN

\ Create storage for damage and force values and clear
CREATE t_gear_damage 4 CELLS ALLOT
CREATE t_gear_force 4 CELLS ALLOT
t_gear_damage 4 CELLS 0 FILL        
t_gear_force 4 CELLS 0 FILL     

\ Create list of column coordinates for force displays
CREATE t_gear_force_cols 4 , 4 , 14 , 14 ,
CREATE t_gear_force_rows 4 , 10 , 10 , 4 ,
\ Create list of column coordinates for damage displays
CREATE t_gear_dmg_cols 4 , 4 , 14 , 14 ,
CREATE t_gear_dmg_rows 3 , 11 , 11 , 3 ,

\ Local variables
VARIABLE t_gear_changed
VARIABLE t_gear_grounded
VARIABLE t_gear_pending
VARIABLE t_gear_pending_grounded

\ Initialize
FALSE t_gear_grounded !
FALSE t_gear_pending !
FALSE t_gear_pending_grounded !

\ Initialize global
FALSE t_gear_warning_given !


\ Pending timer expired
: t_gear_timer_expired          ( -- )
    TID_TASK_GEAR P-STOP        (  )
    FALSE t_gear_pending !      (  )
    t_gear_pending_grounded @   ( ps )
    DUP t_gear_grounded !       ( ns )
    t_gear_notify_grounded      (  )
;


\ Set pending state 
: t_gear_set_pending            ( gp -- )
    t_gear_pending @ NOT IF     ( gp )
        t_gear_pending_grounded !   (  )
        TRUE t_gear_pending !   (  )
        ['] t_gear_timer_expired
        TID_TASK_GEAR 1000      ( xt i n )
        P-TIMERX
    ELSE                        ( gp )
        DROP                    (  )
    THEN
;

\ Clear pending state
: t_gear_clear_pending          ( -- )
    t_gear_pending @ IF         (  )
        FALSE t_gear_pending !  (  )
        TID_TASK_GEAR P-STOP    (  )
    THEN
;

\ Check for grounded state change
\
: t_gear_check_grounded         ( -- )
    0                           ( sum=0 )
    4 0 DO                      ( sum )
        t_gear_force I + @      ( sum f )
        +
    LOOP                        ( sum )
    0= IF                       (  )
        t_gear_grounded @ IF    (  )
            FALSE               ( f )   \ not grounded pending
            t_gear_set_pending  (  )
        ELSE
            t_gear_clear_pending    (  )
        THEN                    (  )
    ELSE                        (  )
        t_gear_grounded @ NOT IF    (  )
            TRUE                ( t )   \ grounded pending
            t_gear_set_pending  (  )
        ELSE                    (  )
            t_gear_clear_pending    (  )
        THEN
    THEN
;


\ Handle warning light notification
: t_gear_check_warning            ( -- )
    t_gear_warning_given @         ( f )
    NOT IF
        4 0 DO
            I CELLS                 ( offs )
            t_gear_damage + @       ( dmg )
            0<>                     ( f )
            t_gear_warning_given @  ( f f )
            NOT AND IF              (  )
                1 PORT_WARNING OUT  (  )
                TRUE t_gear_warning_given !
            THEN
        LOOP                    
    THEN
;

\ handler for foot status messages
\
DECIMAL
: t_gear_rcv_foot               ( n -- )
    DUP FOOT_ID_FIELD /         ( n id )
    CELLS                       ( n 4id )
    SWAP                        ( 4id n )
    DUP MASK_FOOT_DAMAGE AND    ( 4id n v )
    FOOT_DAMAGE_FIELD / SWAP    ( 4id d n )
    MASK_FOOT_FORCE AND         ( 4id d f )
    DUP                         ( 4id d f f )
    3 PICK DUP                  ( 4id d f f 4id 4id )
    ROT SWAP                    ( 4id d f 4id f 4id )
    t_gear_force + @            ( 4id d f 4id f old-force )
    <> IF 1 t_gear_changed +! THEN  ( 4id d f 4id )
    DUP                         ( 4id d f 4id 4id )
    ROT SWAP                    ( 4id d 4id f 4id )
    t_gear_force + !            ( 4id d 4id )
    SWAP DUP ROT                ( 4id d d 4id )
    t_gear_damage + @           ( 4id d d old-dam )
    <> IF 1 t_gear_changed +! THEN  ( 4id d )
    SWAP t_gear_damage + !      (  )
    t_gear_check_grounded       (  )
    t_gear_check_warning        (  )
;


\ Display foot forces
\
DECIMAL
: t_gear_display_forces         ( -- )
    4 0 DO                      (  )
        I CELLS                 ( offs )
        DUP DUP                 ( offs offs offs )
        t_gear_force_cols + @   ( offs offs col )
        SWAP                    ( offs col offs )
        t_gear_force_rows + @   ( offs col row )
        AT-XY                   ( offs )
        t_gear_force + @        ( force )
        100 /                   ( force/100 )
        0 <# # [CHAR] . HOLD # # #> TYPE (  )
    LOOP (  )
;

\ Display foot damage
\
DECIMAL
: t_gear_display_damages         ( -- )
    4 0 DO                      (  )
        I CELLS                 ( offs )
        DUP DUP                 ( offs offs offs )
        t_gear_dmg_cols + @     ( offs offs col )
        SWAP                    ( offs col offs )
        t_gear_dmg_rows + @     ( offs col row )
        AT-XY                   ( offs )
        t_gear_damage + @       ( dmg )
        DUP 8 > IF              ( dmg )
            REVERSEV            ( dmg )
            S" FAILED"          ( dmg addr l )
        ELSE DUP 6 > IF         ( dmg )
            BLINKV              ( dmg )
            REVERSEV            ( dmg )
            S" FAILING"         ( dmg addr l )
        ELSE DUP 3 > IF         ( dmg )
            REVERSEV            ( dmg )
            S" SEVERE "         ( dmg addr l )
        ELSE DUP 0> IF          ( dmg )
            S" DAMAGED"         ( dmg addr l )
        ELSE                    ( dmg )
            S"   OK   "         ( dmg addr l )
        THEN \ >0               ( dmg addr l )
        THEN \ >2               ( dmg addr l )
        THEN \ >5               ( dmg addr l )
        THEN \ >10              ( dmg addr l )
        TYPE NOMODEV DROP       (  )
    LOOP (  )
;


\ Display damage and force values only
: t_gear_display_values     ( -- )
    CURSOR-HIDE
    t_gear_display_forces
    t_gear_display_damages
    CURSOR-SHOW
    fms_park_cursor
;


\ (1) Allocate and clear a menu structure: t_gear_menu
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
    t_gear_changed @            ( f )
    0<> IF                      (  )
        0 t_gear_changed !      (  )
        t_gear_display_values   (  )
    THEN
;

\ (5) t_gear init function
DECIMAL
: t_gear_init                 ( -- )
    PAGE
    t_gear_menu menu_show               (  )
    4 1  AT-XY ." LANDING GEAR STATUS"
    9 4  AT-XY ." KN        KN"
    9 5  AT-XY ." \     /"
    11 6 AT-XY 18 EMIT 18 EMIT 18 EMIT   
    10 7 AT-XY 25 EMIT 32 EMIT 32 EMIT 32 EMIT 25 EMIT
    11 8 AT-XY 18 EMIT 18 EMIT 18 EMIT
    9 9  AT-XY ." /     \"
    9 10 AT-XY ." KN        KN"
    t_gear_display_values       (  )
    fms_refresh_buffer_display  (  )
;

\ (7) Create the task definition: task_gear
' t_gear_poll ' t_gear_init task_create task_gear
task_gear t_gear_addr !


\ Listen for foot status messages (DO queue duplicate messages)
PORT_FOOT_STATUS 0 LISTEN t_gear_rcv_foot

DECIMAL