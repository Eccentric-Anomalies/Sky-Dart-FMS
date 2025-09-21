\ === FMS.FTH ===

DECIMAL

\ NUMERIC BUFFER MANAGEMENT 
10  CONSTANT NUMERIC_AVAILABLE_LENGTH
5   CONSTANT NUMERIC_DISPLAY_X
14  CONSTANT NUMERIC_DISPLAY_Y
24  CONSTANT FMS_COLUMNS
14  CONSTANT FMS_ROWS
\ FUNCTION KEY TEXT 
VARIABLE fms_dp_displayed
VARIABLE fms_pm_state
VARIABLE fms_num_curr_length
\ RAM BUFFER FOR BUILDING TEXT NUMERIC VALUE
CREATE fms_num_buffer NUMERIC_AVAILABLE_LENGTH ALLOT
\ Keep track of whole and frac parts of number
VARIABLE fms_whole
VARIABLE fms_frac
\ Vector for handling UP DOWN and SP keys
VARIABLE fms_up_xt
VARIABLE fms_dn_xt
VARIABLE fms_sp_xt

\ Initialize variables
fms_num_buffer fms_whole !
0 fms_frac !

\ Reset the fms special key handler vectors
: fms_reset_key_xts            ( -- )
    0 fms_up_xt !
    0 fms_dn_xt !
    0 fms_sp_xt !
    ;

\ and reset them now...
fms_reset_key_xts

\ Vector to an fms special key handler, if set
: fms_vec                   ( a -- )
    @                       ( xt )
    DUP 0<> IF              ( xt )
        EXECUTE             (  )
    ELSE                    ( xt )
        DROP                (  )
    THEN                    (  )
;

\ Park the cursor position in the lower-right screen corner
\ 
: fms_park_cursor                           ( -- )
    NUMERIC_DISPLAY_X fms_num_curr_length @ +
    NUMERIC_DISPLAY_Y AT-XY
;

\ Display n-digit integer x at cx, cy
: fms_ndigit                ( n x cx cy -- )
    AT-XY                   ( n x )
    0                       ( n d )
    <#                      ( n d )
    ROT                     ( d n )
    0                       ( d n 0 )
    DO                      ( d )
        #                   ( d )
    LOOP                    ( d )
    #> TYPE                 (  )
;

\ Display length blanks beginning at screen coordinates x, y
\
: erase_display_line                    ( length x y -- )
    AT-XY                               ( length )
    SPACES
;

\ Display text (address, length) at screen coordinates x, y
\
: text_display_line                     ( c-addr u x y -- )
    AT-XY                               ( c-addr u )
    TYPE
;

\ Erase the numeric scratchpad area at the bottom of the screen
: erase_numeric_display                 ( -- )
    NUMERIC_AVAILABLE_LENGTH            ( length )
    NUMERIC_DISPLAY_X NUMERIC_DISPLAY_Y ( length x y )
    erase_display_line
;


\ NOTE: FKEY COLumn 0,1 and ROW 0,1,2,3,4,5 
\
\ Given a text length, function key column and row, return 
\ the length and screen column, row coordinates to begin text
\ that is right or left justified
\ 
: fms_get_fkey_xy               ( length col row -- length x y )
    SWAP                        ( length row col )
    0= IF
        1                       ( length row x )
    ELSE
        FMS_COLUMNS 1+          ( length row fms-cols+1 )
        2 PICK                  ( length row fms-cols+1 length )
        -                       ( length row x )
    THEN
    SWAP                        ( length x row )
    2 * 3 +                     ( length x y )
;

\ Given a length, function key column and row, print length blanks
\ at the correct position to erase any existing text.
\ 
: fms_clear_fkey_text           ( length col row -- )
    fms_get_fkey_xy             ( length x y )
    erase_display_line          (  )
;

\ Given a piece of text (address and length), function key column and
\ row, display the text by the function key, justifying left on the left
\ and right on the right.
\
: fms_set_fkey_text             (  c-addr u col row -- )
    fms_get_fkey_xy             ( c-addr u x y )
    AT-XY                       ( c-addr u )
    TYPE                        (  )
    ;

\ Given a piece of text (address and length), function key column and
\ row, display the text above the function key, justifying left on the left
\ and right on the right.
\
: fms_set_fkey_label            ( c-addr u col row -- )
    fms_get_fkey_xy             ( c-addr u x y )
    1-                          ( c-addr u x y )
    AT-XY                       ( c-addr u )
    TYPE                        (  )
    ;

\ Erase and initialize the numeric scratchpad area at the screen bottom
\
: reset_fms_num_buffer          ( -- )
    1 fms_num_curr_length !  (  )
    FALSE fms_dp_displayed !        (  )
    FALSE fms_pm_state !            (  )
    \ Save a blank character at the start as a sign placeholder
    BL fms_num_buffer C!        (  )
    erase_numeric_display       (  )
    0 fms_frac !                (  )
    ;

\ Refresh the buffer display
\
: fms_refresh_buffer_display
    erase_numeric_display
    NUMERIC_DISPLAY_X NUMERIC_DISPLAY_Y AT-XY
    fms_num_buffer fms_num_curr_length @ TYPE
;

