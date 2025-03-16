( === CLOCK.FTH === )

( === PERIODIC TIMER HANDLERS === )
( MSEC TICK COUNT )
( TICK STORAGE )
2VARIABLE MSEC-COUNT
50 CONSTANT MSEC-INTERVAL
( TICK HANDLER )
: HANDLE-TICK-MSEC  ( -- )
    MSEC-COUNT 2@   ( fetch the dword msec count )
    MSEC-INTERVAL   ( fetch the msec period )
    M+              ( add them )
    MSEC-COUNT 2!   ( update the dword count )
    ;

( SECONDS COMPUTATION AND DISPLAY )
VARIABLE SEC-COUNT      ( SECONDS STORAGE )
: COMPUTE-SECONDS   ( -- )
    MSEC-COUNT 2@   ( fetch the dword msec count )
    1000 M/         ( divide by msec per sec )
    SEC-COUNT !     ( store it seconds )
    ;

( FORMATTED CLOCK TEXT )
: FORMATTED-CLOCK-TEXT ( u -- c-addr u )
    60 /MOD          ( get seconds, minutes total )
    60 /MOD          ( now seconds, minutes, hours total )
    10000 *          ( hours shown at fifth place )
    SWAP 100 * +     ( minutes shown at third place )
    +                ( add seconds - should be HHHHMMSS )
    ( BEGIN FORMATTING SINGLE PRECISION -> hhhhHmmMssS )
    0 <# [CHAR] S HOLD # # [CHAR] M HOLD # # [CHAR] H HOLD # # # # #> 
    ;

( TIME DISPLAY )
: DISPLAY-TIME      ( -- )
    PUSH-XY         ( save display cursor )
    7 1 AT-XY      ( position top middle for 24 column screen )
    SEC-COUNT @     ( obtain the running count of seconds )
    FORMATTED-CLOCK-TEXT TYPE ( format and display it )
    POP-XY          ( restore display cursor )
    ;

( ONE SECOND TICK HANDLER )
: HANDLE-TICK-SEC
    DECIMAL
    COMPUTE-SECONDS ( update the seconds count )
    DISPLAY-TIME ( display the seconds count)
    ;

( === PERIODIC TIMER STARTS === )
( Create periodic tick at MSEC-INTERVAL rate)
TID-MSEC-TICK MSEC-INTERVAL P-TIMER HANDLE-TICK-MSEC
( Create periodic 1/2 second tick )
TID-1SEC-TICK 500 P-TIMER HANDLE-TICK-SEC