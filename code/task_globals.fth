\ === task_globals.fth ===
\
\ Global variables for sharing data between tasks
\


\ Global task pointers 
\ If a task needs a reference to a task structure that is 
\ defined later in the interpretation, place a reference
\ to it here after it is created.

\ MAIN
VARIABLE task_main_addr

\ DIAG
VARIABLE t_diag_addr

\ GEAR
VARIABLE t_gear_addr
VARIABLE t_gear_padsvc_grounded_notify
VARIABLE t_gear_warning_given

\ gf is TRUE if ship is grounded, FALSE if aloft
: t_gear_notify_grounded    ( gf -- )
    \ insert references to functions to receive grounded state changes
    DUP t_gear_padsvc_grounded_notify @ EXECUTE
    \ ... more here - copy line above as necessary
    DROP
;

\ PADSVC
VARIABLE t_padsvc_addr

\ PADSVC PROP
VARIABLE t_padsvc_prop_addr

\ PADSVC ORE
VARIABLE t_padsvc_ore_addr

\ PADSVC GEAR
VARIABLE t_padsvc_gear_addr

\ MSG
VARIABLE t_msg_addr