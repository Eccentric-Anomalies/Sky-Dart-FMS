\ === CLOCK.FTH ===

DECIMAL
\ === PERIODIC TIMER HANDLERS ===
\ MSEC TICK COUNT
\ TICK STORAGE
2VARIABLE clock_msec_count
50 CONSTANT MSEC_INTERVAL

\ Emit a seconds-timestamp in 0000:00:00 format
\
DECIMAL
: clock_stst        ( n -- )
    60 /MOD         ( s m )
    60 /MOD         ( s m h )
    0               ( s m dh )
    <# [CHAR] : HOLD # # # # #> TYPE ( s m )
    0               ( s dm )
    <# [CHAR] : HOLD # # #> TYPE ( s )
    0               ( ds )
    <# # # #> TYPE  (  )
;

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

\ RTC Tick Handler - initializes FMS clock
\
: handle_rtc_tick           ( sec -- )
    1000 UM*                ( d-msec )
    clock_msec_count 2!     (  )
    PORT_RTC_SECONDS UNLISTEN
;

\ === LISTEN FOR RTC TICK ===
PORT_RTC_SECONDS 0 LISTEN handle_rtc_tick


\ === PERIODIC TIMER STARTS ===
\ Create periodic tick at MSEC_INTERVAL rate
TID_MSEC_TICK MSEC_INTERVAL P-TIMER handle_tick_msec
