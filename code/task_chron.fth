\ === task_chron.fth ===
\
\ Definition of chronometer/stopwatch UI task
\

\ Constants
100 CONSTANT T_CHRON_TIMER_MSEC

\ (0) Variable to hold addr of this task
VARIABLE t_chron_addr

\ task state
VARIABLE t_chron_active

\ Time storage
VARIABLE t_chron_sec_count
VARIABLE t_chron_sec_only
VARIABLE t_chron_min_only
VARIABLE t_chron_hour_only

\ Timer state
VARIABLE t_chron_msec_timer
VARIABLE t_chron_up
VARIABLE t_chron_down

\ Initialize variables as needed
FALSE t_chron_active !
0 t_chron_msec_timer !
FALSE t_chron_up !
FALSE t_chron_down !


\ Compute the running count of seconds, minutes, hours
\
DECIMAL
: t_chron_compute_seconds   ( -- )
    \ fetch the dword msec count, divide by msec per sec and store
    clock_msec_count 2@   ( c1 c2 )
    1000 M/                 ( s )
    DUP                     ( s s )
    t_chron_sec_count !     ( s )
    60 /MOD                 ( s q )
    60 /MOD                 ( s m h )
    t_chron_hour_only !     ( s m )
    t_chron_min_only !      ( s )
    t_chron_sec_only !      (  )
;

\ Display the updated mission time
\
: t_chron_display_mission_time
    6 4 AT-XY t_chron_hour_only @ 0 <# # # # # # #> TYPE 
    9 5 AT-XY t_chron_min_only @ 0 <# # # #> TYPE
    9 6 AT-XY t_chron_sec_only @ 0 <# # # #> TYPE
    fms_park_cursor
;

\ Display the updated timer value
\ Original value is msec, display to 1/10 sec
\ 
: t_chron_display_timer         ( -- )
    6 10 AT-XY
    t_chron_msec_timer @ 100 /  ( s*10 )
    0 <# # [CHAR] . HOLD # # # # #> TYPE
    fms_park_cursor             (  )
;

\ Display the mission time fixed text
\
: t_chron_display_fixed_text ( -- )
    6 2 AT-XY   ." MISSION TIME"
    6 3 AT-XY   ." ------------"
    12 4 AT-XY        ." HOUR"
    12 5 AT-XY        ." MIN"
    12 6 AT-XY        ." SEC"

    8 8 AT-XY     ." TIMER"
    6 9 AT-XY   ." ----------"
    13 10 AT-XY        ." SEC"
;

\ Stopwatch is counting up or down
\
: t_chron_is_counting               ( -- f )
    t_chron_up @ t_chron_down @ OR  ( f )
;

\ Halt the stopwatch
\ 
: t_chron_halt          ( -- )
    TID_TASK_CHRON_TIMER P-STOP
    FALSE t_chron_up !
    FALSE t_chron_down !
;

\ Stopwatch timer handler
\
: t_chron_stopwatch_timeout         ( -- )
    T_CHRON_TIMER_MSEC              ( msec )
    t_chron_up @                    ( msec isup )
    IF                              ( msec )
        t_chron_msec_timer +!       (  )
    ELSE                            ( msec )
        t_chron_msec_timer @        ( msec val )
        SWAP -                      ( new )
        DUP                         ( new new )
        t_chron_msec_timer !        ( new )
        0= IF                       (  )
            t_chron_halt            (  )
        THEN                        (  )
    THEN                            (  )
    t_chron_active @ IF             (  )
        t_chron_display_timer       (  )
    THEN
;

\ Start the stopwatch
\ 
: t_chron_start                     ( -- )
    ['] t_chron_stopwatch_timeout   ( xt )
    TID_TASK_CHRON_TIMER            ( xt id )
    T_CHRON_TIMER_MSEC              ( xt id msec )
    P-TIMERX
;

\ (1) handlers for function keys
\ handler to return to calling menu
\
: t_chron_return        ( -- )
    FALSE t_chron_active !
    t_chron_addr @      ( this-task )
    DUP                 ( this-task this-task )
    task_get_orig       ( this-task orig-task )
    task_start          (  )
;

\ set function key
: t_chron_set                   ( -- )
    \ get scratchpad value * 1000
    3                           ( n )
    fms_get_buffer_value        ( x )
    100 / 100 *                 ( x )  \ clear all but 1/10 s
    t_chron_msec_timer !        (  )
    t_chron_display_timer       (  )
;

\ reset function key
: t_chron_reset                 ( -- )
    \ do something to reset the stopwatch
    t_chron_halt                (  )
    0 t_chron_msec_timer !      (  )
    t_chron_display_timer       (  )
;

\ start up-counting or stop
: t_chron_start_up          ( -- )
    \ do something to start the stopwatch up / stop
    t_chron_is_counting IF          (  )
        t_chron_halt
    ELSE
        TRUE t_chron_up !           (  )
        t_chron_start
    THEN
;

\ start down-counting or stop
: t_chron_start_down        ( -- )
    \ do something to start the stopwatch down / stop
    t_chron_is_counting IF          (  )
        t_chron_halt
    ELSE
        t_chron_msec_timer @          ( msec )
        0<> IF                        (  )
            TRUE t_chron_down !           (  )
            t_chron_start                 (  )
        THEN
    THEN
;


\ (2) Allocate, clear, define and build the menu
menu_create t_chron_menu
t_chron_menu menu_clear

: t_chron_menu_create
    ['] t_chron_return S" <RETURN" 0 0 t_chron_menu 0 5 menu_add_option
    ['] t_chron_set S" SET" 0 0 t_chron_menu 1 2 menu_add_option
    ['] t_chron_reset S" RESET" 0 0 t_chron_menu 1 3 menu_add_option
    ['] t_chron_start_up S" UP/ST" 0 0 t_chron_menu 1 4 menu_add_option
    ['] t_chron_start_down S" DN/ST" 0 0 t_chron_menu 1 5 menu_add_option
;

t_chron_menu_create

\ (3) task init and poll functions
\ init
: t_chron_init               ( -- )
    PAGE
    TRUE t_chron_active !           (  )
    t_chron_menu menu_show          (  )
    t_chron_display_fixed_text      (  )
    fms_refresh_buffer_display      (  )
    t_chron_display_timer           (  )
;

\ poll
: t_chron_poll               ( -- )
    t_chron_compute_seconds
    t_chron_display_mission_time
;

\ (4) Create the task definition: task_chron
' t_chron_poll ' t_chron_init task_create task_chron
task_chron t_chron_addr !
