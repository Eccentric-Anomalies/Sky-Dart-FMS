\ === MENU.FTH ===
\
\ Utilities for managing the creation and display of FMS function key buttons
\
\ menu_create   allocates a menu definition structure
\ Usage: menu_create mymenuname                     ( <name> -- )
\           simply execute mymenuname to obtain address of the struct
\
\ menu_clear    zeros out menu definition structure
\ Usage: mymenuname menu_clear                      ( addr -- )
\
\ menu_set_return_xt   set the return XT member of a menu struct
\ Usage: return-xt mymenuname menu_set_return_xt    ( xt addr -- )
\ 
\ menu_get_return_xt   retrieve the return XT member of the menu struct
\ Usage: mymenuname menu_get_return_xt              ( addr -- xt )
\
\ menu_set_menu_name    set the display name of a menu
\ Usage: c-addr u mymenuname menu_set_menu_name     ( c-addr u addr -- )
\
\ menu_get_menu_name    get the display name of a menu
\ Usage: mymenuname menu_get_menu_name              ( addr -- c-addr u )
\
\ menu_set_item_xt set the XT for a specific function key position (col row)
\ Usage: xt mymenuname col row menu_set_item_xt    ( xt addr col row -- )
\
\ menu_get_Item_xt get the XT for a specific function key position (col row)
\ Usage: mymenuname col row menu_get_Item_xt       ( addr col row -- xt)
\
\ menu_set_item_text set the item text for a specific f key position (col row)
\ Usage: c-addr u mymenuname col row menu_set_item_text    ( c-addr u addr col row -- );
\ 
\ menu_get_item_text get the item text for a specific f key position (col row)
\ Usage: mymenuname col row menu_get_item_text             ( addr col row -- c-addr u )
\
\ menu_set_item_label set the item label for a specific f key position (col row)
\ Usage: c-addr u mymenuname col row menu_set_item_label   ( c-addr u addr col row -- );
\ 
\ menu_get_item_label get the item label for a specific f key position (col row)
\ Usage: mymenuname col row menu_get_item_label            ( addr col row -- c-addr u )
\
\ menu_add_option set up parameters of a single menu item
\ Usage: xt S" ITEM" S" LABEL" mymenuname col row menu_add_option  ( xt t-addr tu l-addr lu m-addr col row -- )
\
\ menu_show display the menu on screen
\ Usage: mymenuname menu_show   ( m-addr -- )

\ Constants
\ Define sizes and offsets of items in a menu definition structure
\ Struct consists of return XT (u), menu name (c-addr u), list of 12 menu items
\ Each menu item consists of XT (u), text (c-addr u), label (c-addr u)
SYSTEM_CELL_SIZE 5 * CONSTANT MENU_ITEM_STRUCT_SIZE
\ Each menu has a menu item for each button
FMS_FN_ROWS 2* CONSTANT MENU_ITEM_QTY          
\ Each menu has a return XT
SYSTEM_CELL_SIZE CONSTANT MENU_RETURN_SIZE
\ Offset in menu struct for return XT
0 CONSTANT MENU_RETURN_OFFSET
\ Each menu has a name
SYSTEM_CELL_SIZE 2* CONSTANT MENU_NAME_SIZE
\ OFfset in menu struct for name
MENU_RETURN_SIZE CONSTANT MENU_NAME_OFFSET
\ Offset in menu struct for items
MENU_NAME_OFFSET MENU_NAME_SIZE + CONSTANT MENU_ITEMS_OFFSET
\ Offset in an item for XT
0 CONSTANT MENU_ITEM_XT_OFFSET
\ Offset in an item for text
SYSTEM_CELL_SIZE CONSTANT MENU_ITEM_TEXT_OFFSET
\ Offset in an item for label text
SYSTEM_CELL_SIZE 2* MENU_ITEM_TEXT_OFFSET + 
    CONSTANT MENU_ITEM_LABEL_OFFSET
\ So we can define the overall structure size
MENU_ITEM_QTY MENU_ITEM_STRUCT_SIZE * MENU_RETURN_SIZE + MENU_NAME_SIZE +
    CONSTANT MENU_STRUCT_SIZE

\ Variables
2VARIABLE menu_col_row_scratch
VARIABLE menu_scratch


\ Create a menu definition structure
\
: menu_create                   ( <name> -- )
    CREATE                      (  )
    MENU_STRUCT_SIZE ALLOT      (  )
;

\ Clear a menu definition structure
\
: menu_clear                    ( addr -- )
    MENU_STRUCT_SIZE 0          ( addr u b )
    FILL                        (  )
;

\ Set the return XT in a menu definition struct
\
: menu_set_return_xt            ( xt addr -- )
    MENU_RETURN_OFFSET +        ( xt addr )
    !                           (  )
;

\ Get the return XT from a menu definition struct
\
: menu_get_return_xt            ( addr -- xt )
    MENU_RETURN_OFFSET + @      ( xt )
;

