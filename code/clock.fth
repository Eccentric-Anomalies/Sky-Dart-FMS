\ === CLOCK.FTH ===

DECIMAL
\ === PERIODIC TIMER HANDLERS ===
\ MSEC TICK COUNT
\ TICK STORAGE
2VARIABLE msec_count
50 CONSTANT MSEC_INTERVAL
\ SECONDS STORAGE
VARIABLE sec_count

\ TICK HANDLER
\
: handle_tick_msec  ( -- )
    \ fetch the dword msec count, the msec period, 
    \ then add and update the count
    msec_count 2@   ( c1 c2 )
    MSEC_INTERVAL   ( c1 c2 p )
    M+              ( c1 c2 )
    msec_count 2!   (  )
;

\ SECONDS COMPUTATION AND DISPLAY


\ Compute the running count of seconds
\
: compute_seconds   ( -- )
    \ fetch the dword msec count, divide by msec per sec and store
    msec_count 2@   ( c1 c2 )
    1000 M/         ( s )
    sec_count !     (  )
;

\ Generate formatted clock text from total seconds
\
: formatted_clock_text ( u -- c-addr u )
    \ generate seconds, minutes, then hours
    60 /MOD         ( s q )
    60 /MOD         ( s m h )
    \ move the hours figure to the fifth place
    10000 *         ( s m h*10000 )
    \ more minutes to the third place, then add seconds to produce HHHHMMSS
    SWAP 100 * + +  ( h*10000 + m*100 + s )
    \ format the result as -> hhhhHmmMssS
    0 <# [CHAR] S HOLD # # [CHAR] M HOLD # # [CHAR] H HOLD # # # # #> ( c-addr u )
;

\ Display formatted time on the terminal screen
\
: display_time      ( -- )
    \ save cur, move to 7,1, retrieve seconds, format and display, restore cur
    PUSH-XY                     (  )
    7 1 AT-XY                   (  )
    sec_count @                 ( u )
    formatted_clock_text TYPE   (  )
    POP-XY                      (  )
;

\ Handle ticks on the order of one second period
\
: handle_tick_sec   ( -- )
    compute_seconds
    display_time
;

\ === PERIODIC TIMER STARTS ===
\ Create periodic tick at MSEC_INTERVAL rate
TID_MSEC_TICK MSEC_INTERVAL P-TIMER handle_tick_msec
\ Create periodic 1/2 second tick
TID_1SEC_TICK 500 P-TIMER handle_tick_sec