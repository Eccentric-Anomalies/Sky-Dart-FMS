( === FMS.FTH === )

DECIMAL

\ NUMERIC BUFFER MANAGEMENT 
10  CONSTANT NUMERIC-AVAILABLE-LENGTH
1   CONSTANT NUMERIC-DISPLAY-X
14  CONSTANT NUMERIC-DISPLAY-Y
24  CONSTANT FMS-COLUMNS
14  CONSTANT FMS-ROWS
\ FUNCTION KEY TEXT 
6   CONSTANT FMS-MAX-TASK-NAME-LENGTH
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
    FMS-GET-FKEY-XY
    ERASE-DISPLAY-LINE
    ;

\ Given a piece of text (address and length), function key column and
\ row, display the text by the function key, justifying left on the left
\ and right on the right.
\
: FMS-SET-FKEY-TEXT             (  c-addr u col row -- )
    ( erase the slot first )
    2DUP                        ( c-addr u col row col row )
    FMS-MAX-TASK-NAME-LENGTH    ( c-addr u col row col row l )
    ROT ROT                     ( c-addr u col row l col row )
    FMS-CLEAR-FKEY-TEXT         ( c-addr u col row )
    FMS-GET-FKEY-XY             ( c-addr u x y )
    AT-XY                       ( c-addr u )
    TYPE                    
    ;

\ Erase and initialize the numeric scratchpad area at the screen bottom
\
: RESET-NUMERIC-BUFFER          ( -- )
    1 NUMERIC-CURRENT-LENGTH !
    FALSE DP-DISPLAYED !
    FALSE PM-STATE !
    BL NUMERIC-BUFFER C!        ( SAVE A SPACE CHARACTER TO THE START )
    ERASE-NUMERIC-DISPLAY
    ;


\ Process keypresses on the FMS numeric keypad
\
: HANDLE-FMS-KEYPAD                 ( raw_event -- )
    MASK-FMS-KEY AND                ( get key_value )
    DUP
    VALUE-FMS-CLR = IF              ( [IF 1] check for clear key )
        DROP
        RESET-NUMERIC-BUFFER
    ELSE DUP VALUE-FMS-PM = IF      ( [ELSE 1] [IF 2] check for +/- key )
        DROP
        PM-STATE @ IF               ( [IF 3] )
            BL
        ELSE                        ( [ELSE 3] )
            [CHAR] -
        THEN                        ( [THEN 3] )
        NUMERIC-BUFFER C!            ( store the + or blank in the first position )
        PM-STATE @ NOT PM-STATE !   ( toggle the + or - state )
    ELSE                            ( [ELSE 2] key_value )
        NUMERIC-CURRENT-LENGTH @ NUMERIC-AVAILABLE-LENGTH <> IF     ( [IF 4] if there is room )
            DUP VALUE-FMS-DP = DP-DISPLAYED @ NOT AND IF            ( [IF 5] )
                DROP                ( value is not needed any more )
                [CHAR] .
                NUMERIC-BUFFER NUMERIC-CURRENT-LENGTH @ + C!
                1 NUMERIC-CURRENT-LENGTH +!
                TRUE DP-DISPLAYED ! ( set new dp displayed state )
            ELSE DUP 10 < IF        ( ignore keycodes > 9 )        ( [ELSE 5] [IF 6] )
                [CHAR] 0 +          ( add the keycode to ascii 0 )
                NUMERIC-BUFFER NUMERIC-CURRENT-LENGTH @ + C!
                1 NUMERIC-CURRENT-LENGTH +!
            ELSE                                                    ( [ELSE 6] )
                DROP
            THEN                                                    ( [THEN 6] )
            THEN                                                    ( [THEN 5] )
        ELSE                                                        ( [ELSE 4] )
            DROP                    ( no more room for digits )
        THEN                                                        ( [THEN 4] )
    THEN                                                            ( [THEN 2] )
    THEN                                                            ( [THEN 1] )
    ERASE-NUMERIC-DISPLAY
    NUMERIC-DISPLAY-X NUMERIC-DISPLAY-Y AT-XY
    NUMERIC-BUFFER NUMERIC-CURRENT-LENGTH @ TYPE
    ;


\ Given the raw FMS function key event, return the logical column and row
\ of the button. Column is 0 (left) or 1 (right) and ROW is 0-5.
\
: FMS-KEY-EVENT-TO-COL-ROW                  ( raw-event -- col row )
    DUP                                     ( raw_event raw_event )
    MASK-FMS-KEYGROUP AND                   ( raw_event key_group )
    MASK-FMS-RIGHT-FN = IF 1 ELSE 0 THEN    ( raw_event col )
    SWAP                                    ( col raw_event )
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


( FMS BUTTON TEST )
( raw_event -- )
: HANDLE-FMS-BUTTON
    DUP                                 ( raw_event raw_event )
    MASK-FMS-KEYGROUP AND               ( get the keygroup )
    MASK-FMS-KEYPAD <> IF
        HANDLE-FMS-FUNCTION             ( raw_event )
    ELSE
        HANDLE-FMS-KEYPAD               ( raw_event )
    THEN
    PARK-CURSOR
    ;

( FMS ONE-SHOT STARTUP HANDLER )
: HANDLE-ONE-SHOT 
    ( erase the ok message )
    2 1 1 ERASE-DISPLAY-LINE
    ( RESET THE NUMERIC )
    RESET-NUMERIC-BUFFER
    PARK-CURSOR
    ( stop the timer )
    TID-FMS-ONE-SHOT P-STOP
    ;

( FMS TASK MANAGER INIT )
0 TASK-CURRENT-XT !                     ( no current task )

( FMS TASK MANAGER )                    ( execute current task, if any )
: FMS-TASK-MANAGER
    TASK-CURRENT-XT @ 0<> IF
        TASK-CURRENT-XT @ EXECUTE
        THEN
    ;



( START A ONE-SHOT )
TID-FMS-ONE-SHOT 100 P-TIMER HANDLE-ONE-SHOT

( LISTEN FOR BUTTON PRESSES )
PORT-BUTTON-FMS 0 LISTEN HANDLE-FMS-BUTTON  ( Listen for any FMS button )

( START THE FMS TASK MANAGER )
TID-FMS-TASK 500 P-TIMER FMS-TASK-MANAGER