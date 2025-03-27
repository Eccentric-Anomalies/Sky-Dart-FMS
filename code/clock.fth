\ === CLOCK.FTH ===

DECIMAL
\ === PERIODIC TIMER HANDLERS ===
\ MSEC TICK COUNT
\ TICK STORAGE
2VARIABLE clock_msec_count
50 CONSTANT MSEC_INTERVAL

\ TICK HANDLER
\
: handle_tick_msec  ( -- )
    \ fetch the dword msec count, the msec period, 
    \ then add and update the count
    clock_msec_count 2@   ( c1 c2 )
    MSEC_INTERVAL   ( c1 c2 p )
    M+              ( c1 c2 )
    clock_msec_count 2!   (  )
;


\ === PERIODIC TIMER STARTS ===
\ Create periodic tick at MSEC_INTERVAL rate
TID_MSEC_TICK MSEC_INTERVAL P-TIMER handle_tick_msec
