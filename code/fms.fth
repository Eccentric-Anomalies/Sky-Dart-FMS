\ === FMS.FTH ===

DECIMAL

\ NUMERIC BUFFER MANAGEMENT 
10  CONSTANT NUMERIC-AVAILABLE-LENGTH
1   CONSTANT NUMERIC-DISPLAY-X
14  CONSTANT NUMERIC-DISPLAY-Y
24  CONSTANT FMS-COLUMNS
14  CONSTANT FMS-ROWS
\ FUNCTION KEY TEXT 
VARIABLE DP-DISPLAYED
VARIABLE PM-STATE
VARIABLE NUMERIC-CURRENT-LENGTH
VARIABLE TASK-CURRENT-XT        \ CURRENT TASK XT - ZERO IF NONE
\ RAM BUFFER FOR BUILDING TEXT NUMERIC VALUE
CREATE NUMERIC-BUFFER NUMERIC-AVAILABLE-LENGTH ALLOT

\ Park the cursor position in the lower-right screen corner
\ 
: PARK-CURSOR                           ( -- )
    FMS-COLUMNS FMS-ROWS AT-XY
;

\ Display length blanks beginning at screen coordinates x, y
\
: ERASE-DISPLAY-LINE                    ( length x y -- )
    AT-XY                               ( length )
    SPACES
;

\ Display text (address, length) at screen coordinates x, y
\
: TEXT-DISPLAY-LINE                     ( c-addr u x y -- )
    AT-XY                               ( c-addr u )
    TYPE
;

\ Erase the numeric scratchpad area at the bottom of the screen
: ERASE-NUMERIC-DISPLAY                 ( -- )
    NUMERIC-AVAILABLE-LENGTH            ( length )
    NUMERIC-DISPLAY-X NUMERIC-DISPLAY-Y ( length x y )
    ERASE-DISPLAY-LINE
;


\ NOTE: FKEY COLumn 0,1 and ROW 0,1,2,3,4,5 
\
\ Given a text length, function key column and row, return 
\ the length and screen column, row coordinates to begin text
\ that is right or left justified
\ 
: FMS-GET-FKEY-XY               ( length col row -- length x y )
    SWAP                        ( length row col )
    0= IF
        1                       ( length row x )
    ELSE
        FMS-COLUMNS 1+          ( length row fms-cols+1 )
        2 PICK                  ( length row fms-cols+1 length )
        -                       ( length row x )
    THEN
    SWAP                        ( length x row )
    2 * 3 +                     ( length x y )
;

\ Given a length, function key column and row, print length blanks
\ at the correct position to erase any existing text.
\ 
: FMS-CLEAR-FKEY-TEXT           ( length col row -- )
    FMS-GET-FKEY-XY             ( length x y )
    ERASE-DISPLAY-LINE          (  )
;

\ Given a piece of text (address and length), function key column and
\ row, display the text by the function key, justifying left on the left
\ and right on the right.
\
: FMS-SET-FKEY-TEXT             (  c-addr u col row -- )
    FMS-GET-FKEY-XY             ( c-addr u x y )
    AT-XY                       ( c-addr u )
    TYPE                        (  )
    ;

\ Erase and initialize the numeric scratchpad area at the screen bottom
\
: RESET-NUMERIC-BUFFER          ( -- )
    1 NUMERIC-CURRENT-LENGTH !  (  )
    FALSE DP-DISPLAYED !        (  )
    FALSE PM-STATE !            (  )
    \ Save a blank character at the start as a sign placeholder
    BL NUMERIC-BUFFER C!        (  )
    ERASE-NUMERIC-DISPLAY       (  )
    ;


