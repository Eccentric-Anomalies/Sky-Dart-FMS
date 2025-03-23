\ === IOMAP.FTH === 
\ NOTE: DEFINED NAMES ARE TRANSLATED TO GDSCRIPT
\ - CHARACTERS ARE TRANSLATED to _ 
\ VALID CHARACTERS ARE A-Z,a-z,0-9,-,_ 
\ ALL PORTS AND TIMER IDS SHOULD BE DEFINED HERE 
\ ALSO ANY GLOAL IDENTIFIERS - E.G. TASK IDS

HEX

\ === INPUTS === 
\ BUTTONS

    \ BUTTON STATE MASKS 
    1 CONSTANT MASK_BUTTON_STATE
    2 CONSTANT MASK_BUTTON_LIGHT

    \ FMS KEYPAD MASKS
    0FF00 CONSTANT MASK_FMS_KEYGROUP
    000FF CONSTANT MASK_FMS_KEY
    100 CONSTANT MASK_FMS_KEYPAD
    200 CONSTANT MASK_FMS_LEFT_FN
    400 CONSTANT MASK_FMS_RIGHT_FN
    \ Number of function key rows (numbered 0-5)
    6 CONSTANT FMS_FN_ROWS
    \ Function key values 0-5 (top to bottom), appear in MASK_FMS_KEY byte
    \ Numeric keypad values will be 0-9 for numeric, otherwise:
    0A CONSTANT FMS_DP       \ DECIMAL POINT
    0B CONSTANT FMS_PM       \ PLUS / MINUS
    0C CONSTANT FMS_UP       \ UP ARROW
    0D CONSTANT FMS_DN       \ DOWN ARROW
    0E CONSTANT FMS_SP       \ SPACE
    0F CONSTANT FMS_CLR      \ CLEAR

    \ PORTS
    01 CONSTANT PORT_BUTTON_FMS
    10 CONSTANT PORT_BUTTON_LANDING_LIGHT


\ === OUTPUTS ===
\ LIGHTS
    10 CONSTANT PORT_LANDING_LIGHT

\ === TIMERS ===
    2 CONSTANT TID_MSEC_TICK
    3 CONSTANT TID_1SEC_TICK
    4 CONSTANT TID_TASK_INIT
    5 CONSTANT TID_FMS_TASK

\ == TASKS IDENTIFIED IN DESCENDING ORDER OF PRIORITY ===
    0 1 -                                   \ -1
    1 + DUP     CONSTANT TASKID_PROP        \ PROPULSION
    1 + DUP     CONSTANT TASKID_COMM        \ COMMUNICATIONS
    1 + DUP     CONSTANT TASKID_CHRO        \ CHRONOMETER

    1 +         CONSTANT TASK_QTY           \ TASKS QUANTITY

