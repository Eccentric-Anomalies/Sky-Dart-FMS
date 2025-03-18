\ === CLOCK.FTH ===

DECIMAL
\ === PERIODIC TIMER HANDLERS ===
\ MSEC TICK COUNT
\ TICK STORAGE
2VARIABLE MSEC-COUNT
50 CONSTANT MSEC-INTERVAL

\ TICK HANDLER
\
: HANDLE-TICK-MSEC  ( -- )
    \ fetch the dword msec count, the msec period, 
    \ then add and update the count
    MSEC-COUNT 2@   ( c1 c2 )
    MSEC-INTERVAL   ( c1 c2 p )
    M+              ( c1 c2 )
    MSEC-COUNT 2!   (  )
;

\ SECONDS COMPUTATION AND DISPLAY

\ SECONDS STORAGE
VARIABLE SEC-COUNT

\ Compute the running count of seconds
\
: COMPUTE-SECONDS   ( -- )
    \ fetch the dword msec count, divide by msec per sec and store
    MSEC-COUNT 2@   ( c1 c2 )
    1000 M/         ( s )
    SEC-COUNT !     (  )
;

\ Generate formatted clock text from total seconds
\
: FORMATTED-CLOCK-TEXT ( u -- c-addr u )
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
: DISPLAY-TIME      ( -- )
    \ save cur, move to 7,1, retrieve seconds, format and display, restore cur
    PUSH-XY                     (  )
    7 1 AT-XY                   (  )
    SEC-COUNT @                 ( u )
    FORMATTED-CLOCK-TEXT TYPE   (  )
    POP-XY                      (  )
;

\ Handle ticks on the order of one second period
\
: HANDLE-TICK-SEC   ( -- )
    COMPUTE-SECONDS
    DISPLAY-TIME
;

\ === PERIODIC TIMER STARTS ===
\ Create periodic tick at MSEC-INTERVAL rate
TID-MSEC-TICK MSEC-INTERVAL P-TIMER HANDLE-TICK-MSEC
\ Create periodic 1/2 second tick
TID-1SEC-TICK 500 P-TIMER HANDLE-TICK-SEC