\ Get numeric value of whole part of buffer (signed)
: fms_get_whole_value               ( -- x )
    \ compute the number of digits, considering dp
    fms_whole @ 1 +                 ( addr )
    0                               ( addr 0 )
    fms_frac @ 0= IF                ( addr 0 )
        fms_num_curr_length @ 1 - 0 ( addr 0 l 0 )
    ELSE                            ( addr 0 )
        OVER                        ( addr 0 addr )
        fms_frac @ 1 - SWAP         ( addr 0 end-addr addr )
        - 0                         ( addr 0 l 0 )
    THEN                            ( addr 0 l 0 )
    ?DO                             ( addr 0 )
        10 *                        ( addr n*10 )
        SWAP DUP                    ( n*10 addr addr )
        C@ [CHAR] 0 -               ( n*10 addr digit )
        ROT +                       ( addr n )
        SWAP                        ( n addr )
        1 +                         ( n addr+1 )
        SWAP                        ( addr n )
    LOOP                            
    SWAP DROP                       ( n )
    \ Check for negative
    fms_whole @ [CHAR] -            ( n c '-' )
    = IF                            ( n )
        NEGATE                      ( x )
    THEN                            ( x )
;

\ Get numeric value of fractional part, multiplied by 1 billion
: fms_get_frac_e9                   ( -- x )
    fms_frac @ 0<> IF               
        \ compute the number of digits
        0                               ( r )
        fms_num_curr_length @           ( r loa )
        fms_frac @                      ( r loa faddr )
        fms_whole @ -                   ( r loa faddr-offset )
        -                               ( r l )
        100000000 SWAP 0                ( r m l 0 )
        ?DO                             ( r m )
            fms_frac @ I +              ( r m d-addr )
            C@ [CHAR] 0 -               ( r m d )
            OVER                        ( r m d m )
            *                           ( r m p )
            ROT                         ( m p r )
            +                           ( m r )
            SWAP                        ( r m )
            10 /                        ( r m-new )        
        LOOP                            ( r m )
        DROP                            ( r )
    ELSE                                ( r )
        0                               ( r )
    THEN                                ( r )
;

\ Get integer value of the buffer multiplied by 10^x
\
: fms_get_buffer_value              ( x -- i )
    DUP                             ( x x )
    fms_get_whole_value             ( x x n )
    SWAP 0                          ( x n x 0 )
    ?DO                             ( x n )
        10 *                        ( x n )
    LOOP                            ( x n )
    \ add fractional part
    SWAP                            ( n x )
    9 SWAP -                        ( n xf )
    fms_get_frac_e9                 ( n xf f )
    SWAP 0                          ( n f xf 0 )
    ?DO                             ( n f )
        10 /                        ( n f/10 )
    LOOP                            ( n f )
    +                               ( n )
;

\ Process keypresses on the FMS numeric keypad
\
: fms_handle_keypad                 ( raw-event -- )
    MASK_FMS_KEY AND                ( u )
    DUP                             ( u u )
    FMS_CLR = IF              ( [IF 1] u )
        DROP                        (  )
        reset_fms_num_buffer        (  )
    \ check for +/- key
    ELSE DUP FMS_PM = IF      ( [ELSE 1] [IF 2] u )
        DROP                        (  )
        fms_pm_state @ IF               ( [IF 3] )
            BL                      ( u )
        ELSE                        ( [ELSE 3] u )
            [CHAR] -                ( u )
        THEN                        ( [THEN 3] u )
        \ store the + or bl in the first position
        fms_num_buffer C!           (  )
        \ toggle the + or - state variable
        fms_pm_state @ NOT fms_pm_state !   (  )
    ELSE                            ( [ELSE 2] u )
        fms_num_curr_length @    ( u u )
        \ check to see if there is room for more
        NUMERIC_AVAILABLE_LENGTH <> IF  ( [IF 4] u )
            DUP FMS_DP =      ( u f )
            fms_dp_displayed @ NOT AND IF   ( [IF 5] u )
                DROP                (  )
                [CHAR] .            ( u )
                fms_num_buffer fms_num_curr_length @ + C!    (  )
                1 fms_num_curr_length +!                     (  )
                \ set the position of the frac
                fms_num_buffer fms_num_curr_length @ + fms_frac !
                \ set the new dp displayed state
                TRUE fms_dp_displayed ! (  )
            \ ignore keycodes > 9
            ELSE DUP 10 < IF        ( [ELSE 5] [IF 6] u )
                \ add the keycode to ascii 0
                [CHAR] 0 +          ( u )
                fms_num_buffer fms_num_curr_length @ + C!    (  )
                1 fms_num_curr_length +!                     (  )
            ELSE                    ( [ELSE 6] ) \ handle up dn sp keys
                DUP FMS_UP = IF     ( u )
                    fms_up_xt fms_vec   ( u )
                ELSE                ( u )
                    DUP FMS_DN = IF ( u )
                        fms_dn_xt fms_vec   ( u )
                    ELSE            ( u )
                        DUP FMS_SP = IF ( u )
                            fms_sp_xt fms_vec   ( u )
                        THEN        ( u )
                    THEN            ( u )
                THEN                ( u )
                DROP                (  )
            THEN                    ( [THEN 6] )
            THEN                    ( [THEN 5] )
        ELSE                        ( [ELSE 4] )
            \ no more room for digits
            DROP                    (  )
        THEN                        ( [THEN 4] )
    THEN                            ( [THEN 2] )
    THEN                            ( [THEN 1] )
    fms_refresh_buffer_display
;


\ Given the raw FMS function key event, return the logical column and row
\ of the button. Column is 0 (left) or 1 (right) and ROW is 0-5.
\
: fms_key_event_to_col_row                  ( raw-event -- col row )
    DUP                                     ( raw-event raw-event )
    MASK_FMS_KEYGROUP AND                   ( raw-event key-group )
    MASK_FMS_RIGHT_FN = IF 1 ELSE 0 THEN    ( raw-event col )
    SWAP                                    ( col raw-event )
    MASK_FMS_KEY AND                        ( col row )
;

\
\
reset_fms_num_buffer