\ Process keypresses on the FMS numeric keypad
\
: HANDLE-FMS-KEYPAD                 ( raw-event -- )
    MASK-FMS-KEY AND                ( u )
    DUP                             ( u u )
    VALUE-FMS-CLR = IF              ( [IF 1] u )
        DROP                        (  )
        RESET-NUMERIC-BUFFER        (  )
    \ check for +/- key
    ELSE DUP VALUE-FMS-PM = IF      ( [ELSE 1] [IF 2] u )
        DROP                        (  )
        PM-STATE @ IF               ( [IF 3] )
            BL                      ( u )
        ELSE                        ( [ELSE 3] u )
            [CHAR] -                ( u )
        THEN                        ( [THEN 3] u )
        \ store the + or bl in the first position
        NUMERIC-BUFFER C!           (  )
        \ toggle the + or - state variable
        PM-STATE @ NOT PM-STATE !   (  )
    ELSE                            ( [ELSE 2] u )
        NUMERIC-CURRENT-LENGTH @    ( u u )
        \ check to see if there is room for more
        NUMERIC-AVAILABLE-LENGTH <> IF  ( [IF 4] u )
            DUP VALUE-FMS-DP =      ( u f )
            DP-DISPLAYED @ NOT AND IF   ( [IF 5] u )
                DROP                (  )
                [CHAR] .            ( u )
                NUMERIC-BUFFER NUMERIC-CURRENT-LENGTH @ + C!    (  )
                1 NUMERIC-CURRENT-LENGTH +!                     (  )
                \ set the new dp displayed state
                TRUE DP-DISPLAYED ! (  )
            \ ignore keycodes > 9
            ELSE DUP 10 < IF        ( [ELSE 5] [IF 6] u )
                \ add the keycode to ascii 0
                [CHAR] 0 +          ( u )
                NUMERIC-BUFFER NUMERIC-CURRENT-LENGTH @ + C!    (  )
                1 NUMERIC-CURRENT-LENGTH +!                     (  )
            ELSE                    ( [ELSE 6] )
                DROP                (  )
            THEN                    ( [THEN 6] )
            THEN                    ( [THEN 5] )
        ELSE                        ( [ELSE 4] )
            \ no more room for digits
            DROP                    (  )
        THEN                        ( [THEN 4] )
    THEN                            ( [THEN 2] )
    THEN                            ( [THEN 1] )
    ERASE-NUMERIC-DISPLAY
    NUMERIC-DISPLAY-X NUMERIC-DISPLAY-Y AT-XY
    NUMERIC-BUFFER NUMERIC-CURRENT-LENGTH @ TYPE
;


\ Given the raw FMS function key event, return the logical column and row
\ of the button. Column is 0 (left) or 1 (right) and ROW is 0-5.
\
: FMS-KEY-EVENT-TO-COL-ROW                  ( raw-event -- col row )
    DUP                                     ( raw-event raw-event )
    MASK-FMS-KEYGROUP AND                   ( raw-event key-group )
    MASK-FMS-RIGHT-FN = IF 1 ELSE 0 THEN    ( raw-event col )
    SWAP                                    ( col raw-event )
    MASK-FMS-KEY AND                        ( col row )
;


\ Given the raw FMS function key event, transfer the numeric scratchpad
\ to the slot next to the function key.
\
: HANDLE-FMS-FUNCTION                   ( raw-event -- )
    NUMERIC-BUFFER NUMERIC-CURRENT-LENGTH @ ( raw-event c-addr u )
    ROT                                 ( c-addr u raw-event )
    FMS-KEY-EVENT-TO-COL-ROW            ( c-addr u col row )
    2DUP                                ( c-addr u col row col row )
    NUMERIC-AVAILABLE-LENGTH            ( c-addr u col row col row length )
    ROT ROT                             ( c-addr u col row length col row )
    FMS-CLEAR-FKEY-TEXT                 ( c-addr u col row )
    FMS-SET-FKEY-TEXT
;


\ FMS button handler
\
: HANDLE-FMS-BUTTON                     ( raw-event -- )
    DUP                                 ( raw-event raw-event )
    MASK-FMS-KEYGROUP AND               ( raw-event key-group )
    MASK-FMS-KEYPAD <> IF               ( raw-event)
        HANDLE-FMS-FUNCTION             (  )
    ELSE
        HANDLE-FMS-KEYPAD               (  )
    THEN
    PARK-CURSOR
;

\ FMS one-time initialization code (follows any boot activity)  FIXME probably not needed long-term
\
: HANDLE-ONE-SHOT                       ( -- )
    \ erase the ok message
    2 1 1 ERASE-DISPLAY-LINE            (  )
    RESET-NUMERIC-BUFFER                (  )
    PARK-CURSOR                         (  )
    TID-FMS-ONE-SHOT P-STOP             (  )
;

\ Initialize the current task 
0 TASK-CURRENT-XT !


\ FMS task poll handler executes poll for current task, if any
\
: FMS-TASK-MANAGER                      ( -- )
    TASK-CURRENT-XT @ 0<> IF            (  )
        TASK-CURRENT-XT @ EXECUTE       (  )
    THEN
;


RESET-NUMERIC-BUFFER

\ Listen for all button press events on the FMS
PORT-BUTTON-FMS 0 LISTEN HANDLE-FMS-BUTTON

\ Start a service timer for the FMS task manager
TID-FMS-TASK 500 P-TIMER FMS-TASK-MANAGER