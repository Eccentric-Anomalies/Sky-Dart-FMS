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

\ LANDING PAD LOCAL SIGNAL

    \ Message types (in HO byte)
    FF000000 CONSTANT MASK_PADL_MSG
    00FFFFFF CONSTANT MASK_PADL_VALUE
    0        CONSTANT PADL_RSRC
    01000000 CONSTANT PADL_NAME
    02000000 CONSTANT PADL_ALT
    03000000 CONSTANT PADL_LON
    04000000 CONSTANT PADL_LAT
    05000000 CONSTANT PADL_PAD_0_NAME
    06000000 CONSTANT PADL_PAD_0_DIR
    07000000 CONSTANT PADL_PAD_0_DIST
    08000000 CONSTANT PADL_PAD_1_NAME
    09000000 CONSTANT PADL_PAD_1_DIR
    0A000000 CONSTANT PADL_PAD_1_DIST
    0B000000 CONSTANT PADL_DONE

    \ Multipliers for message values
    DECIMAL
    1000    CONSTANT PADL_ANGLE_X
    HEX

    \ Resource Identifiers
    00010000 CONSTANT PADL_RSRC_POS
    00FFFF CONSTANT MASK_RSRC_VALUE
    01 CONSTANT PADL_FOOD   \ g/100
    02 CONSTANT PADL_WATER  \ ml/100
    03 CONSTANT PADL_ELEC   \ wh/100
    04 CONSTANT PADL_O2     \ ml/100
    05 CONSTANT PADL_LIOH   \ g/100
    06 CONSTANT PADL_PROP   \ kg/100
    07 CONSTANT PADL_REPAIR \ bool
    08 CONSTANT PADL_SPICE  \ kg/100

\ == INPUTS ===
\
    01 CONSTANT PORT_RTC_SECONDS
    02 CONSTANT PORT_BUTTON_FMS
    03 CONSTANT PORT_PADL_RECV
    10 CONSTANT PORT_BUTTON_LANDING_LIGHT

\ === OUTPUTS ===
\ LIGHTS
    10 CONSTANT PORT_LANDING_LIGHT

\ === TIMERS ===
    0           \ 1-based
    1 + DUP     CONSTANT TID_MSEC_TICK
    1 + DUP     CONSTANT TID_TASK_MAIN_INIT
    1 + DUP     CONSTANT TID_TASK_POLL
    1 + DUP     CONSTANT TID_TASK_CHRON_TIMER

                CONSTANT TID_QTY

\ == TASKS IDENTIFIED IN DESCENDING ORDER OF PRIORITY ===
    0 1 -       \ 0-based
    1 + DUP     CONSTANT TASKID_PROP        \ PROPULSION
    1 + DUP     CONSTANT TASKID_COMM        \ COMMUNICATIONS
    1 + DUP     CONSTANT TASKID_CHRO        \ CHRONOMETER

    1 +         CONSTANT TASK_QTY           \ TASKS QUANTITY