\ Set the menu name for a menu
\
: menu_set_menu_name            ( c-addr u addr -- )
    MENU_NAME_OFFSET + 2!       (  )
;

\ Get the menu name for a menu
\
: menu_get_menu_name            ( addr -- c-addr u )
    MENU_NAME_OFFSET + 2@       ( c-addr u )
;

\ Utility for getting address of an item xt
\
: menu_get_item_xt_addr         ( addr col row -- addr )
    SWAP                        ( addr row col )
    FMS_FN_ROWS * +             ( addr u )
    MENU_ITEM_STRUCT_SIZE *     ( addr offset )
    MENU_ITEM_XT_OFFSET +       ( addr offset )
    MENU_ITEMS_OFFSET +         ( addr offset )
    +                           ( addr )
;

\  Set the menu item xt (col row are function key coordinates)
\
: menu_set_item_xt              ( xt addr col row -- )
    menu_get_item_xt_addr       ( xt addr )
    !                           (  )
;

\ Get a menu item xt (col row are function key coordinates)
\
: menu_get_Item_xt              ( addr col row -- xt)
    menu_get_item_xt_addr       ( addr )
    @                           ( xt )
;

\ Utility for getting address of an item text
\
: menu_get_item_text_addr       ( addr col row -- addr )
    SWAP                        ( addr row col )
    FMS_FN_ROWS * +             ( addr u )
    MENU_ITEM_STRUCT_SIZE *     ( addr offset )
    MENU_ITEM_TEXT_OFFSET +     ( addr offset )
    MENU_ITEMS_OFFSET +         ( addr offset )
    +                           ( addr )
;

\  Set the menu item text (col row are function key coordinates)
\
: menu_set_item_text            ( c-addr u addr col row -- )
    menu_get_item_text_addr     ( c-addr u addr )
    2!                          (  )
;

\ Get a menu item text (col row are function key coordinates)
\
: menu_get_item_text            ( addr col row -- c-addr u )
    menu_get_item_text_addr     ( addr )
    2@                          ( c-addr u )
;

\ Utility for getting address of an item label
\
: menu_get_item_label_addr      ( addr col row -- addr )
    SWAP                        ( addr row col )
    FMS_FN_ROWS * +             ( addr u )
    MENU_ITEM_STRUCT_SIZE *     ( addr offset )
    MENU_ITEM_LABEL_OFFSET +    ( addr offset )
    MENU_ITEMS_OFFSET +         ( addr offset )
    +                           ( addr )
;

\  Set the menu item label (col row are function key coordinates)
\
: menu_set_item_label           ( c-addr u addr col row -- )
    menu_get_item_label_addr    ( c-addr u addr )
    2!                          (  )
;

\ Get a menu item label (col row are function key coordinates)
\
: menu_get_item_label           ( addr col row -- c-addr u )
    menu_get_item_label_addr    ( addr )
    2@                          ( c-addr u )
;

\ Set a complete menu line in one step 
\
: menu_add_option               ( xt t-addr tu l-addr lu m-addr col row -- )
    2DUP                        ( xt t-addr tu l-addr lu m-addr col row col row -- )
    menu_col_row_scratch 2!     ( xt t-addr tu l-addr lu m-addr col row )
    2 PICK                      ( xt t-addr tu l-addr lu m-addr col row m-addr )
    menu_scratch !              ( xt t-addr tu l-addr lu m-addr col row )
    menu_set_item_label         ( xt t-addr tu )
    menu_scratch @              ( xt t-addr tu m-addr )
    menu_col_row_scratch 2@     ( xt t-addr tu m-addr col row )
    menu_set_item_text          ( xt )
    menu_scratch @              ( xt m-addr )
    menu_col_row_scratch 2@     ( xt m-addr col row )
    menu_set_item_xt            (  )
;

\ Utility for displaying a single menu item text
\
: menu_item_text_show           ( m-addr col row  -- )
    2DUP                        ( m-addr col row col row )
    menu_col_row_scratch 2!     ( m-addr col row )
    menu_get_item_text          ( c-addr u )
    menu_col_row_scratch 2@     ( c-addr u col row )
    fms_set_fkey_text           (  )
;

\ Utility for displaying a single menu item label
\
: menu_item_label_show          ( m-addr col row  -- )
    2DUP                        ( m-addr col row col row )
    menu_col_row_scratch 2!     ( m-addr col row )
    menu_get_item_label         ( c-addr u )
    menu_col_row_scratch 2@     ( c-addr u col row )
    fms_set_fkey_label          (  )
;

\ Display a complete menu on the screen
\
: menu_show                             ( m-addr -- )
    2 0 DO                              ( m-addr )
        6 0 DO                          ( m-addr )
            DUP                         ( m-addr m-addr )
            J I menu_item_text_show     ( m-addr )
            DUP                         ( m-addr m-addr )
            J I menu_item_label_show    ( m-addr )
        LOOP
    LOOP                                (  )
;