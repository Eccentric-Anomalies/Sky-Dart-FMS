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

\ Create storage for damage and force values
CREATE t_gear_damage 4 CELLS ALLOT
CREATE t_gear_force 4 CELLS ALLOT

\ Create list of column coordinates for force displays
CREATE t_gear_force_cols 4 , 4 , 14 , 14 ,
CREATE t_gear_force_rows 4 , 10 , 10 , 4 ,
\ Create list of column coordinates for damage displays
CREATE t_gear_dmg_cols 4 , 4 , 14 , 14 ,
CREATE t_gear_dmg_rows 3 , 11 , 11 , 3 ,

\ Local variables
VARIABLE t_gear_changed

\ handler for foot status messages
\
DECIMAL
: t_gear_rcv_foot               ( n -- )
    0 t_gear_changed !          ( n )
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
    <> IF t_gear_changed 1 +! THEN  ( 4id d f 4id )
    DUP                         ( 4id d f 4id 4id )
    ROT SWAP                    ( 4id d 4id f 4id )
    t_gear_force + !            ( 4id d 4id )
    SWAP DUP ROT                ( 4id d d 4id )
    t_gear_damage + @           ( 4id d d old-dam )
    <> IF t_gear_changed 1 +! THEN  ( 4id d )
    SWAP t_gear_damage + !      (  )
    t_gear_changed @            ( f )
    0<> IF                      (  )
        \ FIXME do something when the gear values change
    THEN
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
        0 <# # # #> TYPE (  )
    LOOP (  )
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
    t_gear_display_forces
    t_gear_display_damages
    fms_park_cursor
;

\ (5) t_gear init function
DECIMAL
: t_gear_init                 ( -- )
    PAGE
    t_gear_menu menu_show    (  )
    4 1  AT-XY ." LANDING GEAR STATUS"
    9 4  AT-XY ." KN        KN"
    9 5  AT-XY ." \     /"
    11 6 AT-XY 18 EMIT 18 EMIT 18 EMIT   
    10 7 AT-XY 25 EMIT 32 EMIT 32 EMIT 32 EMIT 25 EMIT
    11 8 AT-XY 18 EMIT 18 EMIT 18 EMIT
    9 9  AT-XY ." /     \"
    9 10 AT-XY ." KN        KN"
    fms_refresh_buffer_display  (  )
;

\ (7) Create the task definition: task_gear
' t_gear_poll ' t_gear_init task_create task_gear
task_gear t_gear_addr !


\ Listen for foot status messages (do not queue duplicate messages)
PORT_FOOT_STATUS 0 LISTEN t_gear_rcv_foot

DECIMAL