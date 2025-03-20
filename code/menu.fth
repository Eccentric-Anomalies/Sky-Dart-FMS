\ === MENU.FTH ===
\
\ Utilities for managing the creation and display of FMS function key buttons
\
\ MENU-CREATE   allocates a menu definition structure
\ Usage: MENU-CREATE mymenuname                     ( <name> -- )
\           simply execute mymenuname to obtain address of the struct
\
\ MENU-CLEAR    zeros out menu definition structure
\ Usage: mymenuname MENU-CLEAR                      ( addr -- )
\ MENU-SET-RETURN-XT   set the return XT member of a menu struct
\ Usage: return-xt mymenuname MENU-SET-RETURN-XT    ( xt addr -- )
\ 
\ MENU-GET-RETURN-XT   retrieve the return XT member of the menu struct
\ Usage: mymenuname MENU-GET-RETURN-XT              ( addr -- xt )
\
\ MENU-SET-MENU-NAME    set the display name of a menu
\ Usage: c-addr u mymenuname MENU-SET-MENU-NAME     ( c-addr u addr -- )
\
\ MENU-GET-MENU-NAME    get the display name of a menu
\ Usage: mymenuname MENU-GET-MENU-NAME              ( addr -- c-addr u )
\
\ MENU-SET-ITEM-XT set the XT for a specific function key position (col row)
\ Usage: xt mymenuname col row MENU-SET-ITEM-XT    ( xt addr col row -- )
\
\ MENU-GET-ITEM-XT get the XT for a specific function key position (col row)
\ Usage: mymenuname col row MENU-GET-ITEM-XT       ( addr col row -- xt)
\
\ MENU-SET-ITEM-TEXT set the item text for a specific f key position (col row)
\ Usage: c-addr u mymenuname col row MENU-SET-ITEM-TEXT    ( c-addr u addr col row -- );
\ 
\ MENU-GET-ITEM-TEXT get the item text for a specific f key position (col row)
\ Usage: mymenuname col row MENU-GET-ITEM-TEXT             ( addr col row -- c-addr u )
\
\ MENU-SET-ITEM-LABEL set the item label for a specific f key position (col row)
\ Usage: c-addr u mymenuname col row MENU-SET-ITEM-LABEL   ( c-addr u addr col row -- );
\ 
\ MENU-GET-ITEM-LABEL get the item label for a specific f key position (col row)
\ Usage: mymenuname col row MENU-GET-ITEM-LABEL            ( addr col row -- c-addr u )
\
\ MENU-ADD-OPTION set up parameters of a single menu item
\ Usage: xt S" ITEM" S" LABEL" mymenuname col row MENU-ADD-OPTION  ( xt t-addr tu l-addr lu m-addr col row -- )
\
\ MENU-SHOW display the menu on screen
\ Usage: mymenuname MENU-SHOW   ( m-addr -- )

\ Constants
\ Define sizes and offsets of items in a menu definition structure
\ Struct consists of return XT (u), menu name (c-addr u), list of 12 menu items
\ Each menu item consists of XT (u), text (c-addr u), label (c-addr u)
SYSTEM-CELL-SIZE 5 * CONSTANT MENU-ITEM-STRUCT-SIZE
\ Each menu has a menu item for each button
VALUE-FMS-FN-ROWS 2* CONSTANT MENU-ITEM-QTY          
\ Each menu has a return XT
SYSTEM-CELL-SIZE CONSTANT MENU-RETURN-SIZE
\ Offset in menu struct for return XT
0 CONSTANT MENU-RETURN-OFFSET
\ Each menu has a name
SYSTEM-CELL-SIZE 2* CONSTANT MENU-NAME-SIZE
\ OFfset in menu struct for name
MENU-RETURN-SIZE CONSTANT MENU-NAME-OFFSET
\ Offset in menu struct for items
MENU-NAME-OFFSET MENU-NAME-SIZE * CONSTANT MENU-ITEMS-OFFSET
\ Offset in an item for XT
0 CONSTANT MENU-ITEM-XT-OFFSET
\ Offset in an item for text
SYSTEM-CELL-SIZE CONSTANT MENU-ITEM-TEXT-OFFSET
\ Offset in an item for label text
SYSTEM-CELL-SIZE 2* MENU-ITEM-TEXT-OFFSET + 
    CONSTANT MENU-ITEM-LABEL-OFFSET
\ So we can define the overall structure size
MENU-ITEM-QTY MENU-ITEM-STRUCT-SIZE * MENU-RETURN-SIZE + MENU-NAME-SIZE +
    CONSTANT MENU-STRUCT-SIZE

\ Variables
2VARIABLE MENU-COL-ROW-SCRATCH
VARIABLE MENU-SCRATCH


\ Create a menu definition structure
\
: MENU-CREATE                   ( <name> -- )
    CREATE                      (  )
    MENU-STRUCT-SIZE ALLOT      (  )
;

\ Clear a menu definition structure
\
: MENU-CLEAR                    ( addr -- )
    MENU-STRUCT-SIZE 0          ( addr u b )
    FILL                        (  )
;

\ Set the return XT in a menu definition struct
\
: MENU-SET-RETURN-XT            ( xt addr -- )
    MENU-RETURN-OFFSET +        ( xt addr )
    !                           (  )
;

\ Get the return XT from a menu definition struct
\
: MENU-GET-RETURN-XT            ( addr -- xt )
    MENU-RETURN-OFFSET + @      ( xt )
;

\ Set the menu name for a menu
\
: MENU-SET-MENU-NAME            ( c-addr u addr -- )
    MENU-NAME-OFFSET + 2!       (  )
;

\ Get the menu name for a menu
\
: MENU-GET-MENU-NAME            ( addr -- c-addr u )
    MENU-NAME-OFFSET + 2@       ( c-addr u )
;

\ Utility for getting address of an item xt
\
: MENU-GET-ITEM-XT-ADDR         ( addr col row -- addr )
    SWAP                        ( xt addr row col )
    VALUE-FMS-FN-ROWS * +       ( xt addr u )
    MENU-ITEM-STRUCT-SIZE *     ( xt addr offset )
    MENU-ITEM-XT-OFFSET +       ( xt addr offset )
    MENU-ITEMS-OFFSET +         ( xt addr offset )
    +                           ( xt addr )
;

\  Set the menu item xt (col row are function key coordinates)
\
: MENU-SET-ITEM-XT              ( xt addr col row -- )
    MENU-GET-ITEM-XT-ADDR       ( xt addr )
    !                           (  )
;

\ Get a menu item xt (col row are function key coordinates)
\
: MENU-GET-ITEM-XT              ( addr col row -- xt)
    MENU-GET-ITEM-XT-ADDR       ( addr )
    @                           ( xt )
;

\ Utility for getting address of an item text
\
: MENU-GET-ITEM-TEXT-ADDR       ( addr col row -- addr )
    SWAP                        ( xt addr row col )
    VALUE-FMS-FN-ROWS * +       ( xt addr u )
    MENU-ITEM-STRUCT-SIZE *     ( xt addr offset )
    MENU-ITEM-TEXT-OFFSET +     ( xt addr offset )
    MENU-ITEMS-OFFSET +         ( xt addr offset )
    +                           ( xt addr )
;

\  Set the menu item text (col row are function key coordinates)
\
: MENU-SET-ITEM-TEXT            ( c-addr u addr col row -- )
    MENU-GET-ITEM-TEXT-ADDR     ( c-addr u addr )
    2!                          (  )
;

\ Get a menu item text (col row are function key coordinates)
\
: MENU-GET-ITEM-TEXT            ( addr col row -- c-addr u )
    MENU-GET-ITEM-TEXT-ADDR     ( addr )
    2@                          ( c-addr u )
;

\ Utility for getting address of an item label
\
: MENU-GET-ITEM-LABEL-ADDR      ( addr col row -- addr )
    SWAP                        ( xt addr row col )
    VALUE-FMS-FN-ROWS * +       ( xt addr u )
    MENU-ITEM-STRUCT-SIZE *     ( xt addr offset )
    MENU-ITEM-LABEL-OFFSET +    ( xt addr offset )
    MENU-ITEMS-OFFSET +         ( xt addr offset )
    +                           ( xt addr )
;

\  Set the menu item label (col row are function key coordinates)
\
: MENU-SET-ITEM-LABEL           ( c-addr u addr col row -- )
    MENU-GET-ITEM-LABEL-ADDR    ( c-addr u addr )
    2!                          (  )
;

\ Get a menu item label (col row are function key coordinates)
\
: MENU-GET-ITEM-LABEL           ( addr col row -- c-addr u )
    MENU-GET-ITEM-LABEL-ADDR    ( addr )
    2@                          ( c-addr u )
;

\ Set a complete menu line in one step 
\
: MENU-ADD-OPTION               ( xt t-addr tu l-addr lu m-addr col row -- )
    2DUP                        ( xt t-addr tu l-addr lu m-addr col row col row -- )
    MENU-COL-ROW-SCRATCH 2!     ( xt t-addr tu l-addr lu m-addr col row )
    2 PICK                      ( xt t-addr tu l-addr lu m-addr col row m-addr )
    MENU-SCRATCH !              ( xt t-addr tu l-addr lu m-addr col row )
    MENU-SET-ITEM-LABEL         ( xt t-addr tu )
    MENU-SCRATCH @              ( xt t-addr tu m-addr )
    MENU-COL-ROW-SCRATCH 2@     ( xt t-addr tu m-addr col row )
    MENU-SET-ITEM-TEXT          ( xt )
    MENU-SCRATCH @              ( xt m-addr )
    MENU-COL-ROW-SCRATCH 2@     ( xt m-addr col row )
    MENU-SET-ITEM-XT            (  )
;

\ Utility for displaying a single menu item
\
: MENU-ITEM-SHOW                ( m-addr col row  -- )
    2DUP                        ( m-addr col row col row )
    MENU-COL-ROW-SCRATCH 2!     ( m-addr col row )
    MENU-GET-ITEM-TEXT          ( c-addr u )
    MENU-COL-ROW-SCRATCH 2@     ( c-addr u col row )
    FMS-SET-FKEY-TEXT           (  )
;

\ Display a complete menu on the screen
\
: MENU-SHOW                     ( m-addr -- )
    PAGE                        ( m-addr )
    2 0 DO                      (  )
        6 0 DO                  
    LOOP                        (  )
